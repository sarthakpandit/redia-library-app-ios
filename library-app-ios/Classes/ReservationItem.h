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
#import "XMLRPCConnectionDelegate.h"
#import "ReservationList.h"

@interface ReservationItem : UIViewController<XMLRPCConnectionDelegate> {
	UILabel* bookTitle;
	UILabel* bookAuthor;
	UILabel* expireDate;
	UILabel* queueNumber;
	UILabel* pickupLabel;
	UILabel* pickupBranchLabel;
    UILabel* pickupSelfServiceNumber;
	UIActivityIndicatorView* loadingIndicator;
	UIButton* detailDeleteButton;
	UIButton* detailDeleteConfirmButton;

	NSString* catalogID;
	NSString* reservationID;
	
	ReservationList* superViewController;

}

@property (nonatomic, strong) IBOutlet UILabel* bookTitle;
@property (nonatomic, strong) IBOutlet UILabel* bookAuthor;
@property (nonatomic, strong) IBOutlet UILabel* expireDate;
@property (nonatomic, strong) IBOutlet UILabel* queueNumber;
@property (nonatomic, strong) IBOutlet UILabel* pickupLabel;
@property (nonatomic, strong) IBOutlet UILabel* pickupBranchLabel;
@property (nonatomic, strong) IBOutlet UILabel* pickupSelfServiceNumber;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) IBOutlet UIButton* detailDeleteButton; 
@property (nonatomic, strong) IBOutlet UIButton* detailDeleteConfirmButton;

@property (nonatomic, copy) NSString* catalogID;
@property (nonatomic, copy) NSString* reservationID;
@property (nonatomic, strong) ReservationList* superViewController;

- (IBAction)detailDeleteClicked:(id)sender;
- (IBAction)detailDeleteConfirmClicked:(id)sender;

- (void)showDelete;
- (void)showDeleteConfirm;
- (void)hideDelete:(BOOL)animated;

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;
- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;
- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
@end
