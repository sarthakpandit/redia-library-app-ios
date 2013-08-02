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


#import <UIKit/UIKit.h>
#import "libraryappAppDelegate.h"
#import "XMLRPCConnectionDelegate.h"

@protocol AddReservationViewDelegate <NSObject>

-(void)addReservationViewDismissed:(id)sender;

@end


@interface AddReservationView : UIViewController<XMLRPCConnectionDelegate, MyTabBarNotificationDelegate> {
    UIAlertView* reservationDialog;
    UIAlertView* noPreferredBranchDialog;
    
    NSString* reservationId;
    NSString* title;
    id<AddReservationViewDelegate> delegate;
}

@property (nonatomic, copy) NSString* reservationId;
@property (nonatomic, copy) NSString* title;

+ (AddReservationView*)requestReservation:(NSString*)reservationId withTitle:(NSString*)titl delegate:(id<AddReservationViewDelegate>)aDelegate inNavigationController:(UINavigationController*)navController;


- (void)tabBarControllerSelected:(id)newController;
- (void)authenticationSucceeded;

-(void)finishUp:(id)sender;

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;
- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;
- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;


@end

