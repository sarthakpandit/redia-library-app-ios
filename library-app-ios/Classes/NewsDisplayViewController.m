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


#import "NewsDisplayViewController.h"
#import "LibraryAppSetttings.h"

@interface NewsDisplayViewController ()

@end

@implementation NewsDisplayViewController
@synthesize theWebView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        emptyWebText = [[NSString alloc]
                        initWithFormat:@"<body style=\"background-color:%@;color:#ffffff; font-family:helvetica neue,arial,sans-serif;font-size:12px\">"
                        "<p style=font-size:24px;margin-bottom:-6px> </p>",
                        [LibraryAppSetttings instance].customerBackgroundColorHTML
                        ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.backgroundColor = [LibraryAppSetttings instance].customerBackgroundColor;

    [self clearHTML];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTheWebView:nil];
    [super viewDidUnload];
}

-(void)showHTML:(NSString *)html
{
    [self view]; //make sure that the view is loaded
    //NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [theWebView loadHTMLString:html baseURL:baseURL];
    theWebView.alpha = 0.0;
    theWebView.opaque=NO;
    theWebView.backgroundColor = [LibraryAppSetttings instance].customerBackgroundColor;
    
}

-(void)clearHTML
{
    [theWebView loadHTMLString:emptyWebText baseURL:nil];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{ theWebView.alpha = 1.0; }
                     completion:^(BOOL b){}
     ];
}
@end
