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
//#import "InfoGalleriXmlRpcClient201009ChannelFetchDelegate.h"
#import "libraryappAppDelegate.h"
#import "ChannelFetchManager.h"
#import "LoadImageCounter.h"
#import "HeavyShadowLabel.h"

@interface BibStoreView : UIViewController<UIScrollViewDelegate, ChannelFetchCompleteDelegate, MyTabBarNotificationDelegate, LoadImageCounterDelegate, UINavigationControllerDelegate> {
	UIImageView* featureImage1;
	UIImageView* featureImage2;
	UIImageView* featureImage3;
	UIImageView* featureImage4;
    
    HeavyShadowLabel* featureHeadline1;
    HeavyShadowLabel* featureHeadline2;
    HeavyShadowLabel* featureHeadline3;
    HeavyShadowLabel* featureHeadline4;
    
	UIScrollView* itemScroller;
	UIActivityIndicatorView* loadingIndicator;

	//UIWebView* itemDetailView;
    //UIView* itemDetailBackground;
	
	NSMutableArray* _items;
	NSMutableArray* _itemDetailContent;
	
	//NSString* emptyWebText;
	
	//bool showingDetail;
	LoadImageCounter* imageCounter;
	
	NSString* currentReservationCatalogID;

    BOOL splashHasBeenShown;
}

@property (nonatomic, strong) IBOutlet UIImageView* featureImage1;
@property (nonatomic, strong) IBOutlet UIImageView* featureImage2;
@property (nonatomic, strong) IBOutlet UIImageView* featureImage3;
@property (nonatomic, strong) IBOutlet UIImageView* featureImage4;

@property (nonatomic, strong) IBOutlet HeavyShadowLabel* featureHeadline1;
@property (nonatomic, strong) IBOutlet HeavyShadowLabel* featureHeadline2;
@property (nonatomic, strong) IBOutlet HeavyShadowLabel* featureHeadline3;
@property (nonatomic, strong) IBOutlet HeavyShadowLabel* featureHeadline4;

@property (nonatomic, strong) IBOutlet UIScrollView* itemScroller;
//@property (nonatomic, strong) IBOutlet UIWebView* itemDetailView;
//@property (nonatomic, strong) IBOutlet UIView* itemDetailBackground;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, copy) NSString* currentReservationCatalogID;

@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableArray* itemDetailContent;

- (void)updateItems;

- (void)channelFetchComplete:(NSArray*) infoObjects;

- (void)notifyCountReached:(LoadImageCounter*)sender errorCount:(int)errors;

- (void)itemTapped:(id)sender;

/*
- (void)hideDetail:(bool)animated;
- (void)clearDetailView;
*/

- (void)tabBarControllerSelected:(id)newController;
- (void)authenticationSucceeded;

@end
