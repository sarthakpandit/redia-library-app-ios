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


#import "BrowserViewController.h"
#import "defines.h"

#ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
#error This file must only be included in targets with REDIA_APP_USE_MORE_ABOUT_OPTION defined
#endif

@interface BrowserViewController ()

@end

@implementation BrowserViewController

@synthesize theWebView;
@synthesize backButton;
@synthesize forwardButton;
@synthesize loadingIndicator;


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
    if ([self.startUrl length]>0) {
        [theWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.startUrl]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setTheWebView:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

- (void)checkBackForwardButtons
{
	backButton.enabled = [theWebView canGoBack];
	backButton.alpha = [theWebView canGoBack] ? 1.0 : 0.3;
	forwardButton.enabled = [theWebView canGoForward];
	forwardButton.alpha = [theWebView canGoForward] ? 1.0 : 0.3;
}

- (IBAction)backClicked:(id)sender {
    [theWebView goBack];
    [self checkBackForwardButtons];
}

- (IBAction)forwardClicked:(id)sender {
    [theWebView goForward];
    [self checkBackForwardButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[self checkBackForwardButtons];
	[loadingIndicator stopAnimating];
	DLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    [loadingIndicator stopAnimating];
    DLog(@"didFailLoadWithError: %@",error);
    /*
    DLog(@"code %d: userinfo: %@", error.code, error.userInfo);
    if (error.code==101 || error.code == 102) {
        NSString* failing_url = [error.userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];
        failing_url = [failing_url stringByReplacingOccurrencesOfString:@"itpc://" withString:@"itms://"];
        DLog(@"forwarding failed url to safari: %@",failing_url);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:failing_url]];
    }
    */
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	//[loadingIndicator startAnimating];
    DLog(@"type %d for url %@",navigationType, [request URL]);
    
    if (navigationType != UIWebViewNavigationTypeOther) {
        lasturl = [request URL];
    }
    
	[self checkBackForwardButtons];
	
    return YES;
}

- (IBAction)shareButtonClicked:(id)sender {
    if (lasturl!=nil) {
        [[UIApplication sharedApplication] openURL:lasturl];
    }
}

@end
