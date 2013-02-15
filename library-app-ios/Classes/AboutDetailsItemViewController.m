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


#ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
#error This file must only be included in targets with REDIA_APP_USE_MORE_ABOUT_OPTION defined
#endif

#import "AboutDetailsItemViewController.h"
#import "LibraryAppSetttings.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "LibraryAuthenticationManager.h"
#import "defines.h"
#import "BibSearchSingleton.h"
#import "GenericDetailsListViewController.h"

@interface AboutDetailsItemViewController ()

@end

@implementation AboutDetailsItemViewController

@synthesize backgroundView;
@synthesize superViewController;
@synthesize externalsObject;
@synthesize hasValidExternals;

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)discloseButtonClicked:(id)sender {
    if (hasValidExternals) {
        if ([externalsKey isEqualToString:@"series"]) {
            GenericDetailsListViewController* gdlvc2 = [GenericDetailsListViewController new];
            [gdlvc2 view];
            gdlvc2.titleLabel.text = @"Andre i serien";
            [gdlvc2 updateWithSearchResultRecords:externalsObject.seriesDictionaries];
            [self.navigationController pushViewController:gdlvc2 animated:YES];
        } else if ([externalsKey isEqualToString:@"reviews"]) {
            GenericDetailsListViewController* gdlvc5 = [GenericDetailsListViewController new];
            [gdlvc5 view];
            gdlvc5.titleLabel.text = @"Anmeldelser";
            [gdlvc5 updateWithReviewsExternals:externalsObject.reviewItems];
            [self.navigationController pushViewController:gdlvc5 animated:YES];

        } else if ([externalsKey isEqualToString:@"adhl"]) {
            GenericDetailsListViewController* gdlvc3 = [GenericDetailsListViewController new];
            [gdlvc3 view];
            gdlvc3.titleLabel.text = @"Andre har også lånt";
            [gdlvc3 updateWithSearchResultRecords:externalsObject.adhlDictionaries];
            [self.navigationController pushViewController:gdlvc3 animated:YES];
        } else if ([externalsKey isEqualToString:@"aboutauthor"]) {
            GenericDetailsListViewController* gdlvc4 = [GenericDetailsListViewController new];
            [gdlvc4 view];
            gdlvc4.titleLabel.text = @"Om forfatteren";
            [gdlvc4 updateWithAboutAuthorExternals:externalsObject];
            [self.navigationController pushViewController:gdlvc4 animated:YES];
        } else if ([externalsKey isEqualToString:@"othersbyauthor"]) {
            GenericDetailsListViewController* gdlvc = [GenericDetailsListViewController new];
            [gdlvc view];
            gdlvc.titleLabel.text = @"Andet af...";
            [gdlvc updateWithSearchResultRecords:externalsObject.othersByAuthorDictionaries];
            [self.navigationController pushViewController:gdlvc animated:YES];
        }

    }

}

- (void)viewDidUnload {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
    
    [self setBackgroundView:nil];
    [self setIconView:nil];
    [self setButtonDescription:nil];
    [self setLoadingIndicator:nil];
    [self setDiscloseButton:nil];
    [self setNoContentLabel:nil];
    [self setLoadingLabel:nil];
    [super viewDidUnload];
}

-(void)fetchDataForExternalsKey:(NSString *)k identifier:(NSString *)obj_id
{
    externalsKey = k;
    
    NSArray* param_id = [NSArray arrayWithObject:obj_id];

    [[LibraryXmlRpcClient instance] getObjectExternals:param_id externalsKeys:[NSArray arrayWithObject:k] delegate:self];
    
    [self.loadingIndicator startAnimating];
    
    if ([externalsKey isEqualToString:@"series"]) {
        self.buttonDescription.text = @"Del af serie";
    } else if ([externalsKey isEqualToString:@"reviews"]) {
        self.buttonDescription.text = @"Anmeldelser";
    } else if ([externalsKey isEqualToString:@"adhl"]) {
        self.buttonDescription.text = @"Andre har også lånt";
    } else if ([externalsKey isEqualToString:@"aboutauthor"]) {
        self.buttonDescription.text = @"Om forfatteren";
    } else if ([externalsKey isEqualToString:@"othersbyauthor"]) {
        self.buttonDescription.text = @"Andet af...";
    }

}

-(void)dealloc
{
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];
}

-(void)setExternalsObject:(LibraryExternals *)anExternalsObject
{
    externalsObject = anExternalsObject;
    
    if ([externalsKey isEqualToString:@"series"]) {
        if (externalsObject.hasSeriesItems) {
            self.hasValidExternals=YES;
        }
    } else if ([externalsKey isEqualToString:@"reviews"]) {
        if (externalsObject.hasReviewItems) {
            self.hasValidExternals=YES;
        }
    } else if ([externalsKey isEqualToString:@"adhl"]) {
        if (externalsObject.hasAdhlItems) {
            self.hasValidExternals=YES;
        }
    } else if ([externalsKey isEqualToString:@"aboutauthor"]) {
        if (externalsObject.hasAboutAuthor) {
            self.hasValidExternals=YES;
        }
    } else if ([externalsKey isEqualToString:@"othersbyauthor"]) {
        if (externalsObject.hasOthersByAuthorItems) {
            self.hasValidExternals=YES;
        }
    }
    
    if (self.hasValidExternals) {
        self.discloseButton.hidden=NO;
        self.discloseButton.alpha=0;
        self.buttonDescription.hidden=NO;
        self.buttonDescription.alpha=0;

        [UIView animateWithDuration:0.4
                         animations:^{
                             backgroundView.backgroundColor = [LibraryAppSetttings instance].customerBackgroundColor;
                             self.discloseButton.alpha=1.0;
                             self.buttonDescription.alpha=1.0;
                             self.loadingLabel.alpha=0.0;
                         }
         ];
        

    } else {
        self.noContentLabel.hidden=NO;
        self.noContentLabel.alpha=0;
        self.buttonDescription.hidden=NO;
        self.buttonDescription.alpha=0;
        
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.view.alpha = 0.5;
                             self.noContentLabel.alpha = 1.0;
                             self.buttonDescription.alpha=1.0;
                             self.loadingLabel.alpha=0;
                         }
                         completion:^(BOOL finished) {
                             self.loadingLabel.hidden=YES;
                         }
         ];
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
		
		if ([[request method] isEqualToString:@"getObjectExternals"])
        {
            [self.loadingIndicator stopAnimating];
            
            @try {
                NSDictionary* responsedict = [response object];
                EXPECT_OBJECT(NSDictionary, responsedict);
                
                NSDictionary* datadict = [responsedict objectForKey:@"data"];
                EXPECT_OBJECT(NSDictionary, datadict);
                
                for (NSDictionary* externalsdict in [datadict allValues]) {
                    EXPECT_OBJECT(NSDictionary, externalsdict);
                    
                    NSNumber* result = [externalsdict objectForKey:@"result"];
                    EXPECT_OBJECT(NSNumber, result);
                    
                    if ([result boolValue]) {
                        NSDictionary* externalsdata = [externalsdict objectForKey:@"data"];
                        EXPECT_OBJECT(NSDictionary, externalsdata);
                        
                        NSDictionary* externalsexternals = [externalsdata objectForKey:@"externals"];
                        EXPECT_OBJECT(NSDictionary, externalsexternals);
                        
                        LibraryExternals* parsed_externals = [LibraryExternals createLibraryExternalsFromObject:externalsexternals];
                        [self setExternalsObject:parsed_externals];
                        
                    /*
                    [externalsexternals enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        DLog(@"ext key: %@",key);
                        AboutDetailsItemViewController* corresponding_item = [self getItemForKey:key];
                        
                        if (corresponding_item!=nil) {
                            corresponding_item.externalsObject=parsed_externals;
                            //corresponding_item.view.hidden=NO;
                        }
                    }];
                     */
                    } else {
                        DLog(@"warning: didn't get valid externals");
                        [self setExternalsObject:nil];
                    }
                }
            
            }
            @catch (NSException *exception) {
                ALog(@"ERROR: exception: %@",exception);
                [self setExternalsObject:nil];
            }
            @finally {
                
            }
         }
    }
}


- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error
{
	NSLog(@"request method %@: didFailWithError: %@",[request method], error);
    [self setExternalsObject:nil];

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
