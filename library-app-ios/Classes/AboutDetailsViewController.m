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


#ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
#error This file must only be included in targets with REDIA_APP_USE_MORE_ABOUT_OPTION defined
#endif

#import "AboutDetailsViewController.h"
#import "AboutDetailsItemViewController.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import "defines.h"
#import "BibSearchSingleton.h"
#import "SearchDetailView.h"

@interface AboutDetailsViewController ()

@end

@implementation AboutDetailsViewController

@synthesize coverImageView, titleLabel, authorLabel, reserveButton, loadingIndicator, mainScroller; //, identifier, reservationId;
@synthesize superViewController;
@synthesize resultObject;

-(void)checkForUpdate
{
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.view addGestureRecognizer:gest];
    
    titleLabel.verticalAlign = MultiLineLabelVerticalAlignTop;
    authorLabel.verticalAlign = MultiLineLabelVerticalAlignBottom;
    

}

-(void)viewDidLayoutSubviews
{
    authorLabel.verticalAlign = authorLabel.verticalAlign;
    authorLabel.text = authorLabel.text;
    
}

- (void)updateFromResultObject:(SearchResultObject*)res
{
    [self view];
    
    self.resultObject = res;
    //advc.identifier = self.identifier;
    //advc.reservationId = self.reservationId;
    if (res.coverImage!=nil) {
        coverImageView.image = res.coverImage;
    }
    titleLabel.text = res.origTitle; // self.titleLabel.text;
    authorLabel.text = res.origAuthor; // self.authorLabel.text;
    
    [self performSelector:@selector(fetchAboutDetails) withObject:nil afterDelay:0];
    
    if ([res.identifier length]>0) {
        [[LibraryXmlRpcClient instance] getObjectExtras:[NSArray arrayWithObject:res.identifier] delegate:self];
    }
}

-(void)fetchAboutDetails
{
    int y = 142-8;
    int itemheight = 47;
    
    detailButtons = [NSMutableArray new];
    
    for (int i=0; i<5; i++) {
        AboutDetailsItemViewController* item = [AboutDetailsItemViewController new];
        item.superViewController = self.superViewController;
        //item.view.hidden=YES;
        
        CGRect newframe = CGRectMake(0, y, 320, itemheight);
        item.view.frame = newframe;
        [mainScroller addSubview:item.view];
        [self addChildViewController:item];
        [detailButtons addObject:item];
        y += itemheight;
        
        
        switch (i) {
            case 0:
                item.iconView.image = [UIImage imageNamed:@"details-icon-books"];
                
                [item fetchDataForExternalsKey:@"series" identifier:resultObject.identifier];
                break;
                
            case 1:
                item.iconView.image = [UIImage imageNamed:@"details-icon-star"];
                [item fetchDataForExternalsKey:@"reviews" identifier:resultObject.identifier];
                break;
                
            case 2:
                item.iconView.image = [UIImage imageNamed:@"details-icon-people"];
                [item fetchDataForExternalsKey:@"adhl" identifier:resultObject.identifier];
                break;
                
            case 3:
                item.iconView.image = [UIImage imageNamed:@"details-icon-bookstack"];
                [item fetchDataForExternalsKey:@"othersbyauthor" identifier:resultObject.identifier];
                break;
                
            case 4:
                item.iconView.image = [UIImage imageNamed:@"details-icon-person"];
                [item fetchDataForExternalsKey:@"aboutauthor" identifier:resultObject.identifier];
                break;
                
            default:
                break;
        }
    }
}

-(void)tabBarControllerSelected:(id)newController
{
    
}

-(void)authenticationFailed {
}


-(void)authenticationSucceeded
{
    
}
-(void)addReservationViewDismissed:(id)sender
{
    [currentReservationView.view removeFromSuperview];
    currentReservationView = nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reserveButtonClicked:(id)sender {
    currentReservationView = [AddReservationView requestReservation:resultObject.reservationId withTitle:self.titleLabel.text delegate:self inNavigationController:self.navigationController];
    [[self.tabBarController selectedViewController].view addSubview:currentReservationView.view];

}

- (IBAction)detailsButtonClicked:(id)sender {
    SearchDetailView* sdv = [[SearchDetailView alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:sdv animated:YES];
    
    [sdv updateFromResultObject:self.resultObject];
    sdv.aboutButton.hidden=YES;

}


- (void)viewDidUnload {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
    [self setDetailsButton:nil];
    [super viewDidUnload];
}

-(void)dealloc
{
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
}

/*  ------------------------------------------------------
 XMLRPC
 ------------------------------------------------------
 */


- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	DLog(@"Response for request method: %@", [request method]);
	if ([response isFault]) {
		NSLog(@"Fault code: %@", [response faultCode]);
		
		NSLog(@"Fault string: %@", [response faultString]);
        
        [self.loadingIndicator stopAnimating];
        return;
        
	} else {
		DLog(@"Parsed response for method %@: %@",[request method], [response object]);
		//NSLog(@"xml: %@", [response body]);
		
		//UIFont* titlefont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
		//UIFont* authorfont = [UIFont fontWithName:@"HelveticaNeue" size:12];
        if ([[request method] isEqualToString:@"getObjectExtras"]) {
            [loadingIndicator stopAnimating];
            
            NSDictionary* dict = [response object];
            if (![[LibraryXmlRpcClient instance] isValidSuccessArray:dict]) {
                ALog(@"ERROR: received failure array: %@", dict);
                return;
            }
			NSDictionary* datadict = [dict objectForKey:@"data"];
            EXPECT_OBJECT(NSDictionary, datadict);
			//DLog(@"getCoverUrl: %@",datadict);
			if (datadict!=nil && [datadict isKindOfClass:[NSDictionary class]]) {
                //NSArray* objectextras = [datadict allValues];
                NSArray* extras_keys = [datadict allKeys];
                for (NSString* extraskey in extras_keys) {
					NSDictionary* extras_dict = [datadict objectForKey:extraskey];
                    if (extras_dict!=nil && [extras_dict isKindOfClass:[NSDictionary class]]) {
                        resultObject.reservationId = [extras_dict objectForKey:@"reservationId"];
                        bool isReservable = [[extras_dict objectForKey:@"isReservable"] boolValue];
                        if (resultObject.reservationId!=nil && [resultObject.reservationId length]>0) {
                            self.reserveButton.hidden=NO;
                            
                            //move loadingindicator out of the way
                            CGRect l_i_frame = loadingIndicator.frame;
                            l_i_frame.origin.x -= reserveButton.frame.size.width + 5;
                            loadingIndicator.frame = l_i_frame;
                            
                            if (!isReservable) {
                                self.reserveButton.enabled = NO;
                                [self.reserveButton setTitle:@"Ikke tilg." forState:UIControlStateDisabled];
                            }
                            self.reserveButton.alpha=0.0;
                            [UIView animateWithDuration:0.2
                                                  delay:0
                                                options:UIViewAnimationOptionAllowUserInteraction
                                             animations:^{
                                                 self.reserveButton.alpha=1.0;
                                             }
                                             completion:nil
                             ];
                        }
                    }

				}
			} else {
				NSLog(@"ERROR: datadict was not a dictionary");
			}
            
        } else {
            ALog(@"Warning: response not handled!");
        }
    }
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"request method %@: didFailWithError: %@",[request method], error);
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"request method %@: didReceiveAuthenticationChallenge",[request method]);
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"request method %@: didCancelAuthenticationChallenge",[request method]);
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}

@end
