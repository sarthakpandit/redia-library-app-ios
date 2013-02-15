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

@interface SearchResultObject : NSObject {
/*
 NSString* identifier;
 NSObject* children;
 
 NSString* origTitle;
 NSString* origAuthor;
 NSString* abstract;
 NSString* date;
 NSString* reservationId;
 NSString* coverId;
*/
}

@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, strong) NSObject* children;

@property (nonatomic, copy) NSString* origTitle;
@property (nonatomic, copy) NSString* origAuthor;
@property (nonatomic, copy) NSString* abstract;
@property (nonatomic, copy) NSString* date;
@property (nonatomic, copy) NSString* reservationId;
@property (nonatomic, copy) NSString* coverId;
@property (nonatomic, copy) NSString* otherInfo;
@property (nonatomic, strong) UIImage* coverImage;
@property (nonatomic, copy) NSString* typeString;
@property (nonatomic) BOOL coverImageDownloaded;
//not used yet: @property (nonatomic) BOOL isCollection;

+ (UIImage*)getDefaultImageForType:(NSString *)type_string;

+ (SearchResultObject*)createFromRecordStructure:(NSDictionary*)cur_item;

@end
