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


#import "CustomNavigationController.h"
#import "BarcodeViewController.h"
#import "BibSearchSingleton.h"
#import "defines.h"
#import "SearchResultsView.h"

#ifdef REDIA_APP_USE_SCANNER_OPTION
#import "ScanInstructionsViewController.h"
#endif

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

-(void)setupCustomNavigationController{
    customNavigationBar = [[CustomNavigationBar alloc] initWithNibName:@"CustomNavigationBar" bundle:nil];
    [customNavigationBar.view setFrame:CGRectMake(0, 0, 320, 44)];
    [customNavigationBar.backButton addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    [customNavigationBar.scanButton addTarget:self action:@selector(scanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

}

-(id)init{
    self = [super init];
    if (self) {
        [self setupCustomNavigationController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupCustomNavigationController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupCustomNavigationController];
    }
    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setupCustomNavigationController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar addSubview:customNavigationBar.view];
    //[self addChildViewController:customNavigationBar];
    //customNavigationBar.view.frame = CGRectMake(0,20,320,44);
    
    [[BibSearchSingleton instance] registerCustomNavigationController:self];

    customNavigationBar.theSearchBar.delegate = self;
    shouldBeginEditing = YES;

}
-(void)viewDidLayoutSubviews
{
    //[self.view bringSubviewToFront:customNavigationBar.view];
    //customNavigationBar.view.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showSearchScanResultsRootView:(UIViewController*)newroot
{
    [customNavigationBar hideBackButtonAnimated:NO];
    
    BibSearchSingleton* bss = [BibSearchSingleton instance];
    bss.currentSearchResultsNavController=self;
    bss.searchResultsNavStackTopIndex=self.viewControllers.count;
    
    DLog(@"searchResultsNavStackTopIndex %d",bss.searchResultsNavStackTopIndex);

    [super pushViewController:newroot animated:NO];
    [self.navigationBar bringSubviewToFront:customNavigationBar.view];
    
}

- (void)dismissSearchResultsView
{
    [self popToRootViewControllerAnimated:NO];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    int index = self.viewControllers.count;

    BibSearchSingleton* bss = [BibSearchSingleton instance];
    if (bss.currentSearchResultsNavController==self) {
        index -= bss.searchResultsNavStackTopIndex;
        DLog(@"searchResultsNavStackTopIndex %d",bss.searchResultsNavStackTopIndex);
    }
    DLog(@"index %d",index);
    
    
    if (index > 1) {
        if (animated) {
            [customNavigationBar repeatBackButtonAnimationDescending:YES];
        }
    } else {
        [customNavigationBar showBackButtonAnimated:animated];
    }

    [super pushViewController:viewController animated:animated];
    [self.navigationBar bringSubviewToFront:customNavigationBar.view];
}

-(NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    [customNavigationBar hideBackButtonAnimated:animated];
    NSArray* result = [super popToRootViewControllerAnimated:animated];
    [self.navigationBar bringSubviewToFront:customNavigationBar.view];
    return result;
    
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated{
    int index = self.viewControllers.count;
    
    BibSearchSingleton* bss = [BibSearchSingleton instance];
    if (bss.currentSearchResultsNavController==self) {
        index -= bss.searchResultsNavStackTopIndex;
        DLog(@"searchResultsNavStackTopIndex %d",bss.searchResultsNavStackTopIndex);
    }
    DLog(@"index %d",index);
   
    if (index <= 2) {
        [customNavigationBar hideBackButtonAnimated:animated];
    }
    else if (index > 2){
        [customNavigationBar repeatBackButtonAnimationDescending:NO];
    }
    UIViewController* result = [super popViewControllerAnimated:animated];
    [self.navigationBar bringSubviewToFront:customNavigationBar.view];
    return result;
}

/* used for debugging
-(void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    //DLog(@"search super view pos %@",NSStringFromCGRect(customNavigationBar.theSearchBarSuperView.frame));
    [super presentModalViewController:modalViewController animated:animated];
    //DLog(@"modal super done");
    //DLog(@"search super view pos %@",NSStringFromCGRect(customNavigationBar.theSearchBarSuperView.frame));
}

-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    DLog(@"search super view pos %@",NSStringFromCGRect(customNavigationBar.theSearchBarSuperView.frame));
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
    //DLog(@"normal super done");
    //DLog(@"search super view pos %@",NSStringFromCGRect(customNavigationBar.theSearchBarSuperView.frame));
}

-(void)dismissModalViewControllerAnimated:(BOOL)animated
{
    [super dismissModalViewControllerAnimated:animated];
}
-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion];
}
 */

-(void)popView{
    [self popViewControllerAnimated:YES];
}

-(void)setNavigationBarHidden:(BOOL)navigationBarHidden{
    [super setNavigationBarHidden:navigationBarHidden];
    customNavigationBar.view.hidden = navigationBarHidden;
}

-(void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated{
    [super setNavigationBarHidden:hidden animated:animated];
    customNavigationBar.view.hidden = hidden;
}


-(void)scanButtonClicked:(id)sender
{
#ifdef REDIA_APP_USE_SCANNER_OPTION
    ScanInstructionsViewController* sivc = [ScanInstructionsViewController new];
    sivc.parentNavigationController=self;
    [self presentModalViewController:sivc animated:YES];
#endif
}

-(void)setSearchbarText:(NSString *)text
{
    customNavigationBar.theSearchBar.text = text;
}

-(void)somewhereElseClicked:(id)sender
{
    if ([customNavigationBar.theSearchBar canResignFirstResponder]) {
		[customNavigationBar.theSearchBar resignFirstResponder];
	}
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
	
	SearchResultsView* resultsSubView = [[SearchResultsView alloc] initWithNibName:@"SearchResultsView" bundle:nil];
    [self showSearchScanResultsRootView:resultsSubView];
	
	//old temp hack for testers: NSString* querytext = [NSString stringWithFormat:@"%@ ac.source=\"Bibliotekets materialer\" ",searchBar.text];
    
    [resultsSubView performSearch:searchBar.text typeFilter:@"" resultsPageNo:0];
	
}



@end
