/***********************************************
 This file is part of redia-library-app-ios.
 
 Copyright (c) 2012, 2013 Redia A/S
 
 Redia-library-app-ios is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Redia-library-app-ios is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with redia-library-app-ios.  If not, see <http://www.gnu.org/licenses/>.
 
 *********************************************** */


#import "MainBibSearch.h"
#import "SearchResultsView.h"
#import "defines.h"
#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "XMLRPCEncoder.h"
#import "SearchResultItem.h"
#import "InfoGalleriImageUrlUtils.h"
#import <CommonCrypto/CommonDigest.h>
#import "LibraryXmlRpcClient.h"
#import "BibSearchSingleton.h"
#import <QuartzCore/QuartzCore.h>



@implementation MainBibSearch

@synthesize theSearchBar;
@synthesize theSearchBarSuperView;
@synthesize resultsSuperView;
@synthesize resultsSubView;
@synthesize backButton;
@synthesize showingBackButton;
@synthesize scanButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	shouldBeginEditing = YES;

	//removed during reconstruction of search bar hierachy: [[BibSearchSingleton instance] registerSubController:self];
    
    showingBackButton=FALSE;
    
    //backButton.layer.anchorPoint=CGPointMake(0,0);
    origBackButtonPos = backButton.layer.position;
    
    
    [backButton setBackgroundImage:[[backButton backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:30 topCapHeight:0] forState:UIControlStateNormal];
    
#ifdef REDIA_APP_USE_SCANNER_OPTION
    self.scanButton.hidden=NO;
    [self.scanButton.superview bringSubviewToFront:self.scanButton];
    [self.scanButton addTarget:self action:@selector(scanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect search_frame = theSearchBar.frame;
    CGRect scan_frame = scanButton.frame;
    
    CGFloat delta = scan_frame.origin.x + scan_frame.size.width;
    search_frame.origin.x += delta;
    search_frame.size.width -= delta;
    theSearchBar.frame=search_frame;
    
#endif
}

- (void)scanButtonClicked:(id)sender
{
#ifdef REDIA_APP_USE_SCANNER_OPTION
    if (!barcodeView) {
        barcodeView = [[BarcodeViewController alloc] initWithNibName:@"BarcodeViewController" bundle:nil];
    }
    /*
    UIView* otherview = [[UIApplication sharedApplication] keyWindow];
    CGRect otherframe = CGRectMake(0, 18, 320, 460);
    
    [otherview addSubview:barcodeView.view];
    [otherview bringSubviewToFront:barcodeView.view];
    //CGRect anim_from_frame = otherframe;
    //anim_from_frame.origin.y += 480;
    
    barcodeView.view.frame = otherframe;
    CGPoint curpos = CGPointMake(160, 240);
    barcodeView.view.layer.position = CGPointMake(curpos.x, curpos.y+480);
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         barcodeView.view.layer.position = curpos;
                     } 
     ];
    */
    [self presentModalViewController:barcodeView animated:YES];
    DLog(@"clicked scan button");
#endif
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DLog(@"didReceiveMemoryWarning");

    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setScanButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.theSearchBar=nil;
	self.resultsSuperView=nil;
	self.resultsSubView=nil;
    self.backButton=nil;
  	DLog(@"viewDidUnload");
}


- (void)dealloc {
    	
	DLog(@"dealloced");
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
	//NSLog(@"searchBar:textDidChange: isFirstResponder: %i", [searchBar isFirstResponder]);
    if(![searchBar isFirstResponder]) {
        // user tapped the 'clear' button
        shouldBeginEditing = NO;
        // do whatever I want to happen when the user clears the search...
    } else {
		/* nope
		if ([searchText isEqualToString:@""]) {
			[searchBar resignFirstResponder];
		}
		 */
	}
	
	[[BibSearchSingleton instance] setCurrentSearchString:searchText];

	//NSLog(@"new search text: %@",searchText);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	DLog(@"do search text: %@",searchBar.text);
	[searchBar resignFirstResponder];
	
	self.resultsSubView = [[SearchResultsView alloc] initWithNibName:@"SearchResultsView" bundle:nil];
	[self.resultsSuperView addSubview:self.resultsSubView.view];
	[self.resultsSubView.view setFrame:self.resultsSuperView.frame];
	
	//old temp hack for testers: NSString* querytext = [NSString stringWithFormat:@"%@ ac.source=\"Bibliotekets materialer\" ",searchBar.text];
    
    [self.resultsSubView performSearch:searchBar.text typeFilter:@"" resultsPageNo:0];
	
}

- (void)somewhereElseClicked:(id)sender
{
	if ([theSearchBar canResignFirstResponder]) {
		[theSearchBar resignFirstResponder];
	}
}

- (void)hideResultsView:(id)sender
{
	[self somewhereElseClicked:self];
	if (self.resultsSuperView != nil && self.resultsSubView != nil) {
		[self.resultsSubView.view removeFromSuperview];
		[self.resultsSubView discardResultItems:sender];
		self.resultsSubView = nil; //released pr. property "retain" attribute
	}		
	
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    // reset the shouldBeginEditing BOOL ivar to YES, but first take its value and use it to return it from the method call
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
	DLog(@"search cancelled");
	[searchBar resignFirstResponder];
}

- (BOOL)isShowingBackButton {
    return showingBackButton;
}

- (void)showBackButton:(id)sender
{
    if (!showingBackButton) {
        backButton.hidden=FALSE;
        backButton.layer.opacity=0.0;
        
        int move_x=80;
        CGRect newrect2 = theSearchBarSuperView.layer.bounds;
        newrect2.size.width = 320-move_x;
        newrect2.origin.x = move_x;
        
        newrect2=CGRectMake(move_x, 0, 320-move_x, 44);
        
        //CGPoint newpos = theSearchBarSuperView.layer.position;
        //newpos.x += move_x;
        
        CGPoint newbuttonpos = CGPointMake(320/2, 44/2);
       
        backButton.layer.position = newbuttonpos;

        
        [UIView animateWithDuration:0.5 
                         animations:^{
                             backButton.layer.opacity=1.0;
                             backButton.layer.position = origBackButtonPos;
                             theSearchBarSuperView.frame=newrect2;
                             //theSearchBar.layer.position = newpos;
                         }
                         //completion:^(BOOL b){
                         //    theSearchBar.frame = newrect2;
                         //}
         ];

        showingBackButton=TRUE;
    }
}

- (void)repeatBackButtonAnimation:(id)sender isDescending:(bool)left_dir
{
    CGPoint right = CGPointMake(320/2, 44/2);
    CGPoint left = CGPointMake(-320/2, 44/2);
    
    CGPoint newbuttonpos1;
    CGPoint newbuttonpos2;
    
    if (left_dir) {
        newbuttonpos1 = left;
        newbuttonpos2 = right;
    } else {
        newbuttonpos1 = right;
        newbuttonpos2 = left;
    }
    
    [UIView animateWithDuration:0.25 
                     animations:^{
                         backButton.layer.position = newbuttonpos1;
                     }
                     completion:^(BOOL c) {
                         backButton.layer.position = newbuttonpos2;
                         [UIView animateWithDuration:0.25 
                                          animations:^{
                                              backButton.layer.position = origBackButtonPos;
                                          }
                                          completion:^(BOOL c) {
                                              
                                          }
                          ];
                         
                     }
     ];

}

- (void)hideBackButton:(id)sender
{
    if (showingBackButton) {
        
        CGPoint newbuttonpos = CGPointMake(320/2, 44/2);
       
        [UIView animateWithDuration:0.5 
                         animations:^{
                             backButton.layer.opacity=0.0;
                             backButton.layer.position = newbuttonpos;
                             theSearchBarSuperView.frame = CGRectMake(0, 0,320, 44);
                         }
         ];
        
        showingBackButton=FALSE;
    }
    
}


@end
