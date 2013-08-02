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


#import "LibraryAppSetttings.h"

@implementation LibraryAppSetttings

@synthesize settings;
@synthesize customerBackgroundColor;
@synthesize customerBackgroundColorHTML;
@synthesize isRetinaDisplay;


static LibraryAppSetttings *sharedSingleton;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[LibraryAppSetttings alloc] init];
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
            sharedSingleton.isRetinaDisplay=true;
        }

    }
}

+ (LibraryAppSetttings*)instance
{
	return sharedSingleton;
}

- (id)init {
    self = [super init];
    if (self) {
        self.customerBackgroundColor = [UIColor redColor];
        [self loadSettings];
    }
    return self;
}

- (void)setCustomerBackgroundColorIntsRed:(int)r green:(int)g blue:(int)b
{
    self.customerBackgroundColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    self.customerBackgroundColorHTML = [NSString stringWithFormat:@"#%2x%2x%2x",r,g,b];
}

-(void)loadSettings
{
    self.settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"libraryapp-settings.plist" ofType:nil]];
    if (settings==nil) {
        NSLog(@"ERROR READING IG SETTINGS");
        return;
    }
    
    NSString* string_color = [settings objectForKey:@"interface_hex_color"];
    NSScanner* hexscanner = [NSScanner scannerWithString:string_color];
    unsigned int col_num;
    BOOL success = [hexscanner scanHexInt:&col_num];
    if (success) {
        unsigned char r = (col_num >> 16);
        unsigned char g = (col_num >> 8);
        unsigned char b = (col_num);
        [self setCustomerBackgroundColorIntsRed:r green:g blue:b];
    }

}

-(NSString *)getCustomerId
{
    if (settings!=nil) {
        return [settings objectForKey:@"customer_id"];
    }
    return nil;
}

-(NSString *)getGalleryCustomerId
{
    if (settings!=nil) {
        NSString* ig_customerid = [settings objectForKey:@"customer_id_for_gallery"];
        if (ig_customerid==nil || [ig_customerid length]==0) {
            return [self getCustomerId];
        } else {
            return ig_customerid;
        }
    }
    return nil;
}

-(NSString *)getGalleryId
{
    if (settings!=nil) {
        return [settings objectForKey:@"gallery_id"];
    }
    return nil;
    
}

-(NSString *)getBackgroundColor
{
    return customerBackgroundColorHTML;
}

-(NSString *)getNoImageName
{
    if (settings!=nil) {
        return [settings objectForKey:@"no_image_image"];
    }
    return nil;

}

-(int)getBodyFontSize
{
    return 13;
}

-(NSString*)getLibraryHomepage
{
    return [settings objectForKey:@"librarys_homepage_url"];
}

@end
