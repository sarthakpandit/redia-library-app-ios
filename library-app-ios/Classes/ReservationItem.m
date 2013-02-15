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


#import "ReservationItem.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "defines.h"
#import <QuartzCore/QuartzCore.h>

@implementation ReservationItem

@synthesize bookTitle;
@synthesize bookAuthor;
@synthesize expireDate;
@synthesize catalogID;
@synthesize queueNumber;
@synthesize pickupLabel;
@synthesize pickupBranchLabel;
@synthesize pickupSelfServiceNumber;
@synthesize loadingIndicator;
@synthesize detailDeleteButton; 
@synthesize detailDeleteConfirmButton;
@synthesize superViewController;
@synthesize reservationID;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
 UIButton
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)detailDeleteClicked:(id)sender
{
	[self showDeleteConfirm];
}

- (IBAction)detailDeleteConfirmClicked:(id)sender
{
	[[LibraryXmlRpcClient instance] removeReservation:self.reservationID delegate:self];
	
	/*
	CGRect deletebuttonframe = detailDeleteConfirmButton.frame;
	CGRect loadindicatorframe = loadingIndicator.frame;
	loadindicatorframe.origin.x = deletebuttonframe.origin.x - 25;
	[loadingIndicator setFrame:loadindicatorframe];
	 */
	loadingIndicator.hidden = NO;
	[loadingIndicator startAnimating];
	detailDeleteConfirmButton.enabled=NO;
}

- (void)showDelete
{
	self.loadingIndicator.hidden=YES;
	self.detailDeleteButton.hidden=NO;
	self.detailDeleteConfirmButton.hidden=YES;
	self.detailDeleteButton.layer.opacity = 0.0;
	[UIView animateWithDuration:0.3 animations:^{
		self.detailDeleteButton.layer.opacity = 1.0;
	}
	 ];
}

- (void)showDeleteConfirm
{
	self.loadingIndicator.hidden=YES;
	self.detailDeleteButton.hidden=NO;
	self.detailDeleteButton.layer.opacity = 1.0;

	self.detailDeleteConfirmButton.hidden=NO;
	self.detailDeleteConfirmButton.enabled=YES;
	self.detailDeleteConfirmButton.layer.opacity = 0.0;
	
	[UIView animateWithDuration:0.3 
					 animations:^{
						 
						self.detailDeleteButton.layer.opacity = 0.0;
						self.detailDeleteConfirmButton.layer.opacity = 1.0;
					 }	
					 completion:^(BOOL c){
						 self.detailDeleteButton.hidden=YES;
					 }
	 ];
	
}
- (void)hideDelete:(BOOL)animated
{
	self.loadingIndicator.hidden=YES;
	if (animated) {
		[UIView animateWithDuration:0.3 
						 animations:^{
							 
							 self.detailDeleteButton.layer.opacity = 0.0;
							 self.detailDeleteConfirmButton.layer.opacity = 0.0;
						 }	
						 completion:^(BOOL c){
							 self.detailDeleteButton.hidden=YES;
							 self.detailDeleteConfirmButton.hidden=YES;
						 }
		 ];
	} else {
		self.detailDeleteButton.hidden=YES;
		self.detailDeleteConfirmButton.hidden=YES;
	}
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

	self.bookTitle=nil;
	self.bookAuthor=nil;
	self.expireDate=nil;
	self.queueNumber=nil;
	self.pickupLabel=nil;
    self.pickupBranchLabel=nil;
	self.loadingIndicator=nil;
	self.catalogID=nil;
	self.reservationID=nil;
	
}


- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];


	
	DLog(@"dealloced");
}


- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	NSLog(@"Response for request method: %@", [request method]);
	if ([response isFault]) {
		NSLog(@"Fault code: %@", [response faultCode]);
		
		NSLog(@"Fault string: %@", [response faultString]);
	} else {
		DLog(@"Parsed response: %@", [response object]);
		//NSLog(@"xml: %@", [response body]);
		
		if ([[request method] isEqualToString:@"removeReservation"]) { 
			[self hideDelete:YES];

			NSDictionary* dict = [response object];
			bool showerror = true;
			
			if (dict!=nil && [dict objectForKey:@"message"]!=nil) {
				NSString* message = [dict objectForKey:@"message"];
				if ([message isEqualToString:@"OK"]) {
					[superViewController deleteReservationSucceeded:self];
					showerror=false;
				} 
			}
			if (showerror) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Kunne ikke slette reservationen"
																message:@"Det var ikke muligt at slette reservationen. Kontakt dit bibliotek."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];	
			}
			
		} else {
			NSLog(@"unknown method response received");
		}
	}
}



- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didFailWithError: %@", error);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netværksfejl"
													message:@"Det var ikke muligt at slette reservationen på grund problemer med netværket. Prøv venligst igen senere."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];	
	
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didReceiveAuthenticationChallenge");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netværksfejl"
													message:@"Det var ikke muligt at slette reservationen på grund problemer med netværket. Prøv venligst igen senere."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];	
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didCancelAuthenticationChallenge");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netværksfejl"
													message:@"Det var ikke muligt at slette reservationen på grund problemer med netværket. Prøv venligst igen senere."
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];	
}
 
-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}


@end
