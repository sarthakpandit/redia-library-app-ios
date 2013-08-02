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
#import "libraryappAppDelegate.h"


@interface LibraryAuthenticationManager : UIViewController<XMLRPCConnectionDelegate> {
	UITextField* usernameTextField;
	UITextField* passwordTextField;
	UIButton* loginButton;
	UIButton* cancelButton;
	UIActivityIndicatorView* loginIndicator;
	UIButton* rememberLogin;
    UIButton* backButton;

	NSString* connectionIdentifier;
	UITabBarController* appTabBar;
	
	id<MyTabBarNotificationDelegate> delegate;
	
	bool isShowingAuthenticationDialog;
	
	NSMutableDictionary* reservationBranches;
	NSString* reservationBranchesCachePath;
    //moved to NSDefaults: 	NSString* preferredReservationBranch;
    
	//bool infogalleriObjectsNeedsReload;
	bool reservationsListNeedsReload;
	bool loansListNeedsReload;
	bool openingHoursNeedsReload;
	
	
	NSString* preferredReservationBranchID;
	NSString* patronName;
    
    NSString* defaultAccountKey;
    NSString* defaultRememberPasswordKey;

}

@property (nonatomic, strong) IBOutlet UITextField* usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField* passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton* loginButton;
@property (nonatomic, strong) IBOutlet UIButton* cancelButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loginIndicator;
@property (nonatomic, strong) IBOutlet UIButton* rememberLogin;
@property (nonatomic, strong) IBOutlet UIButton* backButton;

@property (nonatomic, copy) NSString* preferredReservationBranchID;
@property (nonatomic, copy) NSString* patronName;

@property (nonatomic) bool isShowingAuthenticationDialog;
@property (nonatomic, readonly) NSMutableDictionary* reservationBranches;
//moved to NSDefaults: @property (nonatomic, retain) NSString* preferredReservationBranch;
@property (nonatomic, strong) UITabBarController* appTabBar;
@property (nonatomic) bool reservationsListNeedsReload;
@property (nonatomic) bool loansListNeedsReload;
@property (nonatomic) bool openingHoursNeedsReload;

//Get the singleton
+ (LibraryAuthenticationManager*) instance;

- (void)updateReservationBranches;

- (void)hideKeyboard:(id)sender;

- (IBAction)performLibraryLogin:(id)sender;

- (IBAction)cancelLogin:(id)sender;

- (BOOL)checkAuthenticationNeeded:(id<MyTabBarNotificationDelegate>)d inNavigationController:(UIViewController*)navController;

- (IBAction)rememberLoginButtonClicked:(id)sender;

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;



@end
