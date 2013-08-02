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
#import "ChannelFetchManager.h"


@interface ArrangementsView : UIViewController<UIScrollViewDelegate, ChannelFetchCompleteDelegate, MyTabBarNotificationDelegate, UINavigationControllerDelegate> {
	UIScrollView* itemScroller;
	
	NSMutableArray* _items;
	NSMutableArray* _itemDetailContent;
	UIActivityIndicatorView* loadingIndicator;
	
	//NSString* emptyWebText;
	
	//bool showingDetail;
	
}

@property (nonatomic, strong) IBOutlet UIScrollView* itemScroller;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;

@property (nonatomic, strong) NSMutableArray* items;
@property (nonatomic, strong) NSMutableArray* itemDetailContent;


- (void)channelFetchComplete:(NSArray*) infoObjects;
- (void)updateItems;

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)itemTapped:(id)sender;


- (void)tabBarControllerSelected:(id)newController;
- (void)authenticationSucceeded;


@end
