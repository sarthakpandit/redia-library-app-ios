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

#define LIBRARY_SPECIAL_OPENINGHOURS_REFRESH_TIMEOUT_SECONDS (1*60)

@interface OpeningHours : UIViewController<UIWebViewDelegate, MyTabBarNotificationDelegate, XMLRPCConnectionDelegate, UIAlertViewDelegate, UINavigationControllerDelegate> {
	UIWebView* libraryListView;
	UIActivityIndicatorView* loadingIndicator;
	
    bool isFetchingLibraryList;
	NSString* currentDetailRequestId;
	bool firstLoadLibraryListView;
	
	NSDate* lastDataRefreshTimestamp;
}

//@property (nonatomic, retain) IBOutlet UIWebView* scrapeView;
@property (nonatomic, strong) IBOutlet UIWebView* libraryListView;
//@property (nonatomic, strong) IBOutlet UIWebView* detailView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) NSDate* lastDataRefreshTimestamp;

- (void)updateLibraryList;

- (void)tabBarControllerSelected:(id)newController;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;
- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;
- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

- (void)handleLoadError;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
