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


#import <UIKit/UIKit.h>
#import "XMLRPCConnectionDelegate.h"
#import "BackButtonViewDelegate.h"


#ifdef REDIA_APP_USE_SCANNER_OPTION
#import "BarcodeViewController.h"
#endif

@class SearchResultsView;

@interface MainBibSearch : UIViewController<UISearchBarDelegate, BackButtonViewDelegate> {
	UISearchBar* theSearchBar;
    UIView* theSearchBarSuperView;
    UIButton* backButton;

	UIView* resultsSuperView;
	SearchResultsView* resultsSubView;

	BOOL shouldBeginEditing;
    BOOL showingBackButton;
    
    CGPoint origBackButtonPos;
    
#ifdef REDIA_APP_USE_SCANNER_OPTION
    BarcodeViewController* barcodeView;
#endif
}

@property (nonatomic, strong) IBOutlet UISearchBar* theSearchBar;
@property (nonatomic, strong) IBOutlet UIView* theSearchBarSuperView;
@property (nonatomic, strong) IBOutlet UIButton* backButton;
@property (strong, nonatomic) IBOutlet UIButton *scanButton;

@property (nonatomic, strong) UIView* resultsSuperView;
@property (nonatomic, strong) SearchResultsView* resultsSubView;
@property (nonatomic) BOOL showingBackButton;

- (void)somewhereElseClicked:(id)sender;

- (void)hideResultsView:(id)sender;


@end
