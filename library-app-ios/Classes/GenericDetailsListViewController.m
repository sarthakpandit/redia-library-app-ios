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


#import "GenericDetailsListViewController.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import "defines.h"
#import "BibSearchSingleton.h"
#import "SearchResultItem.h"
#import "LibraryAppSetttings.h"
#import "WebTextLength.h"
#import "ReadMoreLinkViewController.h"
#import "ReviewsListItemViewController.h"
#import "LibraryAppSetttings.h"

#ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
#error This file must only be included in targets with REDIA_APP_USE_MORE_ABOUT_OPTION defined
#endif

@interface GenericDetailsListViewController ()

@end

@implementation GenericDetailsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIGestureRecognizer* gest = [[UITapGestureRecognizer alloc] initWithTarget:[BibSearchSingleton instance] action:@selector(somewhereElseClicked:)];
	[gest setDelaysTouchesBegan:NO];
	[gest setCancelsTouchesInView:NO];
	[self.view addGestureRecognizer:gest];

}


- (void)updateWithAboutAuthorExternals:(LibraryExternals*)externals
{
    currentExternals=externals;
    
    if (externals.hasAboutAuthor) {
        //matching for android Externals.rewriteAuthorDescription
        // Nuke lines like this: <p class="faustnr">28511663
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"<p class.*[0-9]{7,8}" options:0 error:nil];
        
        NSMutableString* mutabletext = [externals.aboutAuthorDescription mutableCopy];
        
        [regex replaceMatchesInString:mutabletext options:0 range:NSMakeRange(0, [mutabletext length]) withTemplate:@""];
        
        [mutabletext replaceOccurrencesOfString:@"Blå bog"
                                     withString:@"<span style=\"display:block; margin: 10px 0px 0px 0px;\" id=\"bluebook\">Blå bog</span><img style=\"margin:10px 0px 10px 0px;\" width=\"100%\" class=\"button_image\" src=\"webpage-divider.png\">"
                                        options:0
                                          range:NSMakeRange(0, [mutabletext length])];
        
        [mutabletext replaceOccurrencesOfString:@"<strong>" withString:@"<br><strong>" options:0 range:NSMakeRange(0, [mutabletext length])];
        
        NSString* text = [[NSString alloc]
						  initWithFormat:
                          @"<head><style type=\"text/css\">"
                          "#bluebook { font-size:14px; }"
                          "body { color:#ffffff; font-family:helvetica neue,arial,sans-serif;font-size:12px }"
                          "</style></head>"
                          "<body style=\"background-color:#1e2526;color:#ffffff; font-family:helvetica neue,arial,sans-serif;font-size:13px;margin:0;padding:0;\">"
						  "<p style=font-size:24px;margin-bottom:-6px><b>%@</b></p>"
						  "<p>%@</p>"
						  //"<p style=\"margin-left:-10px\"><img src=\"separator.png\"></p>"
                          "<div id=\"end-marker\">",
						  externals.aboutAuthorName,
						  mutabletext
						  ];
        [self.theWebView loadHTMLString:text baseURL:[[NSBundle mainBundle] bundleURL]];

        readMoreButtons = [NSMutableArray new];
        CGFloat buttonheight = 62;
        CGFloat current_y = self.view.frame.size.height - [currentExternals.aboutAuthorUrls count]*buttonheight;
        
        for (LibraryExternalsUrl* url in currentExternals.aboutAuthorUrls) {
            
            ReadMoreLinkViewController* rmlvc = [ReadMoreLinkViewController new];
            rmlvc.view.frame = CGRectMake(0, current_y, 320, buttonheight);
            [self.view addSubview:rmlvc.view];
            [readMoreButtons addObject:rmlvc];
            [self addChildViewController:rmlvc];
            
            rmlvc.titleLabel.text = url.title;
            rmlvc.url = url.url;
            
            current_y += 62;
            DLog(@"added readmore button");
        }
    }
}

-(void)viewDidLayoutSubviews
{
    if ([readMoreButtons count]>0) {
        
    
        CGFloat buttonheight = 62;
        CGFloat current_y = self.view.frame.size.height - [readMoreButtons count]*buttonheight;
        CGRect scrollerframe = self.mainScroller.frame;
        scrollerframe.size.height = current_y-scrollerframe.origin.y;
        
        CGRect gradientframe = self.webViewBottomGradient.frame;
        gradientframe.origin.y = current_y - gradientframe.size.height;
        self.webViewBottomGradient.frame = gradientframe;
        
        self.mainScroller.frame=scrollerframe;
        for (ReadMoreLinkViewController* rmlvc in readMoreButtons) {
            rmlvc.view.frame = CGRectMake(0, current_y, 320, buttonheight);
            current_y += 62;
            DLog(@"layouted readmore button");
        }
        
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.theWebView.hidden=NO;
    self.webViewBottomGradient.hidden=NO;
    float height = [WebTextLength measureWebBoxHeight:self.theWebView forMarker:@"end-marker"];
    
    CGRect webframe = self.theWebView.frame;
    webframe.size.height = height;
    self.theWebView.frame = webframe;
    
    
    CGFloat current_y = webframe.origin.y + height;
    /* moved
    for (LibraryExternalsUrl* url in currentExternals.aboutAuthorUrls) {
        
        ReadMoreLinkViewController* rmlvc = [ReadMoreLinkViewController new];
        rmlvc.view.frame = CGRectMake(0, current_y, 320, 62);
        [self.mainScroller addSubview:rmlvc.view];
        [readMoreButtons addObject:rmlvc];
        [self addChildViewController:rmlvc];
        
        rmlvc.titleLabel.text = url.title;
        rmlvc.url = url.url;
        
        current_y += 62;
    } */
    [self.mainScroller setContentSize:CGSizeMake(320, current_y)];
     
}

- (void)updateWithSearchResultRecords:(NSArray*)records
{
    [self performSelector:@selector(updateWithSearchResultRecordsDelayed:) withObject:records afterDelay:0];
}

-(void)updateWithSearchResultRecordsDelayed:(NSArray *)records
{
    EXPECT_OBJECT(NSArray, records);
    
    int y=54;
    int height = 138;
    
    searchResultItemsArray = [NSMutableArray new];
    searchResultItemsDict = [NSMutableDictionary new];
    
    for (NSDictionary* cur_item in records) {
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
        
        [self.mainScroller addSubview:sritem.view];
        
        y += height;
        
    }
    
    [self.mainScroller setContentSize:CGSizeMake(320, y)];
    
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
        
    }
}

-(void)updateWithReviewsExternals:(NSArray*)reviewExternals
{
    EXPECT_OBJECT(NSArray, reviewExternals);
    
    int y=54;
    int height = 150;
    
    for (LibraryExternalsReviewItem* rev_item in reviewExternals) {
        EXPECT_OBJECT(LibraryExternalsReviewItem, rev_item);
        
        ReviewsListItemViewController* rlivc = [ReviewsListItemViewController new];
        [self addChildViewController:rlivc];
        rlivc.view.frame = CGRectMake(0, y, 320, height);

        [self.mainScroller addSubview:rlivc.view];

        
        
        NSString* html;
        if ([rev_item.source isEqualToString:@"litteratursiden"]) {
            rlivc.externUrl = rev_item.url;
            html = [NSString stringWithFormat:
                    @"<head><style type=\"text/css\">"
                    "a:link {color:#dddddd;} a:visited {color:#dddddd;} a:hover {color:#888888;} a:active {color:#666666;}"
                    "</style></head>"
                    "<body style=\"color:#ffffff;background:#1e2526;font-family:helvetica neue,arial;font-size:12px;padding:0;margin:0;\">"
                    "<img src=\"litteratursiden-logo%2$@.png\" style=\"max-height:19px;padding-top:10px;padding-bottom:10px;\"><br>"
                    "%1$@",
                    
                    rev_item.review,
                    [LibraryAppSetttings instance].isRetinaDisplay ? @"@2x" : @""
                    
                    ];
        } else {
            html = [NSString stringWithFormat:
                          @"<head><style type=\"text/css\">"
						  "a:link {color:#dddddd;} a:visited {color:#dddddd;} a:hover {color:#888888;} a:active {color:#666666;}"
                          ".infomedia_HeadLine { visibility:hidden; max-height:0;}"
                          ".infomedia_SubHeadLine { visibility:hidden; max-height:0;}"
                          ".infomedia_ByLine { visibility:hidden;max-height:0;}"
                          ".infomedia_DateLine { visibility:hidden;max-height:0;}"
                          ".infomedia_paper { text-transform:uppercase; color:#618335;font-weight:bold;height:50px;}" // margin-top:-8px;
						  "</style></head>"
                          "<body style=\"color:#ffffff;background:#1e2526;font-family:helvetica neue,arial;font-size:12px;padding:0;margin:0;\">"
                          "%1$@"
                          "<div style=\"position:absolute;left:0px;top:24px;\"><img src=\"infomedia-logo-transp%2$@.png\" style=\"max-height:19px;\"></div>" //padding-top:10px;padding-bottom:-10px;
                          ,
                          
                          rev_item.review,
                          [LibraryAppSetttings instance].isRetinaDisplay ? @"@2x" : @""
                          
                          ];
        }
        
        DLog(@"html: %@",html);
        
        [rlivc.theWebView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
        rlivc.unStyledWebText = rev_item.review;
        
        y += height;
    }

    [self.mainScroller setContentSize:CGSizeMake(320, y)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
    
    [self setMainScroller:nil];
    [self setTitleLabel:nil];
    [self setTheWebView:nil];
    [self setWebViewBottomGradient:nil];
    [super viewDidUnload];
    
}
-(void)dealloc
{
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
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
        
        /* no need for alerting here
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fejl i søgning"
                                                        message:@"Serveren kunne desværre ikke gennemføre søgningen."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
         */
        return;
        
	} else {
		DLog(@"Parsed response for method %@: %@",[request method], [response object]);
		//NSLog(@"xml: %@", [response body]);
		
        if ([[request method] isEqualToString:@"getCoverUrl"]) {
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
            //[loadingIndicator stopAnimating];
            
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
