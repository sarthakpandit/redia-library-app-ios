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


#import "ScanInstructionsViewController.h"
#import "BarcodeViewController.h"
#import "LibraryAppSetttings.h"
#import "CustomNavigationController.h"

#ifndef REDIA_APP_USE_SCANNER_OPTION
#error This file must only be included in targets with REDIA_APP_USE_SCANNER_OPTION defined
#endif

@interface ScanInstructionsViewController ()

@end

@implementation ScanInstructionsViewController
@synthesize dontShowAgainButton;
@synthesize parentNavigationController;

+ (void)initialize
{
    //NB:LibraryAppSetttings must not depend on ScanInstructionsViewController in initialization
    NSString* tempdefaultDontShowKey = [[NSString alloc] initWithFormat:@"dontShowScanInstructions-%@", [[LibraryAppSetttings instance] getCustomerId]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
                                 dictionaryWithObjectsAndKeys:@"false", tempdefaultDontShowKey,
                                 nil];
    [defaults registerDefaults:appDefaults];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        defaultDontShowAgainKey = [[NSString alloc] initWithFormat:@"dontShowScanInstructions-%@", [[LibraryAppSetttings instance] getCustomerId]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self updateDontShowCheckbox];
    
}

-(void)viewDidLayoutSubviews
{
    if (dontShowAgainSelected) {
        if (!isScannerViewShowing) {
            [self showBarcodeScannerWithFrame:self.view.bounds animated:NO];
            isScannerViewShowing=YES;
        }
    }
}

- (void)updateDontShowCheckbox
{
    NSString* remem_dontshow = [[NSUserDefaults standardUserDefaults] stringForKey:defaultDontShowAgainKey];
    if ([remem_dontshow isEqualToString:@"true"]) {
        [dontShowAgainButton setTitle:@"√" forState:UIControlStateNormal];
        dontShowAgainSelected=YES;
	} else {
        [dontShowAgainButton setTitle:@"" forState:UIControlStateNormal];
        dontShowAgainSelected=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDontShowAgainButton:nil];
    [super viewDidUnload];
}

- (IBAction)dontShowAgainClicked:(id)sender {
    NSString* remem_dontshow = [[NSUserDefaults standardUserDefaults] stringForKey:defaultDontShowAgainKey];
	if ([remem_dontshow isEqualToString:@"true"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:defaultDontShowAgainKey];
		[dontShowAgainButton setTitle:@"" forState:UIControlStateNormal];
        dontShowAgainSelected=NO;
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:defaultDontShowAgainKey];
		[dontShowAgainButton setTitle:@"√" forState:UIControlStateNormal];
        dontShowAgainSelected=YES;
	}
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)okClicked:(id)sender {
    [self showBarcodeScannerWithFrame:self.view.bounds animated:YES];
}

-(void)showBarcodeScannerWithFrame:(CGRect)newframe animated:(BOOL)animated
{
    BarcodeViewController* bcvc = [BarcodeViewController new];
    bcvc.parentNavigationController=self.parentNavigationController;
    
    bcvc.view.frame = newframe;
    [self.view addSubview:bcvc.view];
    [self addChildViewController:bcvc];
    if (animated) {
        bcvc.view.alpha=0;
        [UIView animateWithDuration:0.5 animations:^{
            bcvc.view.alpha=1.0;
        }];
    }
    isScannerViewShowing=YES;

}


@end
