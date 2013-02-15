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


#import "SearchDetailView.h"
#import "defines.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import "SearchResultItem.h"
#import "LazyLoadImageView.h"
#import "InfoObject.h"
#import "SearchDetailItem.h"
#import "NSString+LibUtils.h"
#import "InfoGalleriImageUrlUtils.h"
#import "AddReservationView.h"
#import "LibraryAppSetttings.h"
#import "BibSearchSingleton.h"

#ifdef REDIA_APP_USE_MORE_ABOUT_OPTION
#import "AboutDetailsViewController.h"
#endif


@implementation SearchDetailView

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize authorLabel;
@synthesize reserveButton;
@synthesize allInfoView;
@synthesize loadingIndicator;
@synthesize mainScroller;
@synthesize separator;
//@synthesize coverImageDownloaded;
@synthesize aboutButton;
@synthesize resultObject;

-(void)checkForUpdate{
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.view addGestureRecognizer:gest];
     
    items = nil;
    
    titleLabel.verticalAlign = MultiLineLabelVerticalAlignTop;
    authorLabel.verticalAlign = MultiLineLabelVerticalAlignBottom;

    //[allInfoView loadHTMLString:@"<body style=\"font-family:HelveticaNeue;background-color:#1e2526;color:#ffffff;padding:0px;margin:0px;\">" baseURL:nil];
    
    //self.coverImageDownloaded=FALSE;
    isObjectFetched=false;
    isObjectExtrasFetched=false;
    childrenListEndYPos=137;
    
#ifdef REDIA_APP_USE_MORE_ABOUT_OPTION
    UIImage* bg_stretch = [[aboutButton backgroundImageForState:UIControlStateNormal] stretchableImageWithLeftCapWidth:30 topCapHeight:15];
    [aboutButton setBackgroundImage:bg_stretch forState:UIControlStateNormal];
    
    bg_stretch = [[aboutButton backgroundImageForState:UIControlStateHighlighted] stretchableImageWithLeftCapWidth:30 topCapHeight:15];
    [aboutButton setBackgroundImage:bg_stretch forState:UIControlStateHighlighted];
#else
    aboutButton.hidden=YES;
#endif
    
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}



- (void)viewDidUnload {
    [self setAboutButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

    self.coverImageView=nil;
    self.titleLabel=nil;
    self.authorLabel=nil;
    self.reserveButton=nil;
    self.allInfoView=nil;
    self.loadingIndicator=nil;
    self.mainScroller=nil;
    self.separator=nil;
    //self.blackCoverView=nil;
}


- (void)dealloc {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

    //self.blackCoverView=nil;
    


    DLog(@"dealloced %x",(unsigned int) self);
}


- (void)updateFromResultObject:(SearchResultObject*)res
{
    [self view];
    
    self.resultObject = res;
    
    /*
    sdv.identifier = self.identifier;
    sdv.children = nil;
    //sdv.coverImage.image = self.coverImage.image; */
    if (res.coverImage!=nil) {
        self.coverImageView.image = res.coverImage;
    }
    
    if ([res.typeString isEqualToString:@"Collection"]) {
        self.aboutButton.hidden=YES;
    }
    
    self.titleLabel.text = res.origTitle;
    self.authorLabel.text = res.origAuthor;
    
    [self updateAllInfoView:nil];
    [self fetchDetails];

}

- (void)fetchDetails
{
    DLog(@"detailview catID: %@" , resultObject.identifier);
    DLog(@"detailview children: %@",resultObject.children);
    //call ws
    if (resultObject.identifier!=nil && [resultObject.identifier length]>0) {
        [[LibraryXmlRpcClient instance] getObject:resultObject.identifier delegate:self];
        NSArray* single_obj_array = [NSArray arrayWithObject:resultObject.identifier];
        [[LibraryXmlRpcClient instance] getCoverUrl:single_obj_array delegate:self];
        [[LibraryXmlRpcClient instance] getObjectExtras:single_obj_array delegate:self];

    } else {
        DLog(@"NO CATALOG ID");
        [loadingIndicator stopAnimating];
    }
    [self parseChildren];
   
}
- (void)recalculateScrollerSize:(bool)move_webview
{
    int y = childrenListEndYPos;
    CGRect av = allInfoView.frame;
    if (move_webview) {
        y += 9;
        av.origin.y = y; 
        allInfoView.frame = av;
    }
    
    y += av.size.height;
    
    [self.mainScroller setContentSize:CGSizeMake(320, y)];

}

- (void)parseChildren
{
    if (resultObject.children!=nil) {
        NSArray* newitems = nil;
        if ([resultObject.children isKindOfClass:[NSDictionary class]]) {
            DLog(@"dict");
            newitems = [(NSDictionary*)resultObject.children allValues];
        } else if ([resultObject.children isKindOfClass:[NSArray class]]) {
            DLog(@"array");
            newitems = (NSArray*) resultObject.children;
        } else {
            NSLog(@"ERROR: children not nil but neither array nor dict");
            return;
        }
        
        NSSortDescriptor* sortdesc = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray* sortdesc_array = [NSArray arrayWithObject:sortdesc];
        newitems = [newitems sortedArrayUsingDescriptors:sortdesc_array];
        
        /* dep
        if (items!=nil) {
            for (SearchResultItem* olditem in items) {
                olditem.superViewController=nil;
            }
        }
         */
        items = [NSMutableArray new];
        
        self.separator.hidden=[newitems count]==0;
        
        bool move_webview=false;
        
        NSMutableArray* children_extras_req = [NSMutableArray new];
        
        int y=137;
        int height = 112;
        for (NSDictionary* cur_item in newitems) {
            
            SearchDetailItem* sditem = [[SearchDetailItem alloc] initWithNibName:@"SearchDetailItem" bundle:nil];
            [items addObject:sditem];
            [self addChildViewController:sditem];
            //sritem.superViewController = self.superViewController;
            
            sditem.view.frame = CGRectMake(0, y, 320, height);
            
            sditem.resultObject = [SearchResultObject new];
            sditem.resultObject.origTitle = [InfoObject unescapeString:[cur_item objectForKey:@"title"]];
            
            sditem.bookTitle.text = sditem.resultObject.origTitle;
            
            NSString* authorstring = [[cur_item objectForKey:@"creator"] unescapedFromXML];
            sditem.resultObject.origAuthor=authorstring;
            sditem.bookAuthor.text = authorstring;
            
            sditem.resultObject.identifier = [cur_item objectForKey:@"identifier"];
            if (sditem.resultObject.identifier != nil && [sditem.resultObject.identifier length]>0) {
                [children_extras_req addObject:sditem.resultObject.identifier];
            }
            
            NSString* booktype = [cur_item objectForKey:@"type"];
            if (booktype!=nil && [booktype length]>0) {
                sditem.resultObject.typeString = booktype;
                sditem.typeLabel.hidden=NO;
                sditem.typeLabel.text=booktype;
            }
            
            NSString* resId = [cur_item objectForKey:@"reservationId"];
            if (resId!=nil && [resId length]>0) {
                sditem.resultObject.reservationId=resId;
                sditem.reserveButton.hidden=NO;
            }
            
            [self.mainScroller addSubview:sditem.view];
            
            move_webview=true;
            y += height;
        }
        
        if ([children_extras_req count]>0) {
            [[LibraryXmlRpcClient instance] getObjectExtras:children_extras_req delegate:self];
        }
        
        childrenListEndYPos = y;
        
        [self recalculateScrollerSize:move_webview];
        
    } else {
        DLog(@"NO CHILDREN");
        self.separator.hidden=YES;
    }
}

- (void)tabBarControllerSelected:(id)newController
{
}

- (IBAction)addReservation:(id)sender
{
    currentReservationView = [AddReservationView requestReservation:resultObject.reservationId withTitle:titleLabel.text delegate:self inNavigationController:self.navigationController];
    [[self.tabBarController selectedViewController].view addSubview:currentReservationView.view];
}

-(void)addReservationViewDismissed:(id)sender
{
    [currentReservationView.view removeFromSuperview];
    currentReservationView=nil;
}

- (IBAction)aboutButtonClicked:(id)sender {
    //allInfoView.hidden=YES;
#ifdef REDIA_APP_USE_MORE_ABOUT_OPTION

    AboutDetailsViewController* advc = [AboutDetailsViewController new];
    /*
    advc.superViewController = self.superViewController;
    [self.superViewController.view addSubview:[advc view]];
    [self.superViewController pushDetailView:advc.view withViewController:advc withFrame:CGRectMake(0, 44, 320, 411)];
     */
    [self.navigationController pushViewController:advc animated:YES];
    
    [advc updateFromResultObject:resultObject];
#endif
    
}

-(void)authenticationFailed {
}


- (void)authenticationSucceeded
{
	//moved to AddReservationView
}


- (void)updateAllInfoView:(NSArray*)new_items
{
    NSMutableArray* details_extra;
    if (new_items==nil || ![new_items isKindOfClass:[NSArray class]]) {
        details_extra = [NSMutableArray new]; 
    } else {
        details_extra = [new_items mutableCopy];
    }

    if (resultObject.date!=nil && [resultObject.date length]>0) {
        [details_extra addObject:[NSDictionary dictionaryWithObjectsAndKeys:resultObject.date,@"value",@"År",@"key",nil]];
    }
    if (resultObject.abstract!=nil && [resultObject.abstract length]>0) {
        [details_extra addObject:[NSDictionary dictionaryWithObjectsAndKeys:resultObject.abstract,@"value",@"Resumé",@"key",nil]];
    }
    
    if ([details_extra count]==0) {
        allInfoView.hidden=true;
        return;
    }
    
    NSMutableString* html = [NSMutableString new];
    [html appendString:@"<body style=\"font-family:HelveticaNeue;background-color:#1e2526;color:#ffffff;padding:0px;margin:0px;\">"
     "<div style=\"border: 1px solid #4a4a4a;"
     "border-top-left-radius: 5px;"
     "border-top-right-radius: 5px;"
     "border-bottom-right-radius: 5px;"
     "border-bottom-left-radius: 5px;"
     "-webkit-box-shadow: 1px 1px 4px #151515;padding:0px;margin:0px;width:296px;\">"
     "<table style=\"font-size:12;border-collapse:collapse;\">"
     "<col width=75px  /> <col width=225px\" />"];
    
    int rownum=0;
    for (NSDictionary* detail_dict in details_extra) {
        bool odd = ((rownum++) % 2);
        [html appendFormat:@"<tr %@><td style=\"text-align:right;color:#888888;padding-right:9px;vertical-align:top;\">%@</td>"
         "<td>%@</td></tr>",
         odd ? @"style=\"background-color:#293031;\"" : @"",
         [detail_dict objectForKey:@"key"],
         [detail_dict objectForKey:@"value"]
         
         ];
    }
    [html appendString:@"</table>"
     "</div><p id=\"end-marker\"></p>"
     "</body>" ];
    
    [allInfoView loadHTMLString:html baseURL:nil];
    //allInfoView.hidden=NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self performSelector:@selector(showAllInfoView:) withObject:nil afterDelay:0.51];
    NSString* retval =
    [self.allInfoView stringByEvaluatingJavaScriptFromString:@"var fpd = document.getElementById(\"end-marker\");"
                                                          "var fpx = 0; var fpy = 0; var offsetLeft = 0; var offsetTop = 0; "
                                                          "while (fpd){ offsetLeft += fpd.offsetLeft; offsetTop += fpd.offsetTop; fpd = fpd.offsetParent;} "
                                                          
                                                          "if (navigator.userAgent.indexOf('Mac') != -1 && typeof document.body.leftMargin != 'undefined'){"
                                                          "  offsetLeft += document.body.leftMargin;"
                                                          "  offsetTop += document.body.topMargin;"
                                                          "}"
                                                          "offsetTop;"];
	int offset = [retval intValue];
    DLog(@"offset: %d", offset);
    CGRect av_frame = allInfoView.frame;
    av_frame.size.height = offset;
    allInfoView.frame = av_frame;
    [self recalculateScrollerSize:false];
}

- (void)showAllInfoView:(id)sender
{
    allInfoView.hidden=NO;
}

- (void)checkLoadingIndicator
{
    if (isObjectFetched && isObjectExtrasFetched) {
        [loadingIndicator stopAnimating];
    } 
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
	} else {
		DLog(@"Parsed response for method %@: %@",[request method], [response object]);
		//NSLog(@"xml: %@", [response body]);
		
		if ([[request method] isEqualToString:@"getObject"]) {
            isObjectFetched=true;
            [self checkLoadingIndicator];
            
            DLog(@"getObject for %@",[request parameters]);
            NSDictionary* dict = [response object];
            if (![[LibraryXmlRpcClient instance] isValidSuccessArray:dict]) {
                ALog(@"ERROR: received failure array: %@", dict);
                return;
            }

            NSDictionary* datadict = [dict objectForKey:@"data"];
            EXPECT_OBJECT(NSDictionary, datadict);
            
            NSArray* details_list = [datadict objectForKey:@"formattedDetails"];
            NSString* newabstract = [datadict objectForKey:@"abstract"];
            if (newabstract!=nil && [newabstract length]>0) {
                resultObject.abstract=newabstract;
            }
            NSString* newdate = [datadict objectForKey:@"date"];
            if (newdate!=nil && [newdate length]>0) {
                resultObject.date=newdate;
            }
            
            resultObject.origTitle = [datadict objectForKey:@"title"];
            self.titleLabel.text = resultObject.origTitle;
            resultObject.origAuthor = [datadict objectForKey:@"creator"];
            self.authorLabel.text = resultObject.origAuthor;
            [self updateAllInfoView:details_list];
            
            resultObject.children = [datadict objectForKey:@"children"];
            
            [self parseChildren];
            
		} else if ([[request method] isEqualToString:@"getCoverUrl"]) {
			DLog(@"getCoverUrl");
			NSDictionary* dict = [response object];
			NSDictionary* datadict = [dict objectForKey:@"data"];
			//DLog(@"getCoverUrl: %@",datadict);
			if (datadict!=nil && [datadict isKindOfClass:[NSDictionary class]]) {
				NSArray* cover_urls = [datadict allValues];
				for (NSString* coverurl in cover_urls) {
				    if (coverurl!=nil && [coverurl length]>0) {
                        NSString* resizeurl_thumb = [InfoGalleriImageUrlUtils getResizedImageUrl:coverurl 
                                                                                         toWidth:[LibraryAppSetttings instance].isRetinaDisplay ? 80*2 : 80 
                                                                                        toHeight:[LibraryAppSetttings instance].isRetinaDisplay ? 117*2 : 117
                                                                                    usingQuality:4 
                                                                                        withMode:IMAGE_URL_UTILS_RESIZE_MODE_CROP_EDGES];
                        UIImageView* image_view = self.coverImageView;
                        [image_view setContentMode: UIViewContentModeScaleAspectFit];
                        
                        [LazyLoadImageView createLazyLoaderWithView:image_view 
                                                             url:[[NSURL alloc] initWithString:resizeurl_thumb]
                                                   animationTime:(resultObject.coverImageDownloaded ? 0.0 : 0.5)
                                                        delegate:self];
                        resultObject.coverImageDownloaded=TRUE;
                    }
				}
			} else {
				NSLog(@"ERROR: datadict was not a dictionary");
			}
        } else if ([[request method] isEqualToString:@"getObjectExtras"]) {
            isObjectExtrasFetched=true;
            [self checkLoadingIndicator];
			DLog(@"getObjectExtras for array %@",[request parameters]);
            //[loadingIndicator stopAnimating];
            NSDictionary* dict = [response object];
			NSDictionary* datadict = [dict objectForKey:@"data"];
			//DLog(@"getCoverUrl: %@",datadict);
			if (datadict!=nil && [datadict isKindOfClass:[NSDictionary class]]) {
               
                //pass on to sub items, if any
                for (SearchDetailItem* sditem in items) {
                    [sditem parseObjectExtras:datadict];
                }
                NSDictionary* extras_dict = [datadict objectForKey:resultObject.identifier];
                
                if (extras_dict!=nil && [extras_dict isKindOfClass:[NSDictionary class]]) {
                    resultObject.reservationId = [extras_dict objectForKey:@"reservationId"];
                    bool isReservable = [[extras_dict objectForKey:@"isReservable"] boolValue];
                    if (resultObject.reservationId!=nil && [resultObject.reservationId length]>0) {
                        self.reserveButton.hidden=NO;
                        
                        //move loadingindicator out of the way
                        CGRect l_i_frame = loadingIndicator.frame;
                        l_i_frame.origin.x -= reserveButton.frame.size.width + 5;
                        loadingIndicator.frame = l_i_frame;
                        
                        if (!isReservable) {
                            self.reserveButton.enabled = NO;
                            [self.reserveButton setTitle:@"Ikke tilg." forState:UIControlStateDisabled];
                        }
                        self.reserveButton.alpha=0.0;
                        [UIView animateWithDuration:0.2
                                              delay:0 
                                            options:UIViewAnimationOptionAllowUserInteraction
                                         animations:^{
                                             self.reserveButton.alpha=1.0;
                                         } 
                                         completion:nil
                         ];
                    }
                }
                
            }
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

-(void)imageLoaded:(UIImage *)theImage
{
    resultObject.coverImage=theImage;
}
-(void)loadImageError
{
    //do nothing
}

@end
