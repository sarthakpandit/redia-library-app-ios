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


#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnectionManager.h"
#import "XMLRPCResponse.h"
#import "defines.h"
#import "NSString+LibUtils.h"

#define LibraryXmlRpcClient_LOGIN_TIMEOUT (24*60)
#define LibraryXmlRpcClient_DATA_REFRESH_TIMEOUT (1*60*60)

@implementation LibraryXmlRpcClient

@synthesize authenticated;
@synthesize wsCustomerId;
@synthesize wsApiKey;
@synthesize lastLoginTimestamp;

static LibraryXmlRpcClient *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[LibraryXmlRpcClient alloc] init];
    }
}

+ (LibraryXmlRpcClient*)instance
{
	return sharedSingleton;
}

- (id)init 
{
	self = [super init];

	url = [[NSURL alloc] initWithString:REDIA_APP_UNIFIED_LIBRARY_BACKEND_URL]; //production
	
	manager = [XMLRPCConnectionManager sharedManager];

	self.lastLoginTimestamp = [NSDate distantPast];
	
    dataRefreshTimeout = LibraryXmlRpcClient_DATA_REFRESH_TIMEOUT;
    
	return self;
}

- (NSString*)isSupported:(id <XMLRPCConnectionDelegate>) delegate
{
	//[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"isSupported" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;
}

- (NSString*)search:(NSString*)searchString maxItems:(int)maxItems offset:(int)offset typeFilter:(NSString*)typeFilter delegate:(id <XMLRPCConnectionDelegate>)d 
{
	[self updateLastCallTimestamp];
	NSMutableArray *params = [[NSMutableArray alloc] init];
    
    searchString = [searchString escapedToXML];
    
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:searchString]; //query
	[params addObject:[NSString stringWithFormat:@"%d", maxItems]]; //maxItems
	[params addObject:[NSString stringWithFormat:@"%d", offset]]; //offSet
	[params addObject:typeFilter]; //dc_type

	DLog("call search with params %@",params);
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"search" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
}

- (NSString*)getCoverUrl:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>) d
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:ids]; 
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getCoverUrl" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
}


- (NSString*)getObject:(NSString*)obj_id delegate:(id <XMLRPCConnectionDelegate>) d
{
	if (obj_id==nil || [obj_id length]==0) {
		NSLog(@"WARNING: empty object_id");
		return @"";
	}
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:obj_id]; 
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getObject" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
}

- (NSString*)getObjectExtras:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>) d
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:ids]; 
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getObjectExtras" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
}

- (NSString*)authenticate:(NSString*)user password:(NSString*)password  delegate:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];

	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:user]; 
	[params addObject:password];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"authenticate" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
}

- (NSString*)addReservation:(NSString*)resourceId pickupBranch:(NSString*)pickupBranch  delegate:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];
	
	DLog(@"addReservation: id=%@ pickup=%@",resourceId,pickupBranch);
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:resourceId]; 
	[params addObject:pickupBranch];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"addReservation" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;

}

- (NSString*)removeReservation:(NSString*)reservationId delegate:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];
	
	DLog(@"removeReservation: id=%@",reservationId);
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:reservationId]; 
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"removeReservation" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
	
}


- (NSString*)getReservationBranches:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getReservationBranches" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;

}

- (NSString*)getReservations:(int)maxItems offSet:(int)offSet delegate:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:[NSString stringWithFormat:@"%d",maxItems]]; 
	[params addObject:[NSString stringWithFormat:@"%d",offSet]]; 

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getReservations" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;

}

- (NSString*)getLoans:(int)maxItems offSet:(int)offSet delegate:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:[NSString stringWithFormat:@"%d",maxItems]]; 
	[params addObject:[NSString stringWithFormat:@"%d",offSet]]; 
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getLoans" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;

}

- (NSString*)renewLoan:(NSArray*)loanIDs delegate:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];
	
	//DLog(@"renewLoan: %@",loanIDs);
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:loanIDs]; 
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"renewLoan" withParameters: params];
	DLog("%@",[request body]);
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;

}

- (NSString*)renewAllLoans:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];

	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"renewAllLoans" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;

}

- (NSString*)deauthenticate:(id <XMLRPCConnectionDelegate>)delegate
{
	self.lastLoginTimestamp = [NSDate distantPast];

	self.authenticated = FALSE;

	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"deauthenticate" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;

}

- (NSString*)getOverdueLoans:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getOverdueLoans" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;

}

- (NSString*)getReadyReservations:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getReadyReservations" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;

}




- (NSString*)getOpeningHoursHTML:(NSString*)library delegate:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];

    bool is_retina = ([[UIScreen mainScreen] currentMode].size.width >= 320*2);

	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
	[params addObject:[NSArray arrayWithObject:library]];
    [params addObject: is_retina ? @"1" : @"0"];
    
    DLog(@"getOpeningHoursHTML parameters: %@", params)
    
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getOpeningHoursHTML" withParameters: params];
    DLog(@"encoded %@", [request body]);
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;

}

- (NSString*)getLibraryListHTML:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];

    bool is_retina = ([[UIScreen mainScreen] currentMode].size.width >= 320*2);
    DLog(@"%lf %lf", [[UIScreen mainScreen] currentMode].size.width, [[UIScreen mainScreen] currentMode].size.height)
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
    [params addObject: is_retina ? @"1" : @"0"];

	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getLibraryListHTML" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;
}

- (NSString*)testXMLRPCConnection:(id <XMLRPCConnectionDelegate>)d
{
	[self updateLastCallTimestamp];
	
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"theAnswerToEverything" withParameters: nil];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:d];
    [self addRequestIdentifier:newidentifier forDelegate:d];
    return newidentifier;

}

- (NSString*)getObjectExternals:(NSArray*)ids externalsKeys:(NSArray*)externalsKeys delegate:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
    [params addObject:ids];
    [params addObject:externalsKeys];
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getObjectExternals" withParameters: params];
    DLog(@"sending request params for %@: %@",[request method],params);

	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;
    
}

- (NSString*)getObjectHasExternals:(NSArray*)ids externalsKeys:(NSArray*)externalsKeys delegate:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
    [params addObject:ids];
    [params addObject:externalsKeys];
    
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getObjectHasExternals" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;
    
}


- (NSString*)getObjectIdByBarcodeId:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
    [params addObject:ids];
    
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getObjectIdByBarcodeId" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;
    
}


- (NSString*)getObjectByBarcodeId:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>)delegate
{
	[self updateLastCallTimestamp];
	
	NSMutableArray *params = [[NSMutableArray alloc] init];
	[params addObject:self.wsCustomerId];
	[params addObject:self.wsApiKey];
    [params addObject:ids];
    
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithURL: url];
	[request setMethod:@"getObjectByBarcodeId" withParameters: params];
	NSString* newidentifier = [manager spawnConnectionWithXMLRPCRequest:request delegate:delegate];
    [self addRequestIdentifier:newidentifier forDelegate:delegate];
    return newidentifier;
    
}

- (void)updateLastLoginTimestamp
{
	self.lastLoginTimestamp = [NSDate date];
	
}

- (BOOL)isReauthenticationNeeded
{
	NSTimeInterval time_since = -[self.lastLoginTimestamp timeIntervalSinceNow];
	if (time_since>LibraryXmlRpcClient_LOGIN_TIMEOUT) {
		self.authenticated = FALSE;
		return TRUE;
	}
	return FALSE;
}

- (BOOL)isValidSuccessArray:(NSDictionary*)dict
{
    if (dict!=nil) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSNumber* result = [dict objectForKey:@"result"];
            if (result!=nil) {
                if ([result isKindOfClass:[NSNumber class]]) {
                    if ([result boolValue]) {
                        return TRUE;
                    } 
                } else DLog(@"ERROR: 'result' in response without bool type");
            } else DLog(@"ERROR: no 'result' key in response");
        } else DLog(@"ERROR: reponse not a NSDictionary, was: %@", dict);
    } else {
        DLog(@"ERROR: response was nil");
    }
    
    return FALSE;
}

- (BOOL)isValidFailureArray:(NSDictionary*)dict
{
    if (dict!=nil) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSNumber* result = [dict objectForKey:@"result"];
            if (result!=nil) {
                if ([result isKindOfClass:[NSNumber class]]) {
                    if (![result boolValue]) {
                        return TRUE;
                    } 
                } else DLog(@"ERROR: 'result' in response without bool type");
            } else DLog(@"ERROR: no 'result' key in response");
        } else DLog(@"ERROR: reponse not a NSDictionary, was: %@", dict);
    } else {
        DLog(@"ERROR: response was nil");
    }
    
    return FALSE;
}



@end


