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
#import "MultiLineLabel.h"
#import "libraryappAppDelegate.h"
#import "AddReservationView.h"
#import "SearchResultsView.h"
#import "SearchResultObject.h"
#import "LibraryXmlRpcClient.h"

@interface AboutDetailsViewController : UIViewController<XMLRPCConnectionDelegate, MyTabBarNotificationDelegate, UIAlertViewDelegate, UIWebViewDelegate, AddReservationViewDelegate>
{
    AddReservationView* currentReservationView;
    NSMutableArray* detailButtons;

}

@property (nonatomic, strong) IBOutlet UIImageView* coverImageView;
@property (nonatomic, strong) IBOutlet MultiLineLabel* titleLabel;
@property (nonatomic, strong) IBOutlet MultiLineLabel* authorLabel;

@property (nonatomic, strong) IBOutlet UIButton* reserveButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) IBOutlet UIScrollView* mainScroller;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;

//@property (nonatomic, copy) NSString* identifier;
//@property (nonatomic, copy) NSString* reservationId;
@property (nonatomic, strong) SearchResultsView* superViewController;
@property (nonatomic, strong) SearchResultObject* resultObject;

- (void)updateFromResultObject:(SearchResultObject*)res;

- (void)fetchAboutDetails;

- (IBAction)reserveButtonClicked:(id)sender;
- (IBAction)detailsButtonClicked:(id)sender;

@end
