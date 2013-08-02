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


#import "OpeningHours.h"
#import "defines.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "BibSearchSingleton.h"
#import "OpeningHoursDetailsViewController.h"

@implementation OpeningHours

@synthesize libraryListView;
@synthesize loadingIndicator;
@synthesize lastDataRefreshTimestamp;




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	libraryListView.hidden = YES;
	//detailView.hidden = YES;

	UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.libraryListView addGestureRecognizer:gest];
	//[self.detailView addGestureRecognizer:gest];
	
	//[self.view bringSubviewToFront:self.mainSearch.view];
	
    /* moved
	UIGestureRecognizer* gest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailTapped:)];
	[gest2 setDelaysTouchesBegan:NO];
	[gest2 setCancelsTouchesInView:NO];
	[self.detailView addGestureRecognizer:gest2];
     */
	
	self.lastDataRefreshTimestamp = [NSDate distantPast];

	currentDetailRequestId = nil;
	
	firstLoadLibraryListView=true;
	//firstLoadDetailView=true;
	
	NSString* emptyweb = @"<body style=\"background:#1e2526;\"><p></p>";
	[libraryListView loadHTMLString:emptyweb baseURL:nil];
	//[detailView loadHTMLString:emptyweb baseURL:nil];
	
	//showingDetail=false;
    isFetchingLibraryList=false;
    //[self registerRootView:self.libraryListView withViewController:nil withFrame:CGRectMake(0, 44, 320, 367)];
    
	[self updateLibraryList];
    
    self.navigationController.delegate=self;
}

- (void)updateLibraryList
{
	//[[LibraryXmlRpcClient instance] cancelRequests:pendingConnectionIds];
	//[pendingConnectionIds removeAllObjects];

	//was: [pendingConnectionIds addObject:[[LibraryXmlRpcClient instance] getLibraryListHTML:self]];
    if (!isFetchingLibraryList) {
        DLog(@"updating lib list");
        [[LibraryXmlRpcClient instance] getLibraryListHTML:self];
        isFetchingLibraryList=true;
    } else {
        DLog(@"didnt update lib list since update is already in progress");
    }
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* param = [[request URL] lastPathComponent];
	NSString* command = [[[request URL] URLByDeletingLastPathComponent] lastPathComponent];
#ifdef DEBUG
	NSString* scheme = [[request URL] scheme];
#endif

	//DLog(@"opening hours request %@",request);
    DLog(@"command: %@  param: %@  scheme: %@",command,param,scheme);

	if (webView == libraryListView) {
		if (firstLoadLibraryListView) {
			firstLoadLibraryListView=false;
			return TRUE;
		}
		
		//NSString* library =  [[request URL] lastPathComponent];
		if ([command isEqualToString:@"showOpeningHours"]) {
			//numerical value means lib id
			
			if (currentDetailRequestId!=nil) {
				[[LibraryXmlRpcClient instance] cancelRequest:currentDetailRequestId];
				currentDetailRequestId=nil;
			}
			
			currentDetailRequestId = [[LibraryXmlRpcClient instance] getOpeningHoursHTML:param delegate:self];
			//[pendingConnectionIds addObject:currentDetailRequestId];
			return FALSE;
		}
	}
	return TRUE;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DLog(@"didReceiveMemoryWarning");

    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
	
	libraryListView.delegate = nil;
	//detailView.delegate = nil;
	
	self.libraryListView = nil;
	//self.detailView = nil;
	self.loadingIndicator = nil;

	self.lastDataRefreshTimestamp = nil;

	DLog(@"viewDidUnload");
}


- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
	
	DLog(@"dealloced");
}

- (void)tabBarControllerSelected:(id)newController
{
	if (newController==self) {
		//[self checkForUpdate];
		//[self hideLibraryDetail:true];
	} else {
		//[self hideLibraryDetail:false];
	}

}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController==self) {
        //[self checkForUpdate];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
    [self checkForUpdate];
}

-(void)checkForUpdate
{
    NSTimeInterval time_since = -[lastDataRefreshTimestamp timeIntervalSinceNow];
    if ([LibraryAuthenticationManager instance].openingHoursNeedsReload
        || [[LibraryXmlRpcClient instance] isRefreshNeeded]
        || time_since>LIBRARY_SPECIAL_OPENINGHOURS_REFRESH_TIMEOUT_SECONDS) {
        [self updateLibraryList];
    } else {
        //DLog(@"didnt reupdate opening hours list");
    }
}

-(void)authenticationFailed {
}


- (void)authenticationSucceeded
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	libraryListView.hidden = NO;
	[loadingIndicator stopAnimating];

    //test
    NSLog(@"output: %@",[webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]);
}

/*  ------------------------------------------------------
 XMLRPC
 ------------------------------------------------------
 */


- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	NSLog(@"Response for request method: %@", [request method]);
	if ([response isFault]) {
		NSLog(@"Fault code: %@", [response faultCode]);
		
		NSLog(@"Fault string: %@", [response faultString]);
		[self handleLoadError];
	} else {
		DLog(@"Parsed response: %@", [response object]);
		//NSLog(@"xml: %@", [response body]);
		
		if ([response object]==nil || [[[response object] objectForKey:@"result"] intValue]!=1) {
			[self handleLoadError];
			return;
		}
		
		if ([[request method] isEqualToString:@"getLibraryListHTML"]) { 
            isFetchingLibraryList=false;
			NSString* html = [[response object] objectForKey:@"data"];
			if (html != nil) {
				self.lastDataRefreshTimestamp = [NSDate date];
                [self performSelector:@selector(delayedLoadListViewHTML:) withObject:html afterDelay:0];
			}
		} else if ([[request method] isEqualToString:@"getOpeningHoursHTML"]) { 
			NSString* html = [[response object] objectForKey:@"data"];
			if (html != nil) {
                OpeningHoursDetailsViewController* ohdvc = [OpeningHoursDetailsViewController new];
				[ohdvc showHTML:html];
                [self performSelector:@selector(delayedShowOpeningHoursViewHTML:) withObject:ohdvc afterDelay:0];
			}
		}
	}
}

- (void)delayedLoadListViewHTML:(NSString*)html
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [libraryListView loadHTMLString:html baseURL:baseURL];

}

- (void)delayedShowOpeningHoursViewHTML:(OpeningHoursDetailsViewController*)ohdvc
{
    [self.navigationController pushViewController:ohdvc animated:YES];
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didFailWithError: %@", error);
	[self handleLoadError];
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didReceiveAuthenticationChallenge");
	[self handleLoadError];
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didCancelAuthenticationChallenge");
	[self handleLoadError];
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}


- (void)handleLoadError
{
	[LibraryAuthenticationManager instance].openingHoursNeedsReload = true;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netværksfejl"
													message:@"Problemer med at kontakte serveren."
												   delegate:self cancelButtonTitle:@"Afbryd" otherButtonTitles:@"Prøv igen",nil];
	[alert show];	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//DLog(@"button index %d",buttonIndex);
	if (buttonIndex==1) {
		//user clicked retry
		[self updateLibraryList];
	}
}



@end
