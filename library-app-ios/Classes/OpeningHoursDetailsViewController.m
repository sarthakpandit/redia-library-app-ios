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


#import "OpeningHoursDetailsViewController.h"
#import "defines.h"
#import "LibraryAuthenticationManager.h"
#import "LibraryXmlRpcClient.h"
#import "OpeningHours.h"

@interface OpeningHoursDetailsViewController ()

@end

@implementation OpeningHoursDetailsViewController

@synthesize detailView;

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
    
    /*
    UIGestureRecognizer* gest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailTapped:)];
	[gest2 setDelaysTouchesBegan:NO];
	[gest2 setCancelsTouchesInView:NO];
	[self.detailView addGestureRecognizer:gest2];
     */
    
    //NSString* emptyweb = @"<body style=\"background:#1e2526;\"><p></p>";
    //[detailView loadHTMLString:emptyweb baseURL:nil];
    
    lastDataRefreshTimestamp = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDetailView:nil];
    [super viewDidUnload];
}

-(void)tabBarControllerSelected:(id)newController
{
}

-(void)authenticationSucceeded
{
}

-(void)authenticationFailed
{
}

-(void)checkForUpdate
{
    NSTimeInterval time_since = -[lastDataRefreshTimestamp timeIntervalSinceNow];
    if ([LibraryAuthenticationManager instance].openingHoursNeedsReload
        || [[LibraryXmlRpcClient instance] isRefreshNeeded]
        || time_since>LIBRARY_SPECIAL_OPENINGHOURS_REFRESH_TIMEOUT_SECONDS) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        //DLog(@"didnt reupdate opening hours list");
    }
    
    
}

-(void)showHTML:(NSString *)html
{
    [self view]; //make sure that the view is loaded
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.detailView loadHTMLString:html baseURL:baseURL];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* param = [[request URL] lastPathComponent];
	NSString* command = [[[request URL] URLByDeletingLastPathComponent] lastPathComponent];
#ifdef DEBUG
	NSString* scheme = [[request URL] scheme];
    DLog(@"command: %@  param: %@  scheme: %@",command,param,scheme);
#endif

    if ([command isEqualToString:@"showMapForAddress"]) {
        NSString* searchQuery =  [param stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        NSString* urlString = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", searchQuery];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        return FALSE;
    } else {
        //not a special navigation, so update refrech timestamp
        lastDataRefreshTimestamp = [NSDate date];
    }
    
    return TRUE;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.hidden=NO;
}

@end
