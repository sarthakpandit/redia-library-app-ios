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

@interface SearchResultsView : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, XMLRPCConnectionDelegate, MyTabBarNotificationDelegate>  {
	UIScrollView* itemScroller;
	UIButton* typeSelectButton;
	UILabel* typeCountLabel;
	UIPickerView* typeSelectPicker;
	UIButton* moreButton;

	UIActivityIndicatorView* loadingIndicator;
	UILabel* errorLabel;
    UIView* rootview;
    
	//NSString* currentReservationCatalogID;
	NSMutableArray* typeTitles;
	NSMutableArray* typeCounts;
	
	//NSMutableArray* searchResultItems;
	NSString* currentSearchString;
	NSString* currentTypeFilter;
	
	//NSMutableArray* pendingConnectionIds;
	NSMutableArray* searchResultItemsArray;
	NSMutableDictionary* searchResultItemsDict;
	int currentTypePickerSelectedRow;
	int currentResultsPageNo;

	bool showingPicker;
    
    //AddReservationView* currentReservationView;
}

@property (nonatomic, strong) IBOutlet UIScrollView* itemScroller; 
@property (nonatomic, strong) IBOutlet UIButton* typeSelectButton;
@property (nonatomic, strong) IBOutlet UILabel* typeCountLabel;
@property (nonatomic, strong) IBOutlet UIPickerView* typeSelectPicker;
@property (nonatomic, strong) IBOutlet UIButton* moreButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;
@property (nonatomic, strong) IBOutlet UILabel* errorLabel;
@property (nonatomic, strong) IBOutlet UIView* rootview;

//@property (nonatomic, copy) NSString* currentReservationCatalogID;
@property (nonatomic, strong) NSMutableArray* typeTitles;
@property (nonatomic, strong) NSMutableArray* typeCounts;

@property (nonatomic, copy) NSString* currentSearchString;
@property (nonatomic, copy) NSString* currentTypeFilter;

- (void)performSearch:(NSString*)searchString typeFilter:(NSString*)typeFilter resultsPageNo:(int)pageNo;

- (void)showTypePicker;
- (void)hideTypePicker;
- (IBAction)toggleTypePicker:(id)sender;
- (IBAction)getMoreResults:(id)sender;

- (void)discardResultItems:(id)sender;

- (void)typeFilterSelected:(id)sender;

- (void)tabBarControllerSelected:(id)newController;
- (void)authenticationSucceeded;

//- (void)addReservation:(NSString*)reservation_id withTitle:(NSString*)titl;

- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response;
- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error;
- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;
- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge;

@end
