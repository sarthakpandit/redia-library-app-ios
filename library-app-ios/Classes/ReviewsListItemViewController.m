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


#import "ReviewsListItemViewController.h"
#import "BrowserViewController.h"

#ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
#error This file must only be included in targets with REDIA_APP_USE_MORE_ABOUT_OPTION defined
#endif


@interface ReviewsListItemViewController ()

@end

@implementation ReviewsListItemViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)discloseButtonClicked:(id)sender {
    
    if ([self.externUrl length]>0) {
        
        //NSURLRequest* newreq = [NSURLRequest requestWithURL:[NSURL URLWithString:self.externUrl]];
        //[newweb loadRequest:newreq];
        
        BrowserViewController* bvc = [BrowserViewController new];
        bvc.startUrl = self.externUrl;
        [self.navigationController pushViewController:bvc animated:YES];
        
    } else {
        UIViewController* def_vc = [UIViewController new];
        
        
        [self.navigationController pushViewController:def_vc animated:YES];
        
        def_vc.view.backgroundColor = [UIColor colorWithRed:0.118 green:0.145 blue:0.149 alpha:1];
        
        UIWebView* newweb = [[UIWebView alloc] initWithFrame:def_vc.view.bounds];
        newweb.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [def_vc.view addSubview:newweb];
        
        
        NSString* html = [NSString stringWithFormat:
                          @"<head><style type=\"text/css\">"
                          ".infomedia_HeadLine { font-weight:bold; padding-top:10px; padding-bottom:10px; }"
                          ".infomedia_SubHeadLine { visibility:hidden;max-height:0;}"
                          ".infomedia_ByLine { padding-bottom:10px; }"
                          ".infomedia_DateLine { }"
                          ".infomedia_paper { padding-bottom: 10px; }"
                          "</style></head>"
                          "<body style=\"font-family:helvetica neue,arial;font-size:13px;\">"
                          "<div align=\"center\"><img src=\"infomedia-big.png\" style=\"max-width:240px;padding-right:15px;\"></div>"
                          "<p align=\"center\"><img src=\"webpage-divider.png\" style=\"padding-right:10px;\"></p>"
                          "%@",self.unStyledWebText];
        [newweb loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
    }
}
- (void)viewDidUnload {
    [self setTheWebView:nil];
    [super viewDidUnload];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.theWebView.hidden=NO;
    self.theWebView.alpha=0;
    [UIView animateWithDuration:0.3 animations:^{
        self.theWebView.alpha=1;
    }];
}
@end
