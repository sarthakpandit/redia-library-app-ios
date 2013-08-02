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
    

/* TODO:
 add general loading indicator
 maybe back button on detail view
 */

#import "BibStoreView.h"
#import "defines.h"
#import "InfoGalleriImageUrlUtils.h"
#import "BibStoreItem.h"
#import <QuartzCore/QuartzCore.h>
#import "LazyLoadImageView.h"
#import "LibraryAuthenticationManager.h"
#import "LibraryXmlRpcClient.h"
#import "DefaultImageSingleton.h"
#import "SearchDetailView.h"
#import "LibraryAppSetttings.h"
#import "NewsDisplayViewController.h"
#import "BibSearchSingleton.h"

@implementation BibStoreView

@synthesize featureImage1;
@synthesize featureImage2;
@synthesize featureImage3;
@synthesize featureImage4;

@synthesize featureHeadline1;
@synthesize featureHeadline2;
@synthesize featureHeadline3;
@synthesize featureHeadline4;

@synthesize itemScroller;
@synthesize loadingIndicator;
@synthesize currentReservationCatalogID;
@synthesize items=_items;
@synthesize itemDetailContent=_itemDetailContent;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    

	UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.view addGestureRecognizer:gest];
		
	    
    self.featureHeadline1.verticalAlign = MultiLineLabelVerticalAlignBottom;
    self.featureHeadline2.verticalAlign = MultiLineLabelVerticalAlignBottom;
    self.featureHeadline3.verticalAlign = MultiLineLabelVerticalAlignBottom;
    self.featureHeadline4.verticalAlign = MultiLineLabelVerticalAlignBottom;
    
	[self updateItems];
    
    self.navigationController.delegate = self;
}


-(void)viewDidLayoutSubviews
{
    if (!splashHasBeenShown) {
        int splashheight = 15;
        CGRect splashframe = CGRectMake(0, self.view.bounds.size.height-splashheight, self.view.bounds.size.width, splashheight);
        //CGRect splash_animframe = splashframe;
        //splash_animframe.origin.y += splashheight;
        UILabel* versionsplash = [[UILabel alloc] initWithFrame:splashframe];
        NSString* splashtext = [NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        [versionsplash setText:splashtext];
        [versionsplash setBackgroundColor:[UIColor clearColor]]; //[UIColor colorWithRed:0.106 green:0.133 blue:0.137 alpha:0.5]];
        [versionsplash setTextColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
        versionsplash.font = [UIFont systemFontOfSize:12];
        /*
         versionsplash.shadowColor = [UIColor blackColor];
         versionsplash.shadowOffset = CGSizeMake(1, 1);
         */
        versionsplash.textAlignment = UITextAlignmentRight;
        //versionsplash.layer.opacity=1.0;
        [self.view addSubview:versionsplash];
        [UIView animateWithDuration:3.0
                              delay:2.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             versionsplash.layer.opacity=0.0;
                             //versionsplash.frame = splash_animframe;
                         }
                         completion:^(BOOL finished) {
                             [versionsplash removeFromSuperview];
                         }
         ];
        splashHasBeenShown=YES;
    }
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
	featureImage1.image=nil;
	featureImage2.image=nil;
	featureImage3.image=nil;
	featureImage4.image=nil;
    
    featureHeadline1.text=@"";
    featureHeadline2.text=@"";
    featureHeadline3.text=@"";
    featureHeadline4.text=@"";
	
	if (self.items != nil) {
		for (BibStoreItem* item in self.items) {
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

-(void)authenticationFailed {
}

- (void)authenticationSucceeded
{
    
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
	self.featureImage1=nil;
	self.featureImage2=nil;
	self.featureImage3=nil;
	self.featureImage4=nil;
	
	self.featureHeadline1=nil;
	self.featureHeadline2=nil;
	self.featureHeadline3=nil;
	self.featureHeadline4=nil;
	
	self.itemScroller=nil;
	self.loadingIndicator=nil;
	
}


- (void)dealloc {
	[[ChannelFetchManager instance] unregisterDelegate:self];

}

- (void)arrayInsertionHelper:(id)obj insertAtIndex:(int)idx inArray:(NSMutableArray*)array
{
    if (obj!=nil && array!=nil) {
        idx = MIN(idx, [array count]);
        
        [array insertObject:obj atIndex:idx];
    }
}

- (void)channelFetchComplete:(NSArray*) infoObjects
{
	DLog(@"channelFetchComplete: %d",[infoObjects count]);
	
    [self removeOldItems];
	
    self.items = [NSMutableArray new];
	self.itemDetailContent = [NSMutableArray new];

    itemScroller.contentOffset=CGPointMake(0, 0);

	int index=0;
	int y=260;
	int itemheight = 82;
	imageCounter = [[LoadImageCounter alloc] initWithMaxCount:5 delegate:self];
    
    NSMutableArray* sorted_infoobjects = [NSMutableArray new];
    InfoObject* feature1=nil;
    InfoObject* feature2=nil;
    InfoObject* feature3=nil;
    InfoObject* feature4=nil;
    
    for (InfoObject* inf in infoObjects) {
        NSString* category = [inf getCategory:@"dk"];
        if (category!=nil) {
            if ([category isEqualToString:@"Mobil App kvadrat 1"] && feature1==nil) {
                feature1=inf;
            } else if ([category isEqualToString:@"Mobil App kvadrat 2"] && feature2==nil) {
                feature2=inf;
            } else if ([category isEqualToString:@"Mobil App kvadrat 3"] && feature3==nil) {
                feature3=inf;
            } else if ([category isEqualToString:@"Mobil App kvadrat 4"] && feature4==nil) {
                feature4=inf;
            } else {
                [sorted_infoobjects addObject:inf];
            }
        }
    }
	
    [self arrayInsertionHelper:feature1 insertAtIndex:0 inArray:sorted_infoobjects];
    [self arrayInsertionHelper:feature2 insertAtIndex:1 inArray:sorted_infoobjects];
    [self arrayInsertionHelper:feature3 insertAtIndex:2 inArray:sorted_infoobjects];
    [self arrayInsertionHelper:feature4 insertAtIndex:3 inArray:sorted_infoobjects];
    
	for (InfoObject* inf in sorted_infoobjects) {
		if ([inf getType]!=INFOOBJECT_TYPE_STANDARD) {
			DLog(@"skipping non-standard element");
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
		
		if (index<4) {
			UITapGestureRecognizer* gest1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
			
			UIImageView* curr_view = nil;
			HeavyShadowLabel* curr_label = nil;
            
			switch (index) {
				default:
				case 0:
					curr_view = featureImage1;
                    curr_label = featureHeadline1;
					break;
				case 1:
					curr_view = featureImage2;
                    curr_label = featureHeadline2;
					break;
				case 2:
					curr_view = featureImage3;
                    curr_label = featureHeadline3;
					break;
				case 3:
					curr_view = featureImage4;
                    curr_label = featureHeadline4;
					break;
			}
			if (mediaurl==nil || [mediaurl length]==0) {
				curr_view.image = [[DefaultImageSingleton instance] getDefaultImage];
				curr_view.contentMode = UIViewContentModeScaleToFill;
				[imageCounter skipOne];
			} else {
                NSString* resizeurl = [InfoGalleriImageUrlUtils getResizedImageUrl:mediaurl 
                                                                           toWidth:[LibraryAppSetttings instance].isRetinaDisplay ? 153*2 : 153
                                                                          toHeight:[LibraryAppSetttings instance].isRetinaDisplay ? 103*2 : 103 
                                                                      usingQuality:8 
                                                                          withMode:IMAGE_URL_UTILS_RESIZE_MODE_CROP_EDGES];
                NSURL* ns_resizeurl = [[NSURL alloc] initWithString:resizeurl];

				//was: [[LazyLoadImageView alloc] initWithView:curr_view url:ns_resizeurl animationTime:0 delegate:imageCounter];
                [LazyLoadImageView createLazyLoaderWithView:curr_view url:ns_resizeurl animationTime:0 delegate:imageCounter];
			}

			[curr_view addGestureRecognizer:gest1];
			curr_view.layer.opacity=0.0;
            
            [curr_label setText:[inf getHeadline:@"dk"]];
            curr_label.layer.opacity=0.0;
            
		} else {
			
			BibStoreItem* newitem = [[BibStoreItem alloc] initWithNibName:@"BibStoreItem" bundle:nil];
			[itemScroller addSubview:newitem.view];
			
			if (mediaurl==nil || [mediaurl length]==0) {
				//newitem.imageContent.image = [[DefaultImageSingleton instance] getDefaultImage];
				//newitem.imageContent.contentMode = UIViewContentModeScaleToFill;
                //don't show anything
			} else {
                NSString* resizeurl = [InfoGalleriImageUrlUtils getResizedImageUrl:mediaurl 
                                                                           toWidth:[LibraryAppSetttings instance].isRetinaDisplay ? 77*2 : 77 
                                                                          toHeight:[LibraryAppSetttings instance].isRetinaDisplay ? 77*2 : 77 
                                                                      usingQuality:8 
                                                                          withMode:IMAGE_URL_UTILS_RESIZE_MODE_CROP_EDGES];
                NSURL* ns_resizeurl = [[NSURL alloc] initWithString:resizeurl];
				[LazyLoadImageView createLazyLoaderWithView:newitem.imageContent url:ns_resizeurl animationTime:index*0.1 delegate:nil];
			}
			
			NSString* headline = [inf getHeadline:@"dk"];
			NSString* head_trunc = headline; //was: [headline stringByTruncatingToRect:newitem.textContent.frame withFont:newitem.textContent.font];
			newitem.textContent.text = head_trunc;
			//[newitem.textContent sizeToFit];
			
			newitem.view.frame = CGRectMake(0, y, 320, itemheight);
			newitem.view.tag = index;
			newitem.view.layer.opacity = 0.0;
			
			[self.items addObject:newitem];
			
			UITapGestureRecognizer* gest2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
			[newitem.view addGestureRecognizer:gest2];
			[newitem.readMoreButton addTarget:self action:@selector(itemTapped:) forControlEvents:UIControlEventTouchUpInside];
            
			y += itemheight;
		}
		
		NSString* reserve_button_html = @"";
        /* FUNCTIONALITY DISABLED BECAUSE OF LACKING IMPL IN BACKEND, AND PROBLEM WITH DETAILVIEWSTACK ON IOS
		NSDictionary* metadata = [inf getMetaData:@"dk"];
		if (metadata!=nil) {
			NSString* faustid = [metadata objectForKey:@"reserver"];
			if (faustid!=nil && ![faustid isEqualToString:@""]) {
				reserve_button_html = [NSString stringWithFormat:@"<a href=\"/reserver/%@\"><img src=\"webpage-reserver-button%@.png\" style=\"margin-bottom:5px;max-width:137px\"></a><br>",
                                       faustid,
                                       [LibraryAuthenticationManager instance].isRetinaDisplay ? @"@2x" : @""];
			}
		}
         */
		
		//DLog(@"body html from IG server: %@",[inf getBody:@"dk"]);
        
        int detail_imagewidth = [LibraryAppSetttings instance].isRetinaDisplay ? 137*2 : 137;
        int detail_imageheight = [LibraryAppSetttings instance].isRetinaDisplay ? 205*2 : 205;
		
		NSString* text = [[NSString alloc]
						  initWithFormat:@"<head><style type=\"text/css\">"
						  "a:link {color:#dddddd;} a:visited {color:#dddddd;} a:hover {color:#888888;} a:active {color:#666666;}"
						  "</style></head>"
						  "<body style=\"background-color:%@;color:#ffffff; font-family:helvetica neue,arial,sans-serif;font-size:%dpx\">"
						  "<p style=font-size:24px;margin-bottom:-6px><b>%@</b></p>"
						  "<p><img src=\"webpage-divider.png\"></p>"
						  "<p style=font-size:14px><b>%@</b></p>"
						  "<div> <div style=\"float:right;margin-left:6px;margin-bottom:6px;margin-top:2px\"> "
						  "%@"
						  "<img src=\"%@\" style=max-width:137px;></div>"
						  "%@</div>",
                          [LibraryAppSetttings instance].customerBackgroundColorHTML,
                          [[LibraryAppSetttings instance] getBodyFontSize],
						  [inf getHeadline:@"dk"],
						  [inf getSubHeadline:@"dk"],
						  reserve_button_html,
						  [mediaurl length]==0 ? @"" : [InfoGalleriImageUrlUtils getResizedImageUrl:mediaurl toWidth:detail_imagewidth toHeight:detail_imageheight usingQuality:8],
						  [inf getBody:@"dk"]
						  ];
		//DLog(@"\n\nCombined html: %@",text);
		[self.itemDetailContent addObject:text];
		
		index++;
	}
    
	itemScroller.contentSize = CGSizeMake(320, y);
	
	//TODO: this could be more elegant
    while (index<4) {
        [imageCounter imageLoaded:nil]; //we need to go all the way here before the final notify (no. 5) enables animation
        index++;
    }
	[imageCounter imageLoaded:nil]; //we need to go all the way here before the final notify (no. 5) enables animation
}

-(void)channelFetchError:(NSError *)error
{
    //TODO: handle error
}

- (void)notifyCountReached:(LoadImageCounter*)sender errorCount:(int)errors 
{
	[loadingIndicator stopAnimating];

	[UIView animateWithDuration:0.3 
						  delay:0.0 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{ self.featureImage1.layer.opacity=1.0; self.featureHeadline1.layer.opacity=1.0; } 
					 completion:nil];
	[UIView animateWithDuration:0.5 
						  delay:0.0 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{ self.featureImage2.layer.opacity=1.0; self.featureHeadline2.layer.opacity=1.0; } 
					 completion:nil];
	[UIView animateWithDuration:0.5 
						  delay:0.2 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{ self.featureImage3.layer.opacity=1.0; self.featureHeadline3.layer.opacity=1.0; } 
					 completion:nil];
	[UIView animateWithDuration:0.5 
						  delay:0.4 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{ self.featureImage4.layer.opacity=1.0; self.featureHeadline4.layer.opacity=1.0; } 
					 completion:nil];
	
	
	int index=0;
	for (UIViewController* v in self.items) {
		[UIView animateWithDuration:0.5 
							  delay:0.25+index*0.25 
							options:UIViewAnimationOptionAllowUserInteraction 
						 animations:^{ v.view.layer.opacity=1.0; } 
						 completion:nil];
		index++;
	}
}


- (void)itemTapped:(id)sender
{
    [[BibSearchSingleton instance] somewhereElseClicked:self];
    
	UIView* senderview = nil;
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        senderview = [sender view];
    } else if ([sender isKindOfClass:[UIButton class]]) {
        senderview = [sender superview];
    }
    
	if (senderview != nil) {
		int index = [senderview tag];
		//DLog(@"tapped tag %d", index);
		
		if (index>=0 && index<[self.itemDetailContent count] && [self.itemDetailContent count]>0) {
			//DLog(@"path: %@",path);
            
            NewsDisplayViewController* newsdisp = [NewsDisplayViewController new];
            [newsdisp showHTML:[self.itemDetailContent objectAtIndex:index]];
            [self.navigationController pushViewController:newsdisp animated:YES];
            
        }
	}
}




- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    /* FUNCTIONALITY DISABLED BECAUSE OF LACKING IMPL IN BACKEND, AND PROBLEM WITH DETAILVIEWSTACK ON IOS
	NSString* faust = [[request URL] lastPathComponent];
	NSString* command = [[[request URL] URLByDeletingLastPathComponent] lastPathComponent];
     */
	NSString* scheme = [[request URL] scheme];
	
    /* FUNCTIONALITY DISABLED BECAUSE OF LACKING IMPL IN BACKEND, AND PROBLEM WITH DETAILVIEWSTACK ON IOS
     DLog(@"faust: %@ command %@ scheme: %@",faust,command,scheme);
     */
	if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] ||  [scheme isEqualToString:@"mailto"] || [scheme isEqualToString:@"tel"]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return FALSE;
	} 
    /* FUNCTIONALITY DISABLED BECAUSE OF LACKING IMPL IN BACKEND, AND PROBLEM WITH DETAILVIEWSTACK ON IOS
      else if ([command isEqualToString:@"reserver"] && ![faust isEqualToString:@""]) {
		self.currentReservationCatalogID = faust;
        
        SearchDetailView* sdv = [[[SearchDetailView alloc] initWithNibName:nil bundle:nil] autorelease];
        //sdv.superViewController = self.superViewController;
        [self.view addSubview:[sdv view]];
        [self pushDetailView:sdv.view withViewController:sdv withFrame:CGRectMake(0, 44, 320, 365)];
        sdv.identifier = faust;
        sdv.children = nil;
        //sdv.coverImage.image = self.coverImage.image;
        sdv.titleLabel.text = @"";
        sdv.authorLabel.text = @"Henter...";
        [sdv fetchDetails];

		return FALSE;
	}
     */
	return TRUE;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [[BibSearchSingleton instance] somewhereElseClicked:self];
}

@end
