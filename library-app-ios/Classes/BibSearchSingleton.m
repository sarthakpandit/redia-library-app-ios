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


#import "BibSearchSingleton.h"
#import "CustomNavigationController.h"

@implementation BibSearchSingleton

@synthesize currentSearchString;
@synthesize currentSearchResultsNavController;
@synthesize searchResultsNavStackTopIndex;

static BibSearchSingleton *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[BibSearchSingleton alloc] init];
	}
}

+ (BibSearchSingleton*)instance
{
	return sharedSingleton;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		searchViewControllers = [NSMutableArray new];
		self.currentSearchString = @"";
	}
	return self;
}

/*
- (void)registerSubController:(MainBibSearch*)sub
{
	[searchViewControllers addObject:sub];
	[sub.theSearchBar setText:currentSearchString];
}
*/

-(void)registerCustomNavigationController:(CustomNavigationController *)customNav
{
    [searchViewControllers addObject:customNav];
    [customNav setSearchbarText:currentSearchString];
}

- (void)somewhereElseClicked:(id)sender
{
    for (CustomNavigationController* customNav in searchViewControllers) {
        [customNav somewhereElseClicked:sender];
    }
}

- (void)dismissSearchResultsView
{
    if (currentSearchResultsNavController!=nil) {
        [currentSearchResultsNavController dismissSearchResultsView];
    }
    currentSearchResultsNavController=nil;
    searchResultsNavStackTopIndex=0;
}

@end
