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
#import "SearchDetailView.h"
#import "LibraryExternals.h"
#import "SearchResultsView.h"

@interface AboutDetailsItemViewController : UIViewController<XMLRPCConnectionDelegate> {
    NSString* externalsKey;
}

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *buttonDescription;
@property (nonatomic, strong) SearchResultsView* superViewController;
@property (nonatomic, strong) LibraryExternals* externalsObject;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *discloseButton;
@property (weak, nonatomic) IBOutlet UILabel *noContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (nonatomic) BOOL hasValidExternals;


- (IBAction)discloseButtonClicked:(id)sender;

-(void)fetchDataForExternalsKey:(NSString*)k identifier:(NSString*)obj_id;


@end
