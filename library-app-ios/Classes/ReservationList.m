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


#import "ReservationList.h"
#import "ReservationItem.h"
#import "MainBibSearch.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import "defines.h"
#import <QuartzCore/QuartzCore.h>
#import "BibSearchSingleton.h"

@implementation ReservationList

#define LIBRARY_GETRESERVATIONS_RESULTS_PER_PAGE (15)

@synthesize itemScroller;
@synthesize headLine;
@synthesize loadingIndicator;
@synthesize moreButton;
@synthesize lastDataRefreshTimestamp;
@synthesize editButton;
@synthesize editOkButton;
@synthesize patronName;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        self.lastDataRefreshTimestamp = [NSDate distantPast];

    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.itemScroller addGestureRecognizer:gest];
	
	reservationItems = nil;
	
	//[self updateReservationItems];
	currentResultsPageNo=0;
	currentScrollerAppendPosition=0;
	currentResultCount = 0;
	
	showingDeleteButtons=false;

    self.navigationController.delegate = self;
}

- (void)refreshReservationItems 
{
    currentResultsPageNo=0;
    currentScrollerAppendPosition=0;
    [self updateReservationItems];

}

- (void)tabBarControllerSelected:(id)newController
{
	if (newController==self) {
		[self hideDeleteButtons:NO];
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
    [self hideDeleteButtons:NO];
    [self checkForUpdate];
}

-(void)checkForUpdate
{
    NSTimeInterval time_since = -[lastDataRefreshTimestamp timeIntervalSinceNow];
    if ([LibraryAuthenticationManager instance].reservationsListNeedsReload
        || [[LibraryXmlRpcClient instance] isRefreshNeeded]
        || time_since>LIBRARY_GENERAL_DATA_REFRESH_TIMEOUT_SECONDS) {
        
        [self refreshReservationItems];
    }

}

-(void)authenticationFailed {
}

- (void)authenticationSucceeded
{
	[[LibraryXmlRpcClient instance] getReservations:LIBRARY_GETRESERVATIONS_RESULTS_PER_PAGE 
								  offSet:currentResultsPageNo * LIBRARY_GETRESERVATIONS_RESULTS_PER_PAGE
								delegate:self];
    patronName.text = [LibraryAuthenticationManager instance].patronName;

}

- (void)updateReservationItems 
{
	
	loadingIndicator.hidden = NO;
	[loadingIndicator startAnimating];
	headLine.text = @"Reserveringer";
	currentResultCount = 0;
	
	if (currentResultsPageNo==0) {
        //reset all
        [self hideDeleteButtons:NO];
        editButton.hidden = YES;
        editOkButton.hidden = YES;

		loadingIndicator.frame = CGRectMake(290, 14, 20, 20);
		
		//only delete items when requesting the first page
		if (reservationItems != nil) {
			for (ReservationItem* olditem in reservationItems) {
				[olditem.view removeFromSuperview];
				olditem.superViewController = nil;
			}
			[reservationItems removeAllObjects];
			reservationItems=nil;
		}
		reservationItems = [NSMutableArray new];
		[itemScroller setContentOffset:CGPointMake(0, 0)];
        currentScrollerAppendPosition=0;
	}

    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
	[[LibraryAuthenticationManager instance] checkAuthenticationNeeded:self inNavigationController:self.navigationController];
	
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
	[[BibSearchSingleton instance] somewhereElseClicked:self];
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

	self.itemScroller = nil;
	self.headLine = nil;
	self.loadingIndicator = nil;
	self.moreButton = nil;
	self.lastDataRefreshTimestamp = nil;
    self.patronName = nil;
	DLog(@"viewDidUnload");
}


- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

	[reservationItems removeAllObjects];
	
    
	DLog(@"dealloced");
}

- (IBAction)toggleDeleteButtons:(id)sender
{
	if (!showingDeleteButtons) {
		[self showDeleteButtons];
	}
	else {
		[self hideDeleteButtons:YES];
	}
}

- (void)showDeleteButtons
{
	if (!showingDeleteButtons) {
		showingDeleteButtons=true;
		
		editButton.hidden=YES;
		editOkButton.hidden=NO;
		
		for (ReservationItem* item in reservationItems) {
			[item showDelete];
		}
	}
}

- (void)hideDeleteButtons:(BOOL)animated
{
	if (showingDeleteButtons) {
		showingDeleteButtons=false;
		
		editButton.hidden=NO;
		editOkButton.hidden=YES;
		
		if (reservationItems!=nil) {
			for (ReservationItem* item in reservationItems) {
				[item hideDelete:animated];
			}
		}
	}
}

- (void)deleteReservationSucceeded:(ReservationItem*)sender
{
	if (sender!=nil) {
		[LibraryAuthenticationManager instance].reservationsListNeedsReload = true;

		CGRect curframe = sender.view.frame;
		int adjustheight = curframe.size.height;
		
		[UIView animateWithDuration:0.6 
						 animations:^{
							 sender.view.layer.opacity=0.0;
							 sender.view.layer.position = CGPointMake(sender.view.layer.position.x-320, sender.view.layer.position.y);
							 
							 bool itemfound = false;
							 for (ReservationItem* item in reservationItems) {
								 if (itemfound) {
									 item.view.layer.position = CGPointMake(item.view.layer.position.x, item.view.layer.position.y-adjustheight) ;
								 }
								 if (item==sender) {
									 itemfound = true;
								 }
							 }
							 currentScrollerAppendPosition -= adjustheight;
							 moreButton.layer.position = CGPointMake(moreButton.layer.position.x, moreButton.layer.position.y-adjustheight);
						 }
						 completion:^(BOOL c) {
							 [sender.view removeFromSuperview];
							 sender.superViewController=nil;
							 [reservationItems removeObject:sender];
							 currentResultCount--;
							 [headLine setText:[NSString stringWithFormat:@"Reserveringer (%d)",currentResultCount]];
                             [moreButton setTitle:@"Genindlæs alle..." forState:UIControlStateNormal];
						 }
		 ];
		
	}
}


- (IBAction)getMoreResults:(id)sender
{
	[self.loadingIndicator setCenter:self.moreButton.center];

	self.moreButton.enabled = NO; //prevent multiple clicks
	self.moreButton.hidden = YES;
	if (![LibraryAuthenticationManager instance].reservationsListNeedsReload) {
		currentResultsPageNo++;
	} else {
		currentResultsPageNo=0;
		currentScrollerAppendPosition=0;
        [itemScroller setContentOffset:CGPointMake(0, 0) animated:NO];
	}

	[self updateReservationItems];
	//[itemScroller setContentOffset:CGPointMake(0, 0)];

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
		
		
		if ([[request method] isEqualToString:@"getReservations"]) { 
			
			if ([response object]==nil || [[[response object] objectForKey:@"result"] intValue]!=1) {
				[self handleLoadError];
				return;
			}
			
			loadingIndicator.hidden = YES;
			[loadingIndicator stopAnimating];
			
			NSDictionary* dict = [[response object] objectForKey:@"data"];
			id abstract_results = [dict objectForKey:@"data"];
			NSArray* results = nil;
			if ([abstract_results isKindOfClass:[NSDictionary class]]) {
				NSLog(@"WARNING: received unordered associative array for reservations");
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
			int h=112;
			currentResultCount = [[dict objectForKey:@"totalCount"] intValue]; //was: [results count];
			
			//NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"hasPickupExpireDate" ascending:NO];
			//results = [results sortedArrayUsingDescriptors:[NSMutableArray arrayWithObjects:descriptor,nil]];
			
			int localindex = 0;
			
			for (NSDictionary* subdict in results) {
				ReservationItem* newitem = [[ReservationItem alloc] initWithNibName:@"ReservationItem" bundle:nil];
				newitem.superViewController = self;
				[reservationItems addObject:newitem];
				CGRect itemframe = CGRectMake(0,y,w,h);
				[newitem.view setFrame:itemframe];
				[itemScroller addSubview:newitem.view];
				y += h;
				
				newitem.catalogID = [subdict objectForKey:@"catalogueRecordId"];
				newitem.reservationID = [subdict objectForKey:@"reservationId"];
				
				if (showingDeleteButtons) {
					[newitem showDelete];
				}
				
				NSString* thetitle = [subdict objectForKey:@"title"];
				newitem.bookTitle.text = [thetitle length]==0 ? @"(Titel mangler)" : thetitle;
				newitem.bookAuthor.text = [subdict objectForKey:@"author"];
				
				// pickup date
				int has_pickup = [[subdict objectForKey:@"hasPickupExpireDate"] intValue];
				
				if (has_pickup) {
					newitem.expireDate.hidden = FALSE;
					newitem.pickupLabel.hidden = FALSE;
					newitem.queueNumber.hidden = TRUE;
					
                    NSString* pickupid = [subdict objectForKey:@"reservationPickUpBranch"];
                    if (pickupid!=nil && [pickupid length]>0) {
                        NSString* pickupname = [[LibraryAuthenticationManager instance].reservationBranches objectForKey:pickupid];
                        if (pickupname!=nil && [pickupname length]>0) {
                            newitem.pickupBranchLabel.hidden=NO;
                            newitem.pickupBranchLabel.text=[NSString stringWithFormat:@"Til afhentning på %@",pickupname];
                        }
                    }
                    
                    NSString* has_selfservice_num = [subdict objectForKey:@"hasSelfServicePickUpNo"];
                    if (has_selfservice_num!=nil && [has_selfservice_num integerValue]>0) {
                        NSString* selfservice_num = [subdict objectForKey:@"selfServicePickUpNo"];
                        if (selfservice_num!=nil && [selfservice_num length]>0) {
                            newitem.pickupSelfServiceNumber.hidden=NO;
                            newitem.pickupSelfServiceNumber.text=[NSString stringWithFormat:@"Reserveringsnummer: %@",selfservice_num];
                        }
                    }
                    
					NSDate* expdate = [[NSDate alloc] initWithTimeIntervalSince1970:[[subdict objectForKey:@"pickupExpireDate"] intValue]];
					NSDateFormatter *dateFormat_out = [[NSDateFormatter alloc] init];
					[dateFormat_out setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"]];
					[dateFormat_out setDateFormat:@"d. MMMM yyyy"];
					// Create date string from formatter, using the current date
					[newitem.expireDate setText:[dateFormat_out stringFromDate:expdate]];
					
					[newitem.expireDate setOpaque:YES];
					[newitem.expireDate setBackgroundColor:[UIColor colorWithRed:0 green:0.45 blue:0 alpha:1]];
					[newitem.expireDate setTextAlignment:UITextAlignmentCenter];
					
					
				} else {
					int has_queue = [[subdict objectForKey:@"hasQueueNo"] intValue];
					if (has_queue) {
						newitem.expireDate.hidden = TRUE;
						newitem.pickupLabel.hidden = TRUE;
						newitem.queueNumber.hidden = FALSE;
						
						int queue_no = [[subdict objectForKey:@"queueNo"] intValue];
						[newitem.queueNumber setText:[NSString stringWithFormat:@"Du står i kø som nummer: %d",queue_no]];
					}
				}

				newitem.view.layer.opacity = 0.0;
				[UIView animateWithDuration:0.15 
									  delay:0.05*localindex
									options:UIViewAnimationOptionAllowUserInteraction 
								 animations:^{ newitem.view.layer.opacity=1.0; } 
								 completion:nil];
				//newitem.renewButton.enabled = [[subdict objectForKey:@"loanIsRenewable"] intValue];
				
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
                [self.moreButton setTitle:@"Flere..." forState:UIControlStateNormal];
			} else {
				self.moreButton.hidden =YES;
			}
			
			
			[itemScroller setContentSize:CGSizeMake(w, y)];
			[headLine setText:[NSString stringWithFormat:@"Reserveringer (%d)",currentResultCount]];
			self.editButton.hidden = NO;
			self.editOkButton.hidden = YES;
			[LibraryAuthenticationManager instance].reservationsListNeedsReload=false;
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

- (void)handleLoadError
{
	[self hideDeleteButtons:YES];
	[LibraryAuthenticationManager instance].reservationsListNeedsReload = true;
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
		[self updateReservationItems];
	}
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}


@end
