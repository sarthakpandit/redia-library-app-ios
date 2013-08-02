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
#import "SearchResultsView.h"
#import "MultiLineLabel.h"
#import "AddReservationView.h"
#import "SearchResultObject.h"
#import "ImageLoadedNotificationDelegate.h"

@interface SearchResultItem : UIViewController<AddReservationViewDelegate, ImageLoadedNotificationDelegate> {
	UIImageView* coverImageView;
	MultiLineLabel* titleLabel;
	MultiLineLabel* authorLabel;
	UILabel* unavailLabel;
	UILabel* typeLabel1;
	UIButton* showDetailButton;
	UIButton* reserveButton;
	UIWebView* allInfoView;
	UIActivityIndicatorView* loadingIndicator;

    //BOOL coverImageDownloaded;

    AddReservationView* currentReservationView;

}

@property (nonatomic, strong) IBOutlet UIImageView* coverImageView;
@property (nonatomic, strong) IBOutlet MultiLineLabel* titleLabel;
@property (nonatomic, strong) IBOutlet MultiLineLabel* authorLabel;
@property (nonatomic, strong) IBOutlet UILabel* unavailLabel;
@property (nonatomic, strong) IBOutlet UILabel* typeLabel1;
@property (nonatomic, strong) IBOutlet UIButton* showDetailButton;
@property (nonatomic, strong) IBOutlet UIButton* reserveButton;
@property (nonatomic, strong) IBOutlet UIWebView* allInfoView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView* loadingIndicator;

//@property (nonatomic) BOOL coverImageDownloaded;

@property (nonatomic, strong) SearchResultObject* resultObject;

- (IBAction)addReservation:(id)sender;

- (IBAction)showDetails:(id)sender;

- (void)updateFromRecordStructure:(NSDictionary*)cur_item;
- (void)updateCoverUrl:(NSString*)coverurl;
- (void)updateFromObjectExtras:(NSDictionary*)extras_dict;

- (void)setBookTitle:(NSString *)s;
- (void)setOtherInfo:(NSString *)s;

@end
