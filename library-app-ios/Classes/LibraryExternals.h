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

@interface LibraryExternals : NSObject {
    
}

@property(nonatomic) NSString* title;
@property(nonatomic) NSString* object_id;
@property(nonatomic) NSString* coverId;

@property(nonatomic) BOOL hasAboutAuthor; //default to false;
@property(nonatomic) NSString* aboutAuthorDescription;
@property(nonatomic) NSString* aboutAuthorTitle;
@property(nonatomic) NSString* aboutAuthorName;
@property(nonatomic) NSArray* aboutAuthorUrls; //of ExternalsUrl

@property(nonatomic) BOOL hasAdhlItems;
@property(nonatomic) NSArray* adhlItems; // of ExternalsAdhlItem
@property(nonatomic) NSArray* adhlDictionaries; // of NSDictionary


@property(nonatomic) BOOL hasOthersByAuthorItems;
@property(nonatomic) NSArray* othersByAuthorItems; // of ExternalsOthersByAuthorItem
@property(nonatomic) NSArray* othersByAuthorDictionaries; // of NSDictionary
@property(nonatomic) NSString* othersByAuthorName;

@property(nonatomic) BOOL hasSeriesItems;

@property(nonatomic) NSArray* seriesItems; // of ExternalsSeriesItem
@property(nonatomic) NSArray* seriesDictionaries; // of NSDictionary

@property(nonatomic) BOOL hasReviewItems;
@property(nonatomic) NSArray* reviewItems; // of ExternalsReviewItem

@property(nonatomic) NSString* faustId;

@property(nonatomic) NSString* creator;

+ (LibraryExternals*)createLibraryExternalsFromObject:(NSDictionary*)externalsDataMap;

@end


@interface LibraryExternalsUrl : NSObject

@property(nonatomic) NSString* url;
@property(nonatomic) NSString* title;

@end

@interface LibraryExternalsAdhlItem : NSObject
@property(nonatomic) NSString* recordId;
@property(nonatomic) NSString* title;
@property(nonatomic) NSString* type;
@property(nonatomic) NSString* description;
@property(nonatomic) NSString* url;
@property(nonatomic) NSString* creator;
@property(nonatomic) NSString* coverId;
@property(nonatomic) NSString* faustId;
@property(nonatomic) NSString* identifier;
@end

@interface LibraryExternalsOthersByAuthorItem : NSObject
@property(nonatomic) NSString* uri;
@property(nonatomic) NSString* publisher;
@property(nonatomic) NSString* creator;
@property(nonatomic) NSString* identifier;
@property(nonatomic) NSString* date;
@property(nonatomic) NSString* type;
@property(nonatomic) NSString* faust;
@property(nonatomic) NSString* title;
@property(nonatomic) NSString* genre;
@property(nonatomic) NSString* coverId;

@end

@interface LibraryExternalsSeriesItem : NSObject
@property(nonatomic) NSString* faust;
@property(nonatomic) NSString* shelfMark;
@property(nonatomic) NSString* identifier;
@property(nonatomic) NSString* language;
@property(nonatomic) NSString* isbn;
@property(nonatomic) NSString* title;
@property(nonatomic) NSString* creator;
@property(nonatomic) NSString* publisher;
@property(nonatomic) NSString* date;
@property(nonatomic) NSString* type;
@property(nonatomic) NSString* subject;
@property(nonatomic) NSString* series;
@property(nonatomic) NSString* genre;
@property(nonatomic) NSString* abstr;
@property(nonatomic) NSString* coverId;

@end

@interface LibraryExternalsReviewItem : NSObject
@property(nonatomic) NSString* review;
@property(nonatomic) NSString* source;
@property(nonatomic) NSString* url;

@end
