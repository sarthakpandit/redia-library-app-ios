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


#import "AddReservationView.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "NSString+LibUtils.h"
#import "LibraryXmlRpcClient.h"
#import "defines.h"
#import "LibraryAuthenticationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "LibraryAppSetttings.h"



@implementation AddReservationView

@synthesize reservationId;
@synthesize title;

-(void)checkForUpdate{
}

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

+ (AddReservationView*)requestReservation:(NSString*)reservationId withTitle:(NSString*)titl delegate:(id<AddReservationViewDelegate>)aDelegate inNavigationController:(UINavigationController*)navController
{
   
    if (reservationId==nil || [reservationId length]==0) {
		ALog(@"ERROR: SearchResultsView addReservation with empty reservationId");
		return nil; //some internal error - silently fail 
	}
    
    AddReservationView* res = [[AddReservationView alloc] initWithNibName:@"AddReservationView" bundle:nil];
    res.reservationId = reservationId;
    res.title=titl;
    res->delegate = aDelegate;
    
    [[LibraryAuthenticationManager instance] checkAuthenticationNeeded:res inNavigationController:navController];
    
    return res;
}

-(void)authenticationFailed {
    [self finishUp:self];
}


- (void)authenticationSucceeded
{
    if (reservationId==nil || [reservationId length]==0) {
		ALog(@"ERROR: SearchResultsView addReservation with empty reservationId after authenticationSucceeded");
		return; //some internal error - silently fail 
	}
    
   
    
    LibraryAuthenticationManager* auth = [LibraryAuthenticationManager instance];
    if (auth.preferredReservationBranchID!=nil && [auth.preferredReservationBranchID length]>0) {
        UIView* otherview = [[UIApplication sharedApplication] keyWindow];
        CGRect otherframe = CGRectMake(0, 18, 320, 460);
        
        [otherview addSubview:self.view];
        self.view.frame = otherframe;
        
        self.view.hidden=NO;
        self.view.layer.opacity=0.0;
        [UIView animateWithDuration:0.5 
                         animations:^{
                             self.view.layer.opacity=0.5;
                         }
         ];

        NSDictionary* branch_dict = auth.reservationBranches;
        NSString* branchname = [branch_dict objectForKey:auth.preferredReservationBranchID];
        DLog(@"pref branch id: %@, name: %@", auth.preferredReservationBranchID, branchname);
        if (branchname==nil) {
            NSLog(@"ERROR: branchname for id %@ was nil", auth.preferredReservationBranchID);
            branchname=@"dit bibliotek";
        }
        
        NSString* mat_desc = @"dette materiale";
        if (self.title!=nil && [self.title length]>0) {
            int maxlen = 70;
            if ([self.title length]>maxlen) {
                NSRange caplen = NSMakeRange(maxlen, [self.title length]-maxlen);
                self.title = [self.title stringByReplacingCharactersInRange:caplen withString:@"…"];
            }
            mat_desc = [NSString stringWithFormat:@"materialet '%@'",self.title];
        }
        
        NSString* msg = [NSString stringWithFormat:@"Godkend reservering af %@\nAfhentningssted: %@",mat_desc,branchname];
        reservationDialog = [[UIAlertView alloc] initWithTitle:@"Reservér" 
                                                       message:msg
                                                      delegate:self cancelButtonTitle:@"Afbryd" otherButtonTitles:@"OK",nil];
        [reservationDialog show];	
    } else {
        NSString* liburl = [[LibraryAppSetttings instance] getLibraryHomepage];
        if (liburl==nil || [liburl length]==0) {
            liburl=@"bibliotekets hjemmeside";
        }
        noPreferredBranchDialog = [[UIAlertView alloc] initWithTitle:@"Problemer med reserveringen" 
                                                             message:
                                   [NSString stringWithFormat:
                                    @"Der er ikke angivet et foretrukket afhentningssted for reserveringer, og det er derfor ikke muligt at gennemføre din reservation i denne app. Log venligst ind på %@ og vælg dit foretrukne afhentningssted, eller kontakt dit bibliotek.",
                                    liburl]
                                                            delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noPreferredBranchDialog show];	
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (reservationDialog!=nil && reservationDialog==alertView) {
        if (buttonIndex==1) {
            DLog(@"reserving faust number %@",reservationId);
            [[LibraryXmlRpcClient instance] addReservation:reservationId pickupBranch:[LibraryAuthenticationManager instance].preferredReservationBranchID delegate:self];
            [LibraryAuthenticationManager instance].reservationsListNeedsReload = true;
            
            /*
            UIView* otherview = [[UIApplication sharedApplication] keyWindow];
            CGRect otherframe = CGRectMake(0, 18, 320, 460);
            
            [otherview addSubview:self.view];
            self.view.frame = otherframe;

            self.view.hidden=NO;
            self.view.layer.opacity=0.0;
            [UIView animateWithDuration:0.5 
                             animations:^{
                                 self.view.layer.opacity=0.5;
                             }
             ];
             */
        } else {
            [self finishUp:self];
        }
        
        
        reservationDialog=nil;
    } else if (noPreferredBranchDialog!=nil && noPreferredBranchDialog==alertView) {
        noPreferredBranchDialog=nil;
        [self finishUp:self];
        NSString* liburl = [[LibraryAppSetttings instance] getLibraryHomepage];
        if (liburl!=nil && [liburl length]>0) {
            if (![[liburl substringToIndex:4] isEqualToString:@"http"]) {
                liburl = [NSString stringWithFormat:@"http://%@",liburl];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:liburl]];
        }

    }
    
}


- (void)tabBarControllerSelected:(id)newController
{
    
}

-(void)finishUp:(id)sender
{
    
    if ([self isViewLoaded]) {
        [self.view removeFromSuperview];
    }
     
    [delegate addReservationViewDismissed:self];
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
}

- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


/*  ------------------------------------------------------
 XMLRPC
 ------------------------------------------------------
 */


- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	DLog(@"Response for request method: %@", [request method]);
	if ([response isFault]) {
		NSLog(@"Fault code: %@", [response faultCode]);
		
		NSLog(@"Fault string: %@", [response faultString]);
	} else {
		DLog(@"Parsed response for method %@: %@",[request method], [response object]);
		//NSLog(@"xml: %@", [response body]);
        if ([[request method] isEqualToString:@"addReservation"]) { 
			NSDictionary* dict = [response object];
			int resultcode = [[dict objectForKey:@"result"] integerValue];
			NSString* message = [dict objectForKey:@"message"];
			if (resultcode==0) {
				ALog("%@",message);
				if ([NSString isContained:@"reservationPatronBlocked" inString:message]) {
                    if ([NSString isContained:@"blockedBorrCard" inString:message]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problemer med reserveringen" 
                                                                        message:@"Dit lånerkort er spærret for reserveringer. Kontakt venligst dit bibliotek."
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];	
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problemer med reserveringen" 
                                                                        message:@"Din konto er spærret for yderligere reserveringer. Kontakt venligst dit bibliotek."
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alert show];	
                    }
				} else if ([NSString isContained:@"reservationAlreadyReserved" inString:message]) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Materialet er allerede reserveret" 
																	message:@"Du har allerede reserveret dette materiale. Kig i din reserveringsliste og se om det er klar til afhentning."
																   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
					[alert show];	
				} 
				else {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problemer med reserveringen" 
																	message:@"Reserveringen kunne desværre ikke gennemføres. Prøv med et andet materiale, eller kontakt dit bibliotek."
																   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
					[alert show];	
				}
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
																message:@"Reserveringen blev gennemført."
															   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];	
			}
            
            [UIView animateWithDuration:0.5 
							 animations:^{
								 self.view.layer.opacity=0.0;
							 } 
							 completion:^(BOOL b){
								 //self.view.hidden=YES;
                                 [self finishUp:self];
							 }
			 ];
            
        }
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"request method %@: didFailWithError: %@",[request method], error);
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"request method %@: didReceiveAuthenticationChallenge",[request method]);
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"request method %@: didCancelAuthenticationChallenge",[request method]);
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}



@end
