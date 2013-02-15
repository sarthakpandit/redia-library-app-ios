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


#import "ArrangementsView.h"
#import "defines.h"
#import "InfoGalleriImageUrlUtils.h"
#import "ArrangementItem.h"
#import <QuartzCore/QuartzCore.h>
#import "LazyLoadImageView.h"
#import "LibraryAuthenticationManager.h"
#import "LibraryAppSetttings.h"
#import "NewsDisplayViewController.h"
#import "BibSearchSingleton.h"

@implementation ArrangementsView

@synthesize itemScroller;
@synthesize loadingIndicator;
@synthesize items=_items;
@synthesize itemDetailContent=_itemDetailContent;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.itemScroller addGestureRecognizer:gest];
	
    [self updateItems];
    
    self.navigationController.delegate=self;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	DLog(@"didReceiveMemoryWarning");

    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [[ChannelFetchManager instance] unregisterDelegate:self];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.itemScroller=nil;

	self.loadingIndicator=nil;
}


- (void)dealloc {
    [[ChannelFetchManager instance] unregisterDelegate:self];
}

- (void)tabBarControllerSelected:(id)newController
{
    if (newController==self) {
		//[self checkForUpdate];
	}
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController==self) {
        //[self checkForUpdate];
	}
}

-(void)viewDidAppear:(BOOL)animated
{
    [self checkForUpdate];
}

-(void)checkForUpdate
{
    if ([[ChannelFetchManager instance] isRefreshNeeded]) {
        [self updateItems];
    }
}

- (void)removeOldItems
{
    if (self.items != nil) {
		for (ArrangementItem* item in self.items) {
			[item.view removeFromSuperview];
		}
		self.items=nil;
	}
	self.itemDetailContent=nil;
}

- (void)updateItems
{
	loadingIndicator.hidden=NO;
	[loadingIndicator startAnimating];
	
	[self removeOldItems];
	
	[[ChannelFetchManager instance] fetchChannels:self];
	//[self clearDetailView];
	
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[[BibSearchSingleton instance] somewhereElseClicked:self];
}

-(void)authenticationFailed {
}


- (void)authenticationSucceeded
{
	
}

- (void)channelFetchComplete:(NSArray*) infoObjects
{
	DLog(@"channelFetchComplete: %d",[infoObjects count]);
	
    [self removeOldItems];
    
	self.items = [NSMutableArray new];
	self.itemDetailContent = [NSMutableArray new];
	
    itemScroller.contentOffset=CGPointMake(0, 0);
    
	int index=0;
	int y=42;
	int itemheight = 82;
	
	for (InfoObject* inf in infoObjects) {
		if ([inf getType]!=INFOOBJECT_TYPE_ARRANGEMENT) {
			DLog(@"skipping non-arrangment element");
			continue;
		}

        NSString* mediaurl = @"";
		
		for (InfoMedia* m in [inf getMedia:@"dk"]) {
			if ( ! [[m mediaType] isEqualToString:@"image"]) {
				DLog(@"skipping video element");
				continue;
			}
			
			mediaurl = [m sourceURL];
			if ([mediaurl length]==0) {
				DLog(@"skipping image element with empty media url");
				continue;
			} else {
				//we found the first image - look no further
				break;
			}
		}
        
        ArrangementItem* newitem = [[ArrangementItem alloc] initWithNibName:@"ArrangementItem" bundle:nil];
        [itemScroller addSubview:newitem.view];

        if (mediaurl!=nil && [mediaurl length]>0) {
            NSString* resizeurl = [InfoGalleriImageUrlUtils getResizedImageUrl:mediaurl 
                                                                       toWidth:[LibraryAppSetttings instance].isRetinaDisplay ? 77*2 : 77 
                                                                      toHeight:[LibraryAppSetttings instance].isRetinaDisplay ? 77*2 : 77
                                                                  usingQuality:8 
                                                                      withMode:IMAGE_URL_UTILS_RESIZE_MODE_CROP_EDGES];
            NSURL* ns_resizeurl = [[NSURL alloc] initWithString:resizeurl];
            [LazyLoadImageView createLazyLoaderWithView:newitem.imageContent url:ns_resizeurl animationTime:0.2 delegate:nil];
        }
        
        NSString* headline = [inf getHeadline:@"dk"];
        NSString* head_trunc = headline; //was: [headline stringByTruncatingToRect:newitem.textContent.frame withFont:newitem.textContent.font];
        newitem.textContent.text = head_trunc;
        //[newitem.textContent sizeToFit];
        
        NSDate* arr_date = [inf getBeginDate:@"dk"];
        
        NSDateFormatter *dateFormat_out = [[NSDateFormatter alloc] init];
        
        [dateFormat_out setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"da_DK"]];
        
        [dateFormat_out setDateFormat:@"d. MMM yyyy"];
        
        // Create date string from formatter, using the current date
        NSString* dato = [dateFormat_out stringFromDate:arr_date];
        
        [dateFormat_out setDateFormat:@"HH:mm"];
        
        // Create date string from formatter, using the current date
        NSString* klokken = [dateFormat_out stringFromDate:arr_date];
        NSString* time_and_date = [NSString stringWithFormat:@"%@ kl. %@",dato,klokken];
        
        newitem.dateContent.text = time_and_date;
        
        
        newitem.view.frame = CGRectMake(0, y, 320, itemheight);
        newitem.view.tag = index;
        
        [self.items addObject:newitem];
        
        UITapGestureRecognizer* gest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
        [newitem.view addGestureRecognizer:gest2];
        [newitem.readMoreButton addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];

        y += itemheight;
		
        NSArray* locations = [inf getLocations:@"dk"];
        NSString* locationstring = @"";
        bool first_loc = true;
        for (NSString* next_location in locations) {
            if (first_loc) {
                locationstring = next_location;
                first_loc = false;
            } else {
                locationstring = [NSString stringWithFormat:@"%@, %@",locationstring, next_location];
            }
        }
        if ([locationstring length]>0) {
            locationstring = [NSString stringWithFormat:@"<p style=margin-bottom:-6px>%@, %@</p>",locationstring,time_and_date];
        } else {
            locationstring = [NSString stringWithFormat:@"<p style=margin-bottom:-6px>%@</p>",time_and_date];
        }
        
        
        NSString* text = [[NSString alloc]
                          initWithFormat:@"<head><style type=\"text/css\">"
						  "a:link {color:#dddddd;} a:visited {color:#dddddd;} a:hover {color:#888888;} a:active {color:#666666;}"
						  "</style></head>"
                          "<body style=\"background-color:%@;color:#ffffff; font-family:helvetica neue,arial,sans-serif;font-size:%dpx\">"
                          "<p style=font-size:24px;margin-bottom:-6px><b>%@</b></p>"
                          "%@"
                          "<p><img src=\"webpage-divider.png\"></p>"
                          "<p style=font-size:14px><b>%@</b></p>"
                          "<div> <div style=float:right;margin-left:6px;margin-bottom:6px;margin-top:2px> "
                          "<img src=\"%@\" style=max-width:137px;></div>"
                          "%@</div>",
                          [LibraryAppSetttings instance].customerBackgroundColorHTML,
                          [[LibraryAppSetttings instance] getBodyFontSize],
                          [inf getHeadline:@"dk"],
                          locationstring,
                          [inf getSubHeadline:@"dk"],
                          [mediaurl length]==0 ? @"" : [InfoGalleriImageUrlUtils getResizedImageUrl:mediaurl 
                                                                                            toWidth:[LibraryAppSetttings instance].isRetinaDisplay ? 137*2 : 137
                                                                                           toHeight:[LibraryAppSetttings instance].isRetinaDisplay ? 205*2 : 205
                                                                                       usingQuality:8],
                          [inf getBody:@"dk"]
                          ];
        //NSLog(@"%@",text);
        [self.itemDetailContent addObject:text];
        
        index++;
	}
	itemScroller.contentSize = CGSizeMake(320, y);
	[loadingIndicator stopAnimating];
}

-(void)channelFetchError:(NSError *)error
{
    //TODO: handle error
}

- (void)itemTapped:(id)sender
{
    [[BibSearchSingleton instance] somewhereElseClicked:sender];
    
    UIView* senderview = nil;
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        senderview = [sender view];
    } else if ([sender isKindOfClass:[UIButton class]]) {
        senderview = [sender superview];
    }
	
    if (senderview != nil) {
		int index = [senderview tag];
		DLog(@"tapped tag %d", index);
		
		if (index>=0 && index<[self.itemDetailContent count] && [self.itemDetailContent count]>0) {
            
            NewsDisplayViewController* newsdisp = [NewsDisplayViewController new];
            [newsdisp showHTML:[self.itemDetailContent objectAtIndex:index]];
            [self.navigationController pushViewController:newsdisp animated:YES];

        }
	}
}


@end
