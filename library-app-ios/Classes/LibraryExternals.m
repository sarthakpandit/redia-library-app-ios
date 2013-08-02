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


#import "LibraryExternals.h"
#import "defines.h"

@implementation NSDictionary (ContainsKey)

-(BOOL)containsKey:(id)key
{
    return [self objectForKey:key] != nil;
}

@end

@implementation LibraryExternals

@synthesize hasAboutAuthor; //default to false;
@synthesize hasAdhlItems;
@synthesize hasOthersByAuthorItems;
@synthesize hasReviewItems;
@synthesize hasSeriesItems;
@synthesize aboutAuthorUrls; //of ExternalsUrl
@synthesize othersByAuthorItems; // of ExternalsOthersByAuthorItem
@synthesize othersByAuthorDictionaries; // of NSDictionary
@synthesize reviewItems; // of ExternalsReviewItem
@synthesize seriesItems; // of ExternalsSeriesItem
@synthesize seriesDictionaries;
@synthesize aboutAuthorDescription;
@synthesize aboutAuthorName;
@synthesize aboutAuthorTitle;
@synthesize coverId;
@synthesize creator;
@synthesize faustId;
@synthesize object_id;
@synthesize title;
@synthesize adhlItems; // of ExternalsAdhlItem
@synthesize adhlDictionaries;



+ (LibraryExternals*)createLibraryExternalsFromObject:(NSDictionary*)externalsDataMap
{
    if (externalsDataMap==nil) {
        ALog(@"Error: externalsDataMap was nil");
    }
	
	LibraryExternals* externals = [LibraryExternals new];
    
	if ([externalsDataMap containsKey:@"aboutauthor"]) {
		NSDictionary* aboutAuthorMap = [externalsDataMap objectForKey:@"aboutauthor"];
		if (aboutAuthorMap!=nil) {
            EXPECT_OBJECT(NSDictionary, aboutAuthorMap)

			externals.aboutAuthorDescription = [aboutAuthorMap objectForKey:@"description"];
			externals.aboutAuthorName = [aboutAuthorMap objectForKey:@"name"];
			externals.aboutAuthorTitle = [aboutAuthorMap objectForKey:@"title"];
			externals.aboutAuthorUrls = [NSMutableArray new];
            for (NSDictionary* urlMap in [aboutAuthorMap objectForKey:@"urls"]) {
                EXPECT_OBJECT(NSDictionary, urlMap);
                LibraryExternalsUrl* url = [LibraryExternalsUrl new];
                url.url = [urlMap objectForKey:@"url"];
				url.title = [urlMap objectForKey:@"title"];
				[(NSMutableArray*)externals.aboutAuthorUrls addObject:url];
            }
            /* was:
			for (Object urlObj : XmlRpcResultUtils.unpackArray([aboutAuthorMap objectForKey:@"urls"])) {
				Map<String,Object> urlMap = XmlRpcResultUtils.unpackStruct(urlObj);
				ExternalsUrl url = new ExternalsUrl();
				url.url = [urlMap objectForKey:@"url"];
				url.title = [urlMap objectForKey:@"title"];
				externals.aboutAuthorUrls.add(url);
			}
             */
			// Only note that we have aboutAuthor info if there is actually something
			// useful beyond a name
			externals.hasAboutAuthor = ([externals.aboutAuthorUrls count]>0 || [externals.aboutAuthorDescription length]>0);
		}
	}
    
	if ([externalsDataMap containsKey:@"series"]) {
		NSDictionary* seriesMap = [externalsDataMap objectForKey:@"series"];
		NSArray* dataObjArr = [seriesMap objectForKey:@"data"];
		if (dataObjArr!=nil) {
            EXPECT_OBJECT(NSArray, dataObjArr);
            
            NSMutableArray* seriesItems = [NSMutableArray new];
            NSMutableArray* seriesDictionaries = [NSMutableArray new];
			for (NSArray* nested1ObjArr in dataObjArr) {
				//NSArray* nested1ObjArr = object;
				if (nested1ObjArr!=nil) {
                    EXPECT_OBJECT(NSArray, nested1ObjArr);
					for (NSDictionary* objMap in nested1ObjArr) {
						//NSDictionary* objMap = XmlRpcResultUtils.unpackStruct(nested1Obj);
                        
                        LibraryExternalsSeriesItem* esi = [LibraryExternalsSeriesItem new];
                        esi.abstr = [objMap objectForKey:@"abstract"];
                        esi.genre = [objMap objectForKey:@"genre"];
                        esi.series = [objMap objectForKey:@"series"];
                        esi.subject = [objMap objectForKey:@"subject"];
                        esi.type = [objMap objectForKey:@"type"];
                        esi.date = [objMap objectForKey:@"date"];
                        esi.publisher = [objMap objectForKey:@"publisher"];
                        esi.creator = [objMap objectForKey:@"creator"];
                        esi.title = [objMap objectForKey:@"title"];
                        esi.isbn = [objMap objectForKey:@"isbn"];
                        esi.faust = [objMap objectForKey:@"faust"];
                        esi.language = [objMap objectForKey:@"language"];
                        esi.shelfMark = [objMap objectForKey:@"shelfMark"];
                        esi.identifier = [objMap objectForKey:@"identifier"];
                        esi.coverId = [objMap objectForKey:@"coverId"];
                        
                        //externals.seriesItems.add(esi);
                        [seriesItems addObject:esi];
                        [seriesDictionaries addObject:objMap];
                        externals.hasSeriesItems = true;
					}
				}
			}
            externals.seriesItems = seriesItems;
            externals.seriesDictionaries = seriesDictionaries;
		}
	}
    
	if ([externalsDataMap containsKey:@"info"]) {
		NSDictionary* infoMap = [externalsDataMap objectForKey:@"info"];
        
        EXPECT_OBJECT(NSDictionary, infoMap);
        
		if ([infoMap containsKey:@"title"]) {
			externals.title = [infoMap objectForKey:@"title"];
		}
		if ([infoMap containsKey:@"creator"]) {
			externals.creator = [infoMap objectForKey:@"creator"]; //setCreator
		}
		if ([infoMap containsKey:@"faust"]) {
			externals.faustId = [infoMap objectForKey:@"faust"];
		}
		if ([infoMap containsKey:@"coverId"]) {
			externals.coverId =[infoMap objectForKey:@"coverId"];
		}
	}
	
	if ([externalsDataMap containsKey:@"reviews"]) {
		NSDictionary* reviewsMap = [externalsDataMap objectForKey:@"reviews"];
        EXPECT_OBJECT(NSDictionary, reviewsMap);
		if ([reviewsMap containsKey:@"data"]) {
			NSArray* dataArray = [reviewsMap objectForKey:@"data"];
            if (dataArray!=nil) {
                EXPECT_OBJECT(NSArray, dataArray);
                
                NSMutableArray* new_reviewsArray = [NSMutableArray new];
                for (NSDictionary* reviewsReviewMap in dataArray) {
                    EXPECT_OBJECT(NSDictionary, reviewsReviewMap);
                    
                    LibraryExternalsReviewItem* newReview = [LibraryExternalsReviewItem new];
                    newReview.review = [reviewsReviewMap objectForKey:@"review"];
                    newReview.source = [reviewsReviewMap objectForKey:@"source"];
                    newReview.url = [reviewsReviewMap objectForKey:@"url"];
                    [new_reviewsArray addObject:newReview];
                    externals.hasReviewItems=true;
                }
                externals.reviewItems = new_reviewsArray;
            }
		}
	}
    
	if ([externalsDataMap containsKey:@"adhl"]) {
		NSDictionary* adhlMap = [externalsDataMap objectForKey:@"adhl"];
		if (adhlMap!=nil) {
            EXPECT_OBJECT(NSDictionary, adhlMap);
			if ([adhlMap containsKey:@"data"]) {
				NSArray* adhlObjs = [adhlMap objectForKey:@"data"];
                NSMutableArray* adhlItems = [NSMutableArray new];
                NSMutableArray* adhlDictionaries = [NSMutableArray new];
				for (NSDictionary* adhlItemMap in adhlObjs) {
					//NSDictionary* adhlItemMap = XmlRpcResultUtils.unpackStruct(adhlItemObj);
					//ExternalsAdhlItem eai = new ExternalsAdhlItem();
                    LibraryExternalsAdhlItem* eai = [LibraryExternalsAdhlItem new];
					eai.recordId = [adhlItemMap objectForKey:@"recordId"];
					eai.title = [adhlItemMap objectForKey:@"title"];
					eai.type = [adhlItemMap objectForKey:@"type"];
					eai.description = [adhlItemMap objectForKey:@"description"];
					eai.url = [adhlItemMap objectForKey:@"url"];
					eai.creator = [adhlItemMap objectForKey:@"creator"];
					eai.coverId = [adhlItemMap objectForKey:@"coverId"];
					eai.faustId = [adhlItemMap objectForKey:@"faust"];
					eai.identifier = [adhlItemMap objectForKey:@"identifier"];
					//externals.adhlItems.add(eai);
                    [adhlItems addObject:eai];
                    [adhlDictionaries addObject:adhlItemMap];
					externals.hasAdhlItems = true;
				}
                
                externals.adhlItems = adhlItems;
                externals.adhlDictionaries = adhlDictionaries;
			}
		}
	}
    
	if ([externalsDataMap containsKey:@"othersbyauthor"]) {
		NSDictionary* othersByAuthorMap = [externalsDataMap objectForKey:@"othersbyauthor"];
		if (othersByAuthorMap!=nil) {
            EXPECT_OBJECT(NSDictionary, othersByAuthorMap);

            if ([othersByAuthorMap containsKey:@"author"]) {
                externals.othersByAuthorName = [othersByAuthorMap objectForKey:@"author"];
            }
			if ([othersByAuthorMap containsKey:@"data"]) {
				NSArray* othersByAuthorObjArr = [othersByAuthorMap objectForKey:@"data"];
				if (othersByAuthorObjArr!=nil) {
                    NSMutableArray* new_othersByAuthorItems = [NSMutableArray new];
                    NSMutableArray* new_othersByAuthorDictionaries = [NSMutableArray new];
                    
					for (NSArray* nested1ObjArr in othersByAuthorObjArr) {
						// Way too deep nesting, but we work around it anyway
						//NSArray* nested1ObjArr = object;
						if (nested1ObjArr!=nil) {
							for (NSDictionary* othersByAuthorItemMap in nested1ObjArr) {
								//NSDictionary* othersByAuthorItemMap = XmlRpcResultUtils.unpackStruct(nested1Obj);
                                
                                LibraryExternalsOthersByAuthorItem* eobai = [LibraryExternalsOthersByAuthorItem new];
                                eobai.genre = [othersByAuthorItemMap objectForKey:@"genre"];
                                eobai.title = [othersByAuthorItemMap objectForKey:@"title"];
                                eobai.faust = [othersByAuthorItemMap objectForKey:@"faust"];
                                eobai.type = [othersByAuthorItemMap objectForKey:@"type"];
                                eobai.date = [othersByAuthorItemMap objectForKey:@"date"];
                                eobai.uri = [othersByAuthorItemMap objectForKey:@"uri"];
                                eobai.identifier = [othersByAuthorItemMap objectForKey:@"identifier"];
                                eobai.publisher = [othersByAuthorItemMap objectForKey:@"publisher"];
                                eobai.creator = [othersByAuthorItemMap objectForKey:@"creator"];
                                eobai.coverId = [othersByAuthorItemMap objectForKey:@"coverId"];
                                //externals.othersByAuthorItems.add(eobai);
                                [new_othersByAuthorItems addObject:eobai];
                                [new_othersByAuthorDictionaries addObject:othersByAuthorItemMap];
                                externals.hasOthersByAuthorItems = true;
							}
						}
					}
                    externals.othersByAuthorItems = new_othersByAuthorItems;
                    externals.othersByAuthorDictionaries = new_othersByAuthorDictionaries;
				}

			}
		}
	}
	
    /* FIXME
	if ([externalsMap containsKey:@"id"]) {
		externals.obje = [externalsMap objectForKey:@"id"];
	}
    */
    
	return externals;
}

@end

@implementation LibraryExternalsUrl

@end

@implementation LibraryExternalsAdhlItem

@end

@implementation LibraryExternalsOthersByAuthorItem

@end

@implementation LibraryExternalsSeriesItem

@end

@implementation LibraryExternalsReviewItem

@end
