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


#import "SearchResultObject.h"
#import "defines.h"
#import "NSString+LibUtils.h"
#import "SearchResultsView.h"

@implementation SearchResultObject

@synthesize identifier;
@synthesize children;
@synthesize origTitle;
@synthesize origAuthor;
@synthesize abstract;
@synthesize date;
@synthesize reservationId;
@synthesize coverId;
@synthesize otherInfo;
@synthesize coverImage;
@synthesize typeString;
@synthesize coverImageDownloaded;
//@synthesize isCollection;

+ (UIImage*)getDefaultImageForType:(NSString *)type_string
{
    if ([type_string isEqualToString:@"Artikel"]
        || [type_string isEqualToString:@"Tidsskrift"]
        || [type_string isEqualToString:@"Årbog"]) {
        
        return [UIImage imageNamed:@"magasin"];
        
    } else if ([type_string isEqualToString:@"Collection"]) {
        
        return [UIImage imageNamed:@"samling"];
        
    } else if ([type_string isEqualToString:@"Wii-spil"]
               || [type_string isEqualToString:@"CD-rom"]
               || [type_string isEqualToString:@"DVD-rom"]
               || [type_string isEqualToString:@"Spil"]
               || [type_string isEqualToString:@"Playstation3-spil"]
               || [type_string isEqualToString:@"Playstation2-spil"]
               || [type_string isEqualToString:@"XBOX-spil"]
               || [type_string isEqualToString:@"PC-spil"]
               || [type_string isEqualToString:@"Playstation-spil"]
               ) {
        
        return [UIImage imageNamed:@"spil"];
        
    } else if ([type_string isEqualToString:@"CD"]
               || [type_string isEqualToString:@"Lydbog (CD)"]
               || [type_string isEqualToString:@"Grammofonplade"]
               ) {
        
        return [UIImage imageNamed:@"cd"];
        
    } else if ([type_string isEqualToString:@"DVD"]
               || [type_string isEqualToString:@"Blu-ray disc"]
               || [type_string isEqualToString:@"Video"]
               || [type_string isEqualToString:@"VHS"]
               ) {
        
        return [UIImage imageNamed:@"film"];
        
    }  else if ([type_string isEqualToString:@"Node"]) {
        
        return [UIImage imageNamed:@"musik"];
        
    }
    
    return [UIImage imageNamed:@"bog"];
    
}

+ (SearchResultObject*)createFromRecordStructure:(NSDictionary*)cur_item
{
    SearchResultObject* res = [SearchResultObject new];
    EXPECT_OBJECT(NSDictionary, cur_item);
    
    res.origTitle = [[cur_item objectForKey:@"title"] unescapedFromXML] ? : @"";
    
    
    NSString* authorstring = [[cur_item objectForKey:@"creator"] unescapedFromXML] ? : @"";
    bool has_author = [authorstring length]>0;
    res.origAuthor = authorstring;
    
    NSString* datestring = [cur_item objectForKey:@"date"] ? : @"";
    bool has_date = [datestring length]>0;
    res.date = datestring;
    
    NSString* abstractstring = [cur_item objectForKey:@"abstract"] ? : @"";
    res.abstract = abstractstring;
    
    res.otherInfo = [NSString stringWithFormat:@"%@%@%@%@%@%@%@",
                           has_author ? @"af: " : @"",
                           authorstring,
                           has_date ? @" (" : @"",
                           datestring,
                           has_date ? @")" : @"",
                           has_author ? @"\n\n" : @"\n",
                           abstractstring];
    
    
    res.identifier = [cur_item objectForKey:@"identifier"];
    res.coverId = [cur_item objectForKey:@"coverId"];
    
    //this hack is a workaround for case 7156
    if (res.coverId==nil || [res.coverId length]==0) {
        res.coverId = res.identifier;
    }
    res.typeString = [cur_item objectForKey:@"type"];
    res.children = [cur_item objectForKey:@"children"];
    
    res.coverImage = [self getDefaultImageForType:res.typeString];

    return res;
}

@end
