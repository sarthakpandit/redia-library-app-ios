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


#import "SearchResultsView.h"
#import <QuartzCore/CALayer.h>
//#import "ReservationBranchPicker.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "defines.h"
#import "LibraryAuthenticationManager.h"
#import "SearchResultItem.h"
#import "LazyLoadImageView.h"
#import "InfoGalleriImageUrlUtils.h"
//#import "HTMLEntityResolver.h"
#import "InfoObject.h"
#import "NSString+LibUtils.h"
#import "AddReservationView.h"
#import "LibraryAppSetttings.h"
#import "BibSearchSingleton.h"

@implementation SearchResultsView

/* 
 filter button min width: 97   max: 204,  diff 107
 item count min x pos: 156   max: 263,  diff 107
 min text: 64
 */

#define LIBRARY_SEARCH_RESULTS_PER_PAGE (20)
#define LIBRARY_SEARCH_FILTER_ALL_STRING @"ALLE"

@synthesize itemScroller; 
@synthesize typeSelectButton;
@synthesize typeCountLabel;
@synthesize typeSelectPicker;
@synthesize moreButton;
@synthesize loadingIndicator;
@synthesize errorLabel;
@synthesize rootview;

//@synthesize currentReservationidentifier;
@synthesize typeTitles;
@synthesize typeCounts;

@synthesize currentSearchString;
@synthesize currentTypeFilter;


-(void)checkForUpdate
{
    
}

- (void)updateFilterButtonWidth
{
    NSString* text = typeSelectButton.titleLabel.text;
    UIFont* font = typeSelectButton.titleLabel.font;
    CGSize tsize = [text sizeWithFont:font];
    
    int extrawidth = 45;
    int newtotalwidth = 72;
    if (tsize.width+extrawidth>72) {
        newtotalwidth = tsize.width+extrawidth;
        if (newtotalwidth>208) {
            newtotalwidth = 208;
        }
    }

    
    CGRect curbuttonframe = typeSelectButton.frame;
    curbuttonframe.size.width = newtotalwidth;
    typeSelectButton.frame=curbuttonframe;
    [typeSelectButton.titleLabel setTextAlignment:UITextAlignmentCenter];
    
    int labelxpos = newtotalwidth+59;
    CGRect curlabelframe = typeCountLabel.frame;
    curlabelframe.origin.x = labelxpos;
    typeCountLabel.frame=curlabelframe;
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    [typeSelectButton setBackgroundImage:
     [[typeSelectButton backgroundImageForState:UIControlStateNormal] 
      stretchableImageWithLeftCapWidth:96/2 topCapHeight:0] forState:UIControlStateNormal]; 

	self.typeTitles = [[NSMutableArray alloc] initWithObjects:LIBRARY_SEARCH_FILTER_ALL_STRING, @"Bog", @"Lydbog", @"CD", @"PC-spil", @"DVD", nil];
	
	self.typeCounts = [[NSMutableArray alloc] initWithObjects:@"43",@"17",@"3",@"14",@"1",@"2", nil];
	
	//pendingConnectionIds = [NSMutableArray new];
	
	[typeSelectPicker setHidden:TRUE];
	showingPicker=false;
	
	[self.view bringSubviewToFront:typeSelectPicker];
	typeSelectButton.titleLabel.text = LIBRARY_SEARCH_FILTER_ALL_STRING;
	[typeSelectButton addTarget:self action:@selector(toggleTypePicker:) forControlEvents:UIControlEventTouchUpInside];
	DLog(@"typeSelectButton: %@, text = %@",typeSelectButton,typeSelectButton.titleLabel.text);
	
	currentResultsPageNo=0;
	
	UITapGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.itemScroller addGestureRecognizer:gest];
	
	UITapGestureRecognizer* gest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(typeFilterSelected:)];
	[gest2 setDelaysTouchesBegan:NO];
	[gest2 setCancelsTouchesInView:NO];
	[self.typeSelectPicker addGestureRecognizer:gest2];
    
    //[self registerRootView:self.rootview withViewController:nil withFrame:self.rootview.frame];
}

- (void)performSearch:(NSString*)searchString typeFilter:(NSString*)typeFilter resultsPageNo:(int)pageNo
{
	errorLabel.hidden = YES;
	loadingIndicator.hidden = NO;
	[loadingIndicator startAnimating];
	[self.view bringSubviewToFront:loadingIndicator];
	
	[self discardResultItems:self];
	
	searchResultItemsDict = [NSMutableDictionary new];
	searchResultItemsArray = [NSMutableArray new];
	
	self.currentSearchString = searchString;
	self.currentTypeFilter = typeFilter;
	currentResultsPageNo = pageNo;

    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
    [[LibraryXmlRpcClient instance] search:searchString
							  maxItems:LIBRARY_SEARCH_RESULTS_PER_PAGE 
								offset:pageNo * LIBRARY_SEARCH_RESULTS_PER_PAGE
							typeFilter:typeFilter 
							  delegate:self];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DLog(@"didReceiveMemoryWarning");

    // Release any cached data, images, etc. that aren't in use.
}

- (void)discardResultItems:(id)sender
{
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
	
	if (searchResultItemsArray != nil) {
		for (SearchResultItem* olditem in searchResultItemsArray) {
			[olditem.view removeFromSuperview];
			//olditem.superViewController = nil;
            [olditem removeFromParentViewController];
		}
		
		[searchResultItemsArray removeAllObjects];
		searchResultItemsArray = nil;
		
		[searchResultItemsDict removeAllObjects];
		searchResultItemsDict = nil;
	}
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
	
    [self discardResultItems:self];
    
	[searchResultItemsArray removeAllObjects];
	searchResultItemsArray = nil;
	
	[searchResultItemsDict removeAllObjects];
	searchResultItemsDict = nil;
	
	self.itemScroller = nil;
	self.typeSelectButton = nil;
	self.typeCountLabel = nil;
	self.typeSelectPicker = nil;
	self.moreButton = nil;
	self.loadingIndicator = nil;
	self.errorLabel = nil;
    self.rootview=nil;
	
	DLog(@"viewDidUnload");
}


- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

    [self discardResultItems:self];

	[searchResultItemsArray removeAllObjects];
	searchResultItemsArray = nil;
	
	[searchResultItemsDict removeAllObjects];
	searchResultItemsDict = nil;
	

	DLog(@"dealloced");
}


- (void)showTypePicker  
{
	//DLog(@"show picker");
	typeSelectPicker.hidden = FALSE;
	typeSelectPicker.layer.opacity = 0.0;
	showingPicker=true;
	
	[UIView animateWithDuration:0.35 animations:^{
		typeSelectPicker.layer.opacity = 1.0;		
	}];
}

- (void)hideTypePicker
{
	//DLog(@"hide picker");
	showingPicker=false;
	[UIView animateWithDuration:0.35 animations:^{
		typeSelectPicker.layer.opacity = 0.0;		
	}];
}

- (IBAction)toggleTypePicker:(id)sender {
	if (showingPicker) {
		[self hideTypePicker];
	} else {
		[self showTypePicker];
	}

}

- (IBAction)getMoreResults:(id)sender
{
	self.moreButton.enabled = NO; //prevent multiple clicks
	self.moreButton.hidden = YES;
	[self performSearch:currentSearchString typeFilter:currentTypeFilter resultsPageNo:currentResultsPageNo+1];
	[itemScroller setContentOffset:CGPointMake(0, 0)];
}

- (void)delayedTypeFilterSelected:(id)sender
{
    DLog(@"currentTypePickerSelectedRow: %d", currentTypePickerSelectedRow);
	[typeSelectButton setTitle:[typeTitles objectAtIndex:currentTypePickerSelectedRow] forState:UIControlStateNormal];
	[typeCountLabel setText:[NSString stringWithFormat:@"(%@)",[typeCounts objectAtIndex:currentTypePickerSelectedRow]]];
    [self updateFilterButtonWidth];
    currentResultsPageNo=0;
    [itemScroller setContentOffset:CGPointMake(0, 0)];
	[self performSearch:currentSearchString typeFilter:currentTypeFilter resultsPageNo:currentResultsPageNo];
}

- (void)typeFilterSelected:(id)sender
{
	[self hideTypePicker];
    [self performSelector:@selector(delayedTypeFilterSelected:) withObject:self afterDelay:0.5];
}

//UIPickerViewDelegate Protocol
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	currentTypeFilter = [typeTitles objectAtIndex:row];
	if ([currentTypeFilter isEqualToString:LIBRARY_SEARCH_FILTER_ALL_STRING]) {
		currentTypeFilter = @"";
	}
	currentTypePickerSelectedRow = row;
    DLog(@"didSelectRow: %d", row);
}



- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString* retval=@"";
    if (row<[typeTitles count] && row<[typeCounts count]) {
        NSString* typename = [typeTitles objectAtIndex:row];
        NSString* typecount = [typeCounts objectAtIndex:row];
        retval = [NSString stringWithFormat:@"%@ (%@)",typename,typecount];
    }
	return retval;
}


//UIPickerViewDataSource Protocol
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [typeTitles count];
}




- (void)tabBarControllerSelected:(id)newController
{
}

-(void)authenticationFailed {
}

- (void)authenticationSucceeded
{

}



/*  ------------------------------------------------------
 XMLRPC
 ------------------------------------------------------
 */


- (void)request: (XMLRPCRequest *)request didReceiveResponse: (XMLRPCResponse *)response
{
	DLog(@"Response for request method: %@", [request method]);
	if ([response isFault]) {
		NSLog(@"Fault code: %@", [response faultCode]);
		
		NSLog(@"Fault string: %@", [response faultString]);
        
        [self.loadingIndicator stopAnimating];
        [self.errorLabel setHidden:NO];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fejl i søgning"
                                                        message:@"Serveren kunne desværre ikke gennemføre søgningen."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];	
        return;

	} else {
		DLog(@"Parsed response for method %@: %@",[request method], [response object]);
		//NSLog(@"xml: %@", [response body]);
		
		//UIFont* titlefont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
		//UIFont* authorfont = [UIFont fontWithName:@"HelveticaNeue" size:12];
        
		if ([[request method] isEqualToString:@"search"]) {
			NSDictionary* dict = [response object];
            
            EXPECT_OBJECT(NSDictionary, dict);
            
            NSNumber* result = [dict objectForKey:@"result"];
            EXPECT_OBJECT(NSNumber, result);
            
            if (![result boolValue]) {
                [self.loadingIndicator stopAnimating];
				[self.errorLabel setHidden:NO];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fejl i søgning"
                                                                message:@"Serveren kunne desværre ikke gennemføre søgningen."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];	
            } else {
                NSDictionary* datadict = [dict objectForKey:@"data"];
                
                //workaround for case 7167
                if (datadict==nil || ![datadict isKindOfClass:[NSDictionary class]]) {
                    [self.loadingIndicator stopAnimating];
                    [self.errorLabel setHidden:NO];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fejl i søgning"
                                                                    message:@"Serveren kunne desværre ikke gennemføre søgningen."
                                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];	
                    return;
                }
                
                EXPECT_OBJECT(NSDictionary, datadict);
                
                NSString* hitcount = @"0";
                if ([datadict objectForKey:@"hitCount"]!=nil) {
                    hitcount = [datadict objectForKey:@"hitCount"];
                }
                DLog("search hitcount: %@",hitcount);
                if ([hitcount intValue]==0) {
                    [self.loadingIndicator stopAnimating];
                    [self.errorLabel setHidden:NO];
                } else {
                    NSArray* results = nil;
                    
                    // this code is a quick fix for php svn rev. 10543
                    NSObject* abstractresults = [datadict objectForKey:@"results"];
                    if ([abstractresults isKindOfClass:[NSDictionary class]]) {
                        NSDictionary* dictionaryresults = (NSDictionary*) abstractresults;
                        results = [dictionaryresults allValues];
                    } else if ([abstractresults isKindOfClass:[NSArray class]]) {
                        results = (NSArray*) abstractresults;
                    } else {
                        ALog(@"ERROR: unknown class in 'results'");
                    }
                    
                    
                    BOOL moreresults = [[datadict objectForKey:@"more"] intValue];
                    
                    [self.loadingIndicator stopAnimating];
                    
                    int y=0;
                    int height = 138;
                    for (NSDictionary* cur_item in results) {
                        //NSLog(@"title: %@", [cur_item objectForKey:@"title"]);
                        //NSLog(@"creator: %@", [cur_item objectForKey:@"creator"]);
                        //NSLog(@"abstract: %@", [cur_item objectForKey:@"abstract"]);
                        
                        //DLog(@"cur_item class: %@",[cur_item class]);
                        
                        //quick fixes for bugs in php svn rev. 10543 
                        if (![cur_item isKindOfClass:[NSDictionary class]]) {
                            DLog(@"skipping bad result element (not NSDictionary), %@",cur_item);
                            continue; //skip this item since it is badly formatted
                        }
                        if ([cur_item objectForKey:@"title"]==nil) {
                            DLog(@"skipping bad result element with missing keys, %@",cur_item);
                            continue;
                        }
                        
                        
                        SearchResultItem* sritem = [[SearchResultItem alloc] initWithNibName:@"SearchResultItem" bundle:nil];
                        
                        //sritem.superViewController = self;
                        [self addChildViewController:sritem];
                        
                        sritem.view.frame = CGRectMake(0, y, 320, height);
                        
                        [sritem updateFromRecordStructure:cur_item];
                                                                    
                        [searchResultItemsDict setValue:sritem forKey:sritem.resultObject.identifier];
                        [searchResultItemsArray addObject:sritem];
                        
                        [self.itemScroller addSubview:sritem.view];
                        
                        y += height;
                        
                    }
                    
                    y += 5;
                    
                    if (moreresults) {
                        CGRect button_frame = self.moreButton.frame;
                        y += 10;
                        button_frame.origin.y = y;
                        self.moreButton.frame = button_frame;
                        self.moreButton.hidden = NO;
                        self.moreButton.enabled = YES;
                        y += button_frame.size.height + 15;
                    } else {
                        self.moreButton.hidden =YES;
                    }
                    
                    [self.itemScroller setContentSize:CGSizeMake(320, y)];
                    //NSLog(@"abstract is %@", [[results objectAtIndex:0] objectForKey:@"abstract"]);
                    
                }
                
                if ([currentTypeFilter isEqualToString:@""]) {
                    //only update filter types when in typefilter is not set (ie. "ALL")
                    NSArray* facets = [datadict objectForKey:@"facetTerm"];
                    self.typeTitles = [[NSMutableArray alloc] initWithObjects:LIBRARY_SEARCH_FILTER_ALL_STRING,nil];
                    self.typeCounts = [[NSMutableArray alloc] initWithObjects:hitcount,nil];
                    
                    for (NSDictionary* facetdict in facets) {
                        NSString* temptype = [facetdict objectForKey:@"term"];
                        if ([temptype length]>0) {
                            temptype = [temptype stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[temptype substringToIndex:1] uppercaseString]];
                        }
                        [self.typeTitles addObject:temptype];
                        [self.typeCounts addObject:[facetdict objectForKey:@"frequence"]];
                    }
                    [self.typeSelectPicker reloadAllComponents];
                    self.typeCountLabel.text = [NSString stringWithFormat:@"(%@)",hitcount];
                }
                
                //spawn requests for reservebuttons and coverurls
                NSMutableArray* id_list = [NSMutableArray new];
                NSMutableArray* id_list_covers = [NSMutableArray new];
                for (SearchResultItem* item in searchResultItemsArray) {
                    if ([item.resultObject.identifier length]>0) {
                        [id_list addObject:item.resultObject.identifier];
                        [id_list_covers addObject:item.resultObject.coverId];
                    }
                }
                if ([id_list count]>0) {
                    DLog(@"id list sent to coverurl/getObjectExtras: %@",id_list);
                    [[LibraryXmlRpcClient instance] getCoverUrl:id_list_covers delegate:self];
                    [[LibraryXmlRpcClient instance] getObjectExtras:id_list delegate:self];
                    
                    /* alternative for chunking up cover requests
                    int chunkstart_index=0;
                    int chunk_len = 3;
                    while (chunkstart_index<[id_list count]) {
                        NSRange range;
                        range.location = chunkstart_index;
                        range.length = [id_list count]-chunkstart_index;
                        if (range.length>chunk_len) {
                            range.length=chunk_len;
                        }
                        NSArray* tempchunk = [id_list subarrayWithRange:range];
                        [[KKBXmlRpcClient instance] getObjectExtras:tempchunk delegate:self];
                        
                        chunkstart_index+=chunk_len;
                    }
                    */
                }

            }
		} else if ([[request method] isEqualToString:@"getCoverUrl"]) {
			DLog(@"getCoverUrl");
			NSDictionary* dict = [response object];
            if (![[LibraryXmlRpcClient instance] isValidSuccessArray:dict]) {
                ALog(@"ERROR: received failure array: %@", dict);
                return;
            }
			NSDictionary* datadict = [dict objectForKey:@"data"];
            EXPECT_OBJECT(NSDictionary, datadict);
            
			if (datadict!=nil && [datadict isKindOfClass:[NSDictionary class]]) {
				NSArray* cover_keys = [datadict allKeys];
				for (NSString* coverkey in cover_keys) {
					NSString* coverurl = [datadict objectForKey:coverkey];
                    SearchResultItem* sritem = nil; //was:[searchResultItemsDict objectForKey:coverkey];
					
                    for (sritem in searchResultItemsArray) {
                        if ([coverkey isEqualToString:sritem.resultObject.coverId]) {
                            if (sritem==nil || coverurl==nil || [coverurl length]==0) {
                                continue; //some error, so skip this one
                            }
                            //DLog(@"url: %@",coverurl);
                            [sritem updateCoverUrl:coverurl];
                            
                            break;
                        }
                    }
                    
                }
			} else {
				NSLog(@"ERROR: datadict was not a dictionary");
			}

			
		} else if ([[request method] isEqualToString:@"getObjectExtras"]) {
			DLog(@"getObjectExtras for array %@",[request parameters]);
            [loadingIndicator stopAnimating];
            
            //stop all loading indicators
            for (SearchResultItem* sritem2 in searchResultItemsArray) {
                [sritem2.loadingIndicator stopAnimating];
            }
            
            NSDictionary* dict = [response object];
            if (![[LibraryXmlRpcClient instance] isValidSuccessArray:dict]) {
                ALog(@"ERROR: received failure array: %@", dict);
                return;
            }
			NSDictionary* datadict = [dict objectForKey:@"data"];
            EXPECT_OBJECT(NSDictionary, datadict);
			//DLog(@"getCoverUrl: %@",datadict);
			if (datadict!=nil && [datadict isKindOfClass:[NSDictionary class]]) {
                //NSArray* objectextras = [datadict allValues];
                NSArray* extras_keys = [datadict allKeys];
                for (NSString* extraskey in extras_keys) {
					NSDictionary* extras_dict = [datadict objectForKey:extraskey];
					SearchResultItem* sritem = [searchResultItemsDict objectForKey:extraskey];
					
					if (sritem==nil || extras_dict==nil) {
						continue; //some error, so skip this one
					}
                    
					[sritem updateFromObjectExtras:extras_dict];
				}
			} else {
				NSLog(@"ERROR: datadict was not a dictionary");
			}

                /*
                if (objectextras!=nil && [objectextras count]>0) {
                    NSDictionary* extras_dict = [objectextras objectAtIndex:0];
                    if (extras_dict!=nil && [extras_dict isKindOfClass:[NSDictionary class]]) {
                        self.reservationId = [extras_dict objectForKey:@"reservationId"];
                        bool isReservable = [[extras_dict objectForKey:@"isReservable"] boolValue];
                        if (self.reservationId!=nil && [self.reservationId length]>0) {
                            self.reserveButton.hidden=NO;
                            if (!isReservable) {
                                self.reserveButton.enabled = NO;
                                [self.reserveButton setTitle:@"Ikke tilg." forState:UIControlStateDisabled];
                            }
                            self.reserveButton.layer.opacity=0.0;
                            [UIView animateWithDuration:0.2
                                                  delay:0 
                                                options:UIViewAnimationOptionAllowUserInteraction
                                             animations:^{
                                                 self.reserveButton.layer.opacity=1.0;
                                             } 
                                             completion:nil
                             ];
                        }
                    }
                }*/
        } else {
           ALog(@"Warning: response not handled!");
        }

	}
}


- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"request method %@: didFailWithError: %@",[request method], error);
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"request method %@: didReceiveAuthenticationChallenge",[request method]);
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
	NSLog(@"request method %@: didCancelAuthenticationChallenge",[request method]);
}

-(BOOL)request:(XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return NO;
}

@end
