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


#import "LibraryAuthenticationManager.h"
#import <QuartzCore/CALayer.h>
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "defines.h"
#import "SearchResultsView.h"
#import "Keychain.h"
#import "LibraryAppSetttings.h"

@implementation LibraryAuthenticationManager

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize loginButton;
@synthesize cancelButton;
@synthesize loginIndicator;
@synthesize isShowingAuthenticationDialog;
@synthesize reservationBranches;
@synthesize appTabBar;
@synthesize reservationsListNeedsReload;
@synthesize loansListNeedsReload;
@synthesize openingHoursNeedsReload;
@synthesize preferredReservationBranchID;
@synthesize rememberLogin;
@synthesize patronName;
@synthesize backButton;

static LibraryAuthenticationManager *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        
        //NB:LibraryAppSetttings must not depend on LibraryAuthenticationManager in initialization
        NSString* tempdefaultAccountKey = [[NSString alloc] initWithFormat:@"defaultAccount-%@", [[LibraryAppSetttings instance] getCustomerId]];
        NSString* tempdefaultRememberPasswordKey = [[NSString alloc] initWithFormat:@"rememberPassword-%@", [[LibraryAppSetttings instance] getCustomerId]];
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *appDefaults = [NSDictionary
									 dictionaryWithObjectsAndKeys:@"", tempdefaultAccountKey,
									 @"false", tempdefaultRememberPasswordKey,
									 nil];
		[defaults registerDefaults:appDefaults];
		
        sharedSingleton = [[LibraryAuthenticationManager alloc] initWithNibName:nil bundle:nil];
        
        sharedSingleton->defaultAccountKey=tempdefaultAccountKey;
        sharedSingleton->defaultRememberPasswordKey=tempdefaultRememberPasswordKey;

        sharedSingleton->reservationBranches = [NSMutableDictionary new];
        
        /* old code, only works for KKB
        sharedSingleton->reservationBranches = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                @"HB", @"Hovedbiblioteket",
                                                @"bi", @"Bispebjerg",
                                                @"bl~aa", @"Blågården",
                                                @"brh", @"Brønshøj",
                                                @"bro", @"Bibliotekshuset",
                                                @"bry", @"Islands Brygge",
                                                @"ch", @"Christianshavn",
                                                @"edb", @"HNG 3. sal/DTA",
                                                @"hu", @"Husum",
                                                @"ja", @"Øbro Jagtvej",
                                                @"n~oe", @"Nørrebro",
                                                @"rhb", @"Rådhusbiblioteket",
                                                @"s", @"Sundby",
                                                @"sr", @"Solvang Centret",
                                                @"syd", @"Sydhavn",
                                                @"tin", @"Tingbjerg",
                                                @"va", @"Valby",
                                                @"van", @"Vanløse",
                                                @"ve", @"Vesterbro",
                                                @"vi", @"Vigerslev",
                                                @"~oe", @"Østerbro",
                                                @"~oern", @"Lærkevej/Ørnevej",
                                                nil];
         */
        
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		sharedSingleton->reservationBranchesCachePath = [[NSString alloc] initWithString:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"reservationBranches.plist"]];
		NSFileManager *filemgr = [[NSFileManager alloc] init];
		if ([filemgr fileExistsAtPath:sharedSingleton->reservationBranchesCachePath]) {
			NSDictionary* valuedict = [NSDictionary dictionaryWithContentsOfFile:sharedSingleton->reservationBranchesCachePath];
			sharedSingleton->reservationBranches = [[valuedict objectForKey:@"branches"] mutableCopyWithZone:nil];
			//moved to NSDefaults: sharedSingleton->preferredReservationBranch = [valuedict objectForKey:@"preferred"];
		}
		
		sharedSingleton->reservationsListNeedsReload = true;
		sharedSingleton->loansListNeedsReload = true;
		
	}
}

+ (LibraryAuthenticationManager*)instance
{
	return sharedSingleton;
}
 
- (void)updateReservationBranches
{
    [[LibraryXmlRpcClient instance] getReservationBranches:self]; //update list of reservation branches
}


- (void)updateAccountTextFields
{
    usernameTextField.text = @"";
    passwordTextField.text = @"";

    NSString* remem_passw = [[NSUserDefaults standardUserDefaults] stringForKey:defaultRememberPasswordKey];
    if ([remem_passw isEqualToString:@"true"]) {

        [rememberLogin setTitle:@"√" forState:UIControlStateNormal];

        NSString* def_account = [[NSUserDefaults standardUserDefaults] stringForKey:defaultAccountKey];
        if (def_account!=nil && [def_account length]>0) {
            usernameTextField.text = def_account;
			NSString* def_passw = [Keychain getStringForKey:def_account];
			if (def_passw!=nil) {
				passwordTextField.text = def_passw;
			}
		} 
	} else {
        [rememberLogin setTitle:@"" forState:UIControlStateNormal];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [self updateAccountTextFields];
    
    [backButton setBackgroundImage:[[backButton backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:30 topCapHeight:0] forState:UIControlStateNormal];

	UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
	gest.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:gest];
}

- (IBAction)rememberLoginButtonClicked:(id)sender
{
	NSString* remem_passw = [[NSUserDefaults standardUserDefaults] stringForKey:defaultRememberPasswordKey];
	if ([remem_passw isEqualToString:@"true"]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"false" forKey:defaultRememberPasswordKey];
		[rememberLogin setTitle:@"" forState:UIControlStateNormal];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:defaultRememberPasswordKey];
		[rememberLogin setTitle:@"√" forState:UIControlStateNormal];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)hideKeyboard:(id)sender
{
	[usernameTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
	
}

- (void)checkRememberPasswordStore
{
	NSString* remem_passw = [[NSUserDefaults standardUserDefaults] stringForKey:defaultRememberPasswordKey];
	if ([usernameTextField.text length]>0) {
		if ([remem_passw isEqualToString:@"true"]) {
            [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:defaultAccountKey];
			[Keychain saveString:passwordTextField.text forKey:usernameTextField.text];
		} else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:defaultAccountKey];
			[Keychain deleteStringForKey:usernameTextField.text];
		}
	}
	
	//hmm? [[NSUserDefaults standardUserDefaults] setObject:@"true" forKey:defaultRememberPasswordKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (IBAction)performLibraryLogin:(id)sender
{
	NSLog(@"dologin");
	
	[self hideKeyboard:sender];
	
    [self checkRememberPasswordStore];
	
	loginButton.enabled = NO;
	//loginButton.alpha = 0.2;
	loginIndicator.hidden = NO;
	[loginIndicator startAnimating];
	[self.view bringSubviewToFront:loginIndicator];
	
	LibraryXmlRpcClient* client = [LibraryXmlRpcClient instance];
	connectionIdentifier = [[client authenticate:usernameTextField.text password:passwordTextField.text delegate:self] copy];
}

- (IBAction)cancelLogin:(id)sender
{
	if (!self.isShowingAuthenticationDialog)
	{
		return;
	}
	if ([connectionIdentifier compare:@""]!=0) {
		LibraryXmlRpcClient* client = [LibraryXmlRpcClient instance];
		[client cancelRequest:connectionIdentifier];
	}
	//CGPoint curpos = self.view.layer.position;
	self.isShowingAuthenticationDialog = false;
    
    [self checkRememberPasswordStore];

    /* was:
	[UIView animateWithDuration:0.4 
					 animations:^{
						 self.view.layer.position = CGPointMake(curpos.x, curpos.y+480);
					 } 
					 completion:^(BOOL b){
                         [self updateAccountTextFields];
						 [self.view removeFromSuperview];
					 }
	 ];
     */
    DLog(@"dismissing");
    [self dismissViewControllerAnimated:YES completion:nil];
	[delegate authenticationFailed];
    
	self.appTabBar.selectedIndex = 0; //go to first tab
}


- (BOOL)checkAuthenticationNeeded:(id<MyTabBarNotificationDelegate>)d inNavigationController:(UIViewController*)presentingController
{
	LibraryXmlRpcClient* client = [LibraryXmlRpcClient instance];
	if ((! [client isReauthenticationNeeded]) && client.authenticated) {
		[d authenticationSucceeded];
		return FALSE;
	} else {
		self.isShowingAuthenticationDialog = true;
		delegate = d;
		
        /*
		UIView* otherview = [[UIApplication sharedApplication] keyWindow];
		CGRect otherframe = CGRectMake(0, 18, 320, 460);
		
		[otherview addSubview:auth.view];
		[otherview bringSubviewToFront:auth.view];
		//CGRect anim_from_frame = otherframe;
		//anim_from_frame.origin.y += 480;
		
		auth.view.frame = otherframe;
		CGPoint curpos = self.view.layer.position;
		auth.view.layer.position = CGPointMake(curpos.x, curpos.y+480);

		[UIView animateWithDuration:0.5 
						 animations:^{
							 auth.view.layer.position = curpos;
						 } 
		 ];*/
        
        UIViewController* actuallyPresenting = presentingController;
        DLog(@"going to present to %@",actuallyPresenting);
        [actuallyPresenting presentViewController:self animated:YES completion:nil];
		
		loginButton.enabled = YES;
		loginButton.alpha = 1.0;
		loginIndicator.hidden = YES;
		[loginIndicator stopAnimating];
		
		return TRUE;
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == usernameTextField) {
		[usernameTextField resignFirstResponder];
		[passwordTextField becomeFirstResponder];
	} else {
		[self performLibraryLogin:self];
	}
	return NO;
}

- (void)reenableButtons 
{
	loginButton.enabled = YES;
	loginIndicator.hidden = YES;
	[loginIndicator stopAnimating];
}

//  ------------------------------------------------------
//  XMLRPC
//  ------------------------------------------------------

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	//[self reenableButtons];
	
	NSLog(@"Response for request method: %@", [request method]);
	if ([response isFault]) {
		NSLog(@"Fault code: %@", [response faultCode]);
		NSLog(@"Fault string: %@", [response faultString]);
        DLog(@"fault response xml: %@", [response body]);
		if ([[request method] isEqualToString:@"authenticate"]) {
			[[[UIAlertView alloc] initWithTitle:@"Netværksfejl" message:@"Kunne ikke logge ind på grund af en intern fejl. Prøv venligst igen senere. [90001]" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
			[self reenableButtons];
		}
	} else {
		DLog(@"Parsed response: %@", [response object]);
		//DLog(@"xml: %@", [response body]);
		
		if ([[request method] isEqualToString:@"getReservationBranches"]) {
			NSDictionary* dict = [response object];
            if (dict!=nil && [dict isKindOfClass:[NSDictionary class]]) {
                NSDictionary* temptempdict = [dict objectForKey:@"data"];
                if (temptempdict!=nil && [temptempdict isKindOfClass:[NSDictionary class]] && [temptempdict count]>0) {
                    NSDictionary* tempdict = [temptempdict objectForKey:@"branches"];
                    if (tempdict!=nil && [tempdict isKindOfClass:[NSDictionary class]] && [tempdict count]>0) {
                        reservationBranches = [[NSMutableDictionary alloc] initWithDictionary:tempdict];
                        
                        NSDictionary* diskdict = [NSDictionary dictionaryWithObjectsAndKeys:reservationBranches,@"branches",
                                                  /* moved to NSDefaults: preferredReservationBranch,@"preferred", */
                                                  nil];
                        //NSFileManager *filemgr = [[NSFileManager alloc] init];
                        if (![diskdict writeToFile:reservationBranchesCachePath atomically:YES]) {
                            NSLog(@"write to cache file error: %@",reservationBranchesCachePath);
                        }
                        
                    } else {
                        NSLog(@"ERROR: reservation branches returned bad dictionary");
                    }
                } else {
                    NSLog(@"ERROR: reservation branches returned really bad dictionary");
                }
            } else {
                NSLog(@"ERROR: didn't receive dictionary");
            }
		} else if ([[request method] isEqualToString:@"authenticate"]) {

			NSDictionary* dict = [response object];
			if (dict==nil || [dict objectForKey:@"result"]==nil) {
				[[[UIAlertView alloc] initWithTitle:@"Netværksfejl" message:@"Kunne ikke logge ind på grund af en intern fejl. Prøv venligst igen senere. [90002]" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
				[self reenableButtons];
			} else {
				int loginresult = [[dict objectForKey:@"result"] intValue];
				if (loginresult==1) {
					[LibraryXmlRpcClient instance].authenticated = YES;
					
					NSString* pref_branch=nil;
					NSString* patron=nil;
					NSDictionary* datadict = [dict objectForKey:@"data"];
					if (datadict!=nil && [datadict isKindOfClass:[NSDictionary class]]) {
						NSDictionary* patrondict = [datadict objectForKey:@"patron"];
						if (patrondict!=nil) {
							pref_branch = [patrondict objectForKey:@"preferredBranch"];
							patron = [patrondict objectForKey:@"name"];
						}
					}
					if (pref_branch==nil) {
						pref_branch=@"";
					}
					self.preferredReservationBranchID = pref_branch;
					if (patron==nil) {
                        patron=@"";
                    }
					self.patronName=patron;
                    

                    DLog(@"dismissing from %@",self.navigationController);
                    //[self performSelector:@selector(dismissViewControllerAnimated:completion:) withObject:self afterDelay:0];
					//[self dismissViewControllerAnimated:YES completion:nil];
                    self.isShowingAuthenticationDialog=false;
                    [self performSelector:@selector(dismissAndSucceed) withObject:nil afterDelay:0];
                    
				} else {
					NSString* message = [dict objectForKey:@"message"];
					if (message!=nil && [message isEqualToString:@"wrongUsernameOrPassword"]) {
						UIAlertView* login_error_alert = [[UIAlertView alloc]initWithTitle:@"Login fejlede" message:@"Kunne ikke logge ind. Der er fejl i lånerkortnr. eller PIN-kode." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
						[login_error_alert show];
					} else {
						[[[UIAlertView alloc] initWithTitle:@"Netværksfejl" message:@"Kunne ikke logge ind på grund af en intern fejl. Prøv venligst igen senere. [90007]" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
					}

					[self reenableButtons];
				}
			}
		}
	}
}

- (void)dismissAndSucceed
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (delegate!=nil) {
        [[LibraryXmlRpcClient instance] updateLastLoginTimestamp];
        [delegate authenticationSucceeded];
    }
}

-(void)dealloc
{
    DLog(@"dealloced");
}


- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didFailWithError: %@", error);
	if ([[request method] isEqualToString:@"authenticate"]) {
		[self reenableButtons];

		[[[UIAlertView alloc] initWithTitle:@"Netværksfejl" message:@"Kunne ikke logge ind på grund af manglende netværksforbindelse. Prøv venligst igen senere. [90003]" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	} else if ([[request method] isEqualToString:@"getReservationBranches"]) {
	}
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didReceiveAuthenticationChallenge");

	if ([[request method] isEqualToString:@"authenticate"]) {
		[self reenableButtons];
		[[[UIAlertView alloc] initWithTitle:@"Netværksfejl" message:@"Kunne ikke logge ind på grund af en intern fejl. Prøv venligst igen senere. [90004]" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didCancelAuthenticationChallenge");
	if ([[request method] isEqualToString:@"authenticate"]) {
		[self reenableButtons];
		[[[UIAlertView alloc] initWithTitle:@"Netværksfejl" message:@"Kunne ikke logge ind på grund af en intern fejl. Prøv venligst igen senere. [90005]" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	}
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}



@end
