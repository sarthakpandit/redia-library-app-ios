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


#import "LoansList.h"
#import "LoanItem.h"
#import "MainBibSearch.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import "defines.h"
#import <QuartzCore/QuartzCore.h>
#import "BibSearchSingleton.h"

@implementation LoansList

#define LIBRARY_GETLOANS_RESULTS_PER_PAGE (15)

@synthesize itemScroller;
@synthesize headLine;
@synthesize renewAllButton;
@synthesize loadingIndicator;
@synthesize moreButton;
@synthesize lastDataRefreshTimestamp;
@synthesize blackCoverView;
@synthesize patronName;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	loanItems = nil;
	
	UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.itemScroller addGestureRecognizer:gest];
	
	currentResultsPageNo=0;
	currentScrollerAppendPosition=0;
	self.lastDataRefreshTimestamp = [NSDate distantPast];
	
	self.blackCoverView.hidden = YES;
	showingBlackCover=false;
    
    self.navigationController.delegate=self;
}

- (void)refreshLoanItems
{
    currentResultsPageNo=0;
    currentScrollerAppendPosition=0;
    [self updateLoanItems];
    [itemScroller setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)tabBarControllerSelected:(id)newController
{
	if (newController==self) {
		//[self checkForUpdate];
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
    if ([LibraryAuthenticationManager instance].loansListNeedsReload
        || [[LibraryXmlRpcClient instance] isRefreshNeeded]
        || time_since>LIBRARY_GENERAL_DATA_REFRESH_TIMEOUT_SECONDS) {
        
        [self refreshLoanItems];
    }
}

-(void)authenticationFailed {
}

- (void)authenticationSucceeded
{
	loadingIndicator.hidden = NO;
	[loadingIndicator startAnimating];
	[[LibraryXmlRpcClient instance] getLoans:LIBRARY_GETLOANS_RESULTS_PER_PAGE 
								  offSet:currentResultsPageNo * LIBRARY_GETLOANS_RESULTS_PER_PAGE
								delegate:self];
    patronName.text = [LibraryAuthenticationManager instance].patronName;
    
}

- (void)updateLoanItems 
{
	loadingIndicator.hidden = NO;
	[loadingIndicator startAnimating];
	headLine.text = @"Mine lån";
	
	if (currentResultsPageNo==0) {
		if (loanItems != nil) {
			for (LoanItem* olditem in loanItems) {
				[olditem.view removeFromSuperview];
				olditem.superViewController = nil;
			}
			[loanItems removeAllObjects];
			loanItems = nil;
		}
		loanItems = [NSMutableArray new];
        currentScrollerAppendPosition=0;
	}
    
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

    [[LibraryAuthenticationManager instance] checkAuthenticationNeeded:self inNavigationController:self];
}


- (IBAction)renewAllLoans:(id)sender
{
	[self showBlackCover];
	self.renewAllButton.enabled = NO;
	
	/* old code using renewLoan
	NSMutableArray* loans = [NSMutableArray new];
	
	for (LoanItem* item in loanItems) {
		[loans addObject:item.loanID];
	}
	*/
	[[LibraryXmlRpcClient instance] renewAllLoans:self];
}

- (void)renewLoan:(NSString*)loanID
{
	[self showBlackCover];
	NSArray* loans = [NSArray arrayWithObject:loanID];
	[[LibraryXmlRpcClient instance] renewLoan:loans delegate:self];
}

- (IBAction)getMoreResults:(id)sender
{
	[self.loadingIndicator setCenter:self.moreButton.center];
	
	self.moreButton.enabled = NO; //prevent multiple clicks
	self.moreButton.hidden = YES;

	currentResultsPageNo++;
	[self updateLoanItems];
	//[itemScroller setContentOffset:CGPointMake(0, 0)];

}

- (void)showBlackCover
{
	if (!showingBlackCover) {
		showingBlackCover=true;
		[self.view bringSubviewToFront:blackCoverView];
		blackCoverView.hidden=NO;
		blackCoverView.layer.opacity = 0.0;
		[UIView animateWithDuration:0.5 animations:^{ blackCoverView.layer.opacity = 0.5; } ];
	}
}

- (void)hideBlackCover
{
	if (showingBlackCover) {
		showingBlackCover=false;
		blackCoverView.layer.opacity = 0.5;
		[UIView animateWithDuration:0.5 animations:^{ blackCoverView.layer.opacity = 0.0; } completion:^(BOOL hidden){ blackCoverView.hidden=YES; } ];
	}
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
	[[BibSearchSingleton instance] somewhereElseClicked:self];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DLog(@"didReceiveMemoryWarning");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;

    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

	self.itemScroller = nil;
	self.headLine = nil;
	self.renewAllButton = nil;
	self.loadingIndicator = nil;
	self.moreButton = nil;
	self.blackCoverView = nil;
    self.patronName = nil;
	//self.lastDataRefreshTimestamp = nil;
	DLog(@"viewDidUnload");
}


- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

	
	[loanItems removeAllObjects];
	
	DLog(@"dealloced");
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
		
		if ([[request method] isEqualToString:@"renewLoan"] || [[request method] isEqualToString:@"renewAllLoans"]) { 
			
			//DLog(@"recv. response to renewLoan");
			[LibraryAuthenticationManager instance].loansListNeedsReload = true;
			self.renewAllButton.enabled=YES;
			NSDictionary* dict = [response object];
			NSDictionary* renewalresult = [dict objectForKey:@"data"];
			
			NSDictionary *obj_result = nil;
			NSString *last_error = nil;
			NSEnumerator *enumerator = [renewalresult objectEnumerator];
			int total_count=0;
			int success_count=0;
			while (obj_result = [enumerator nextObject])
			{
				total_count++;
				//if ([obj_result isEqualToString:@"ok"]) {
                if ([[obj_result objectForKey:@"result"] intValue]==1) { //NB: new for 1.1
					success_count++;
				} else {
					last_error=[obj_result objectForKey:@"message"];
				}

			}
			NSString* user_headline = total_count>1 ? @"Forny alle lån" : @"Forny lån";
			if (total_count>0) {
				NSString* usermessage;
				if (success_count==0 && total_count==1) {
					user_headline = @"Kunne ikke forny lån";
					//some error encountered during renewal of 1 loan, we can assume that the result is still in obj_result
					if (last_error==nil) {
						last_error=@"";
					}
					if ([last_error isEqualToString:@"maxNofRenewals"]) {
						usermessage = @"Dit lån kunne ikke fornyes flere gange.";
					} else {
						usermessage = @"Dit lån kunne ikke fornyes.";
					}
				} else if (success_count==0) {
					user_headline = @"Kunne ikke forny lån";
					usermessage = @"Ingen af dine lån kunne fornyes.";
				} else if (success_count==1 && total_count==1) {
					usermessage = @"Dit lån blev fornyet.";
				} else if (success_count==total_count) {
					usermessage = @"Alle dine lån blev fornyede.";
				} else {
					usermessage = [NSString stringWithFormat:@"Kun %d af dine %d lån blev fornyede",success_count,total_count];
				}

				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:user_headline
																message:usermessage
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
				[self hideBlackCover];
                
                if (success_count>0) {
                    [self refreshLoanItems];
                }

			}
			
		} else if ([[request method] isEqualToString:@"getLoans"]) { 
			
			loadingIndicator.hidden = YES;
			[loadingIndicator stopAnimating];

			NSDictionary* dict = [[response object] objectForKey:@"data"];
			id abstract_results = [dict objectForKey:@"data"];
			NSArray* results = nil;
			if ([abstract_results isKindOfClass:[NSDictionary class]]) {
				NSLog(@"WARNING: received unordered associative array for loans");
				results = [abstract_results allObjects];
			} else {
				NSAssert([abstract_results isKindOfClass:[NSArray class]], @"results from ws should be either array or dictionary");
				results = abstract_results;
			}


			BOOL moreresults = [[dict objectForKey:@"more"] intValue];
			
			int y = currentScrollerAppendPosition;
			if (y<59) { //was: 49
				y = 59; //skip headline
			}
			int w=320;
			int h=79;
			int numitems = [[dict objectForKey:@"totalCount"] intValue]; //was: [results count];
			
			if (numitems>0) {
				[renewAllButton setEnabled:YES];
			} else {
				[renewAllButton setEnabled:NO];
			}
			
			int localindex = 0;
			
			for (NSDictionary* subdict in results) {
				LoanItem* newitem = [[LoanItem alloc] initWithNibName:@"LoanItem" bundle:nil];
				newitem.superViewController = self;
				[loanItems addObject:newitem];
				CGRect itemframe = CGRectMake(0,y,w,h);
				[newitem.view setFrame:itemframe];
				[itemScroller addSubview:newitem.view];
				y += h;
				
				newitem.catalogID = [subdict objectForKey:@"catalogueRecordId"];
				newitem.loanID = [subdict objectForKey:@"loanId"];
				
				NSString* thetitle = [subdict objectForKey:@"title"];
				newitem.bookTitle.text = [thetitle length]==0 ? @"(Titel mangler)" : thetitle;
				newitem.bookAuthor.text = [subdict objectForKey:@"author"];
				
				NSDate* expdate = [[NSDate alloc] initWithTimeIntervalSince1970:[[subdict objectForKey:@"loanDueDate"] intValue]];
				NSDateFormatter *dateFormat_out = [[NSDateFormatter alloc] init];
				[dateFormat_out setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"]];
				[dateFormat_out setDateFormat:@"d. MMMM yyyy"];
				// Create date string from formatter, using the current date
				[newitem.expireDate setText:[dateFormat_out stringFromDate:expdate]];
				
				if ([expdate timeIntervalSinceNow]<(-60*60*24*3)) 
				{
					[newitem.expireDate setOpaque:YES];
					[newitem.expireDate setBackgroundColor:[UIColor redColor]];
					[newitem.expireDate setTextAlignment:UITextAlignmentCenter];
				}
				newitem.expireDate.hidden = NO;
				newitem.renewButton.enabled = [[subdict objectForKey:@"loanIsRenewable"] intValue];
				
				newitem.view.layer.opacity = 0.0;
				[UIView animateWithDuration:0.15 
									  delay:0.05*localindex
									options:UIViewAnimationOptionAllowUserInteraction 
								 animations:^{ newitem.view.layer.opacity=1.0; } 
								 completion:nil];
				
				
				localindex++;
			}
			
			currentScrollerAppendPosition = y;
			
			y += 5;
			
			if (moreresults) {
				CGRect button_frame = self.moreButton.frame;
				y += 10;
				button_frame.origin.y = y;
				self.moreButton.frame = button_frame;
				self.moreButton.hidden = NO;
				self.moreButton.enabled = YES;
				y += button_frame.size.height + 15;
			} else {
				self.moreButton.hidden =YES;
			}
			
			[itemScroller setContentSize:CGSizeMake(w, y)];
			[headLine setText:[NSString stringWithFormat:@"Mine lån (%d)",numitems]];
			[LibraryAuthenticationManager instance].loansListNeedsReload = false;
			self.lastDataRefreshTimestamp = [NSDate date];
		}
	}
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
	[LibraryAuthenticationManager instance].loansListNeedsReload = true;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Netværksfejl"
													message:@"Problemer med at kontakte serveren."
												   delegate:self cancelButtonTitle:@"Afbryd" otherButtonTitles:@"Prøv igen",nil];
	[alert show];	
	[self hideBlackCover];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//DLog(@"button index %d",buttonIndex);
	if (buttonIndex==1) {
		//user clicked retry
		[self refreshLoanItems];
	}
}

/*
Renew loan request response:
{
    data =     {
        3449503901 = "Maximum number of renewals reached";
        3450185220 = "Maximum number of renewals reached";
        4192542028 = "Maximum number of renewals reached";
    };
    message = OK;
    result = 1;
}
*/


@end
