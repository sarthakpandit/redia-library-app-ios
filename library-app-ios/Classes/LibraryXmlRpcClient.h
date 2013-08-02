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


#import <Foundation/Foundation.h>
#import "XMLRPCConnectionDelegate.h"
#import "XMLRPCConnectionManager.h"
#import "AbstractXMLRPCClient.h"

#define LIBRARY_GENERAL_DATA_REFRESH_TIMEOUT_SECONDS (1*60*60)

@interface LibraryXmlRpcClient : AbstractXMLRPCClient {

    NSString* wsCustomerId;
    NSString* wsApiKey;
	BOOL authenticated;
	
	NSDate* lastLoginTimestamp;
    
}

@property (nonatomic) BOOL authenticated;
@property (nonatomic, copy) NSString* wsCustomerId;
@property (nonatomic, copy) NSString* wsApiKey;
@property (nonatomic, strong) NSDate* lastLoginTimestamp;

//Get the singleton
+ (LibraryXmlRpcClient*) instance;

- (NSString*)isSupported:(id<XMLRPCConnectionDelegate>)delegate;

- (NSString*)search:(NSString*)searchString maxItems:(int)maxItems offset:(int)offset typeFilter:(NSString*)typeFilter delegate:(id <XMLRPCConnectionDelegate>) d;
- (NSString*)getCoverUrl:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>) d;
- (NSString*)getObject:(NSString*)obj_id delegate:(id <XMLRPCConnectionDelegate>) d;
- (NSString*)getObjectExtras:(NSArray*)obj_ids delegate:(id <XMLRPCConnectionDelegate>) d;


- (NSString*)authenticate:(NSString*)user password:(NSString*)password  delegate:(id <XMLRPCConnectionDelegate>)d;
- (NSString*)addReservation:(NSString*)resourceId pickupBranch:(NSString*)pickupBranch  delegate:(id <XMLRPCConnectionDelegate>)d;
- (NSString*)removeReservation:(NSString*)reservationId delegate:(id <XMLRPCConnectionDelegate>)d;

- (NSString*)getReservationBranches:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getReservations:(int)maxItems offSet:(int)offSet delegate:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getLoans:(int)maxItems offSet:(int)offSet delegate:(id <XMLRPCConnectionDelegate>)delegate;

- (NSString*)renewLoan:(NSArray*)loanIDs delegate:(id <XMLRPCConnectionDelegate>)d;
- (NSString*)renewAllLoans:(id <XMLRPCConnectionDelegate>)d;

- (NSString*)getOpeningHoursHTML:(NSString*)library delegate:(id <XMLRPCConnectionDelegate>)d;
- (NSString*)getLibraryListHTML:(id <XMLRPCConnectionDelegate>)d;

- (NSString*)deauthenticate:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getOverdueLoans:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getReadyReservations:(id <XMLRPCConnectionDelegate>)delegate;

- (NSString*)testXMLRPCConnection:(id <XMLRPCConnectionDelegate>)d;

- (NSString*)getObjectExternals:(NSArray*)ids externalsKeys:(NSArray*)externalsKeys delegate:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getObjectHasExternals:(NSArray*)ids externalsKeys:(NSArray*)externalsKeys delegate:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getObjectIdByBarcodeId:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>)delegate;
- (NSString*)getObjectByBarcodeId:(NSArray*)ids delegate:(id <XMLRPCConnectionDelegate>)delegate;

- (void)updateLastLoginTimestamp;
- (BOOL)isReauthenticationNeeded;

- (BOOL)isValidSuccessArray:(NSDictionary*)dict;
- (BOOL)isValidFailureArray:(NSDictionary*)dict;

@end
