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

@interface LibraryAppSetttings : NSObject
{
    NSDictionary* settings;
    
    
    UIColor* customerBackgroundColor;
    NSString* customerBackgroundColorHTML; 
    bool isRetinaDisplay;

}

@property (nonatomic, strong) NSDictionary* settings;
@property (nonatomic, strong) UIColor* customerBackgroundColor;
@property (nonatomic, copy) NSString* customerBackgroundColorHTML;

@property (nonatomic) bool isRetinaDisplay;

+ (LibraryAppSetttings*) instance;

-(void)loadSettings;
-(void)setCustomerBackgroundColorIntsRed:(int)r green:(int)g blue:(int)b;

-(NSString*)getCustomerId;
-(NSString*)getGalleryCustomerId;
-(NSString*)getGalleryId;
-(NSString*)getBackgroundColor;
-(NSString*)getNoImageName;

-(int)getBodyFontSize;
-(NSString*)getLibraryHomepage;

#ifdef REDIA_APP_USE_SCANNER_OPTION
//get scanner sound id
#endif

@end
