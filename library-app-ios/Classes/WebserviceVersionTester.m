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


#import "WebserviceVersionTester.h"
#import "LibraryXmlRpcClient.h"
#import "defines.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"

@implementation WebserviceVersionTester

- (void)checkWebserviceVersion
{
    
    [[LibraryXmlRpcClient instance] isSupported:self];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.apple.com/dk/mac/app-store/"]];
}

-(void)dealloc
{
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
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
	} else {
		DLog(@"Parsed response: %@", [response object]);
		if ([[request method] isEqualToString:@"isSupported"]) { 
            if (![[response object] isKindOfClass:[NSString class]] || ![[response object] isEqualToString:@"supportedOK"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ny version tilgængelig"
                                                                message:@"Denne version af app'en er ikke længere understøttet. Opgradér venligst til den nyeste version via App Store."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];	
            }
            else {
                
            }
		}
	}
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didFailWithError: %@", error);
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didReceiveAuthenticationChallenge");
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"Response for request method: %@", [request method]);
	NSLog(@"didCancelAuthenticationChallenge");
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}


@end
