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


#import "ReadMoreLinkViewController.h"
#import "defines.h"
#import "BrowserViewController.h"

#ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
#error This file must only be included in targets with REDIA_APP_USE_MORE_ABOUT_OPTION defined
#endif

@interface ReadMoreLinkViewController ()

@end

@implementation ReadMoreLinkViewController
@synthesize url;

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

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
- (IBAction)discloseButtonClicked:(id)sender {
    DLog(@"url %@",self.url);
    BrowserViewController* bvc = [BrowserViewController new];
    bvc.startUrl = self.url;
    [self.navigationController pushViewController:bvc animated:YES];
}
@end
