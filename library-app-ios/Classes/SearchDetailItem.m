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


#import "SearchDetailItem.h"
#import "SearchDetailView.h"
#import "SearchResultsView.h"
#import "defines.h"
#import "AddReservationView.h"
#import <QuartzCore/QuartzCore.h>


@implementation SearchDetailItem

@synthesize bookTitle;
@synthesize bookAuthor;
@synthesize detailButton;
@synthesize reserveButton;
@synthesize typeLabel;
//@synthesize identifier;
@synthesize superViewController;
//@synthesize reservationId;
@synthesize resultObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.detailButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
    
    /*moved to big button:
    UITapGestureRecognizer* gest2 */

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.bookTitle=nil;
    self.bookAuthor=nil;
    self.detailButton=nil;
}

- (void)dealloc {
    
    
    
    DLog(@"dealloced");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)updateFromResultObject:(SearchResultObject *)res
{
    
}

- (void)parseObjectExtras:(NSDictionary*)datadict
{
    if (datadict==nil) {
        return;
    }
        
    NSDictionary* extras_dict = [datadict objectForKey:resultObject.identifier];
    
    if (extras_dict!=nil && [extras_dict isKindOfClass:[NSDictionary class]]) {
        resultObject.reservationId = [extras_dict objectForKey:@"reservationId"];
        bool isReservable = [[extras_dict objectForKey:@"isReservable"] boolValue];
        if (resultObject.reservationId!=nil && [resultObject.reservationId length]>0) {
            if (isReservable && self.reserveButton.hidden) {
                self.reserveButton.hidden=NO;
                self.reserveButton.layer.opacity=0.0;
                [UIView animateWithDuration:0.2
                                      delay:0 
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:^{
                                     self.reserveButton.layer.opacity=1.0;
                                 } 
                                 completion:nil
                 ];

            }
        }
    }
    
}

- (IBAction)showDetails:(id)sender
{
    SearchDetailView* sdv = [[SearchDetailView alloc] initWithNibName:nil bundle:nil];
    /* was:
    sdv.superViewController = self.superViewController;
    [self.superViewController.view addSubview:[sdv view]];
    [self.superViewController pushDetailView:sdv.view withViewController:sdv withFrame:CGRectMake(0, 44, 320, 365)];
     */
    //moved to updateFromResultObject: [sdv view];
    [self.navigationController pushViewController:sdv animated:YES];
    
    [sdv updateFromResultObject:resultObject];
    /* moved to updateFromResultObject
    sdv.identifier = self.identifier;
    sdv.children = nil;
    //sdv.coverImage.image = self.coverImage.image;
    sdv.titleLabel.text = self.bookTitle.text;
    sdv.authorLabel.text = self.bookAuthor.text;

    [sdv updateAllInfoView:nil];
    [sdv fetchDetails];
    */
}

- (IBAction)addReservation:(id)sender
{
    currentAddReservationView = [AddReservationView requestReservation:resultObject.reservationId withTitle:self.bookTitle.text delegate:self inNavigationController:self.navigationController];
    [[self.tabBarController selectedViewController].view addSubview:currentAddReservationView.view];
}

-(void)addReservationViewDismissed:(id)sender
{
    [currentAddReservationView.view removeFromSuperview];
    currentAddReservationView=nil;
}

@end
