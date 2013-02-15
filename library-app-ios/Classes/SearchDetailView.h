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
#import "SearchResultObject.h"
#import "ImageLoadedNotificationDelegate.h"

@interface SearchDetailView : UIViewController<XMLRPCConnectionDelegate, MyTabBarNotificationDelegate, UIAlertViewDelegate, UIWebViewDelegate, AddReservationViewDelegate, ImageLoadedNotificationDelegate> {
	UIImageView* coverImageView;
	MultiLineLabel* titleLabel;
	MultiLineLabel* authorLabel;
	UIButton* reserveButton;
	UIWebView* allInfoView;
	UIActivityIndicatorView* loadingIndicator;
    UIScrollView* mainScroller;
    UIImageView* separator;

    NSMutableArray* items;

    //BOOL coverImageDownloaded;
    bool isObjectFetched;
    bool isObjectExtrasFetched;
    int childrenListEndYPos;
    
    AddReservationView* currentReservationView;
    
}

@property (nonatomic, strong) IBOutlet UIImageView* coverImageView;
@property (nonatomic, strong) IBOutlet MultiLineLabel* titleLabel;
@property (nonatomic, strong) IBOutlet MultiLineLabel* authorLabel;

@property (nonatomic, strong) IBOutlet UIButton* reserveButton;
@property (nonatomic, strong) IBOutlet UIButton *aboutButton;
@property (nonatomic, strong) IBOutlet UIWebView* allInfoView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) IBOutlet UIScrollView* mainScroller;
@property (nonatomic, strong) IBOutlet UIImageView* separator;

//@property (nonatomic) BOOL coverImageDownloaded;
@property (nonatomic, strong) SearchResultObject* resultObject;

- (IBAction)addReservation:(id)sender;

- (void)updateFromResultObject:(SearchResultObject*)res;

- (void)fetchDetails;
- (void)parseChildren;
- (void)tabBarControllerSelected:(id)newController;
- (void)authenticationSucceeded;
- (void)updateAllInfoView:(NSArray*)new_items;
- (void)showAllInfoView:(id)sender;


@end
