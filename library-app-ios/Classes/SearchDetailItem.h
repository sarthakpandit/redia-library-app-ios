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
#import "AddReservationView.h"
#import "SearchResultObject.h"

@class SearchDetailView;
@class SearchResultsView;

@interface SearchDetailItem : UIViewController<AddReservationViewDelegate> {
    UILabel* bookTitle;
    UILabel* bookAuthor;
    UIButton* detailButton;
    UIButton* reserveButton;
    UILabel* typeLabel;
    
    //NSString* identifier;
    SearchResultsView* superViewController;
    //NSString* reservationId;
    
    AddReservationView* currentAddReservationView;
    
}

@property (nonatomic, strong) IBOutlet UILabel* bookTitle;
@property (nonatomic, strong) IBOutlet UILabel* bookAuthor;
@property (nonatomic, strong) IBOutlet UIButton* detailButton;
@property (nonatomic, strong) IBOutlet UIButton* reserveButton;
@property (nonatomic, strong) IBOutlet UILabel* typeLabel;
//@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, strong) SearchResultsView* superViewController;
//@property (nonatomic, copy) NSString* reservationId;
@property (nonatomic, strong) SearchResultObject* resultObject;

- (IBAction)showDetails:(id)sender;
- (IBAction)addReservation:(id)sender;

- (void)updateFromResultObject:(SearchResultObject*)res;
- (void)parseObjectExtras:(NSDictionary*)datadict;

@end
