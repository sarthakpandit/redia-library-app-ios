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


#import <Foundation/Foundation.h>


@class MainBibSearch;
@class CustomNavigationController;

@interface BibSearchSingleton : NSObject {
	NSMutableArray* searchViewControllers;
	NSString* currentSearchString;
    
}

@property (nonatomic, copy) NSString* currentSearchString;
@property (nonatomic, strong) CustomNavigationController* currentSearchResultsNavController;
@property (nonatomic) int searchResultsNavStackTopIndex;


//Get the singleton
+ (BibSearchSingleton*) instance;

//- (void)registerSubController:(MainBibSearch*)sub;
- (void)registerCustomNavigationController:(CustomNavigationController*)customNav;
- (void)somewhereElseClicked:(id)sender;
- (void)dismissSearchResultsView;

@end
