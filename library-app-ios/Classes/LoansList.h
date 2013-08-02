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
#import "libraryappAppDelegate.h"
#import "XMLRPCConnectionDelegate.h"

@interface LoansList : UIViewController<UIScrollViewDelegate, MyTabBarNotificationDelegate, XMLRPCConnectionDelegate, UIAlertViewDelegate, UINavigationControllerDelegate> {
	UIScrollView* itemScroller;
	UIActivityIndicatorView* loadingIndicator;
	UIButton* moreButton;
	UILabel* patronName;
    
	UIView* blackCoverView;

	NSMutableArray* loanItems;
	UILabel* headLine;
	int currentResultsPageNo;
	int currentScrollerAppendPosition;
	bool showingBlackCover;
	
	NSDate* lastDataRefreshTimestamp;

}

@property (nonatomic, strong) IBOutlet UIScrollView* itemScroller;
@property (nonatomic, strong) IBOutlet UILabel* headLine;
@property (nonatomic, strong) IBOutlet UIButton* renewAllButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) IBOutlet UIButton* moreButton;
@property (nonatomic, strong) IBOutlet UILabel* patronName;
@property (nonatomic, strong) IBOutlet UIView* blackCoverView;

@property (nonatomic, strong) NSDate* lastDataRefreshTimestamp;

- (void)updateLoanItems;

- (void)tabBarControllerSelected:(id)newController;
- (void)authenticationSucceeded;

- (IBAction)renewAllLoans:(id)sender;
- (IBAction)getMoreResults:(id)sender;

- (void)renewLoan:(NSString*)loanID;

- (void)showBlackCover;
- (void)hideBlackCover;

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)handleLoadError;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
