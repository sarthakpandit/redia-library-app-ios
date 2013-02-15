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


#import "BarcodeViewController.h"
#import "defines.h"
#import "LibraryXmlRpcClient.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "NSData+Base64.h"
#import "SearchResultObject.h"
#import "AboutDetailsViewController.h"
#import "BrowserViewController.h"

#ifndef REDIA_APP_USE_SCANNER_OPTION
#error This file must only be included in targets with REDIA_APP_USE_SCANNER_OPTION defined
#endif

@interface BarcodeViewController ()

@end

@implementation BarcodeViewController

@synthesize captureView;
@synthesize loadingIndicator;
@synthesize parentNavigationController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //disAllowedScanSymbols = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        
        NSURL* soundurl = [[NSBundle mainBundle] URLForResource:@"scanner_code_scanner_sound.wav" withExtension:nil];
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundurl),&cameraSoundRef);
        if (error!=noErr) {
            ALog(@"Error loading scanner sound file: %ld",error);
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if USE_ZBAR_SCANNING_LIBRARY && (! TARGET_IPHONE_SIMULATOR)
    _capture = [[ZBarReaderView alloc] init];
    [_capture setReaderDelegate:self];
    
    [self.captureView addSubview:_capture];
    
    //_capture.layer.borderColor = [UIColor clearColor].CGColor;
    
    [self fixSubLayerBorders:_capture.layer];
#endif
}

-(void)fixSubLayerBorders:(CALayer*) sublayer
{
    sublayer.borderColor = [UIColor clearColor].CGColor;
    for (CALayer* caplayer in [sublayer sublayers]) {
        [self fixSubLayerBorders:caplayer];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_capture start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_capture stop];
}

- (void)viewDidUnload {
    [[LibraryXmlRpcClient instance] cancelAllRequestsForDelegate:self];

    [_capture stop];
    
    [self setCapture:nil];
    [self setCaptureView:nil];
    [self setDecodedLabel:nil];
    
    
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
    
    
}

#if USE_ZBAR_SCANNING_LIBRARY

#pragma mark - ZBarReaderViewDelegate Methods

-(void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    // do something useful with results
    for(ZBarSymbol *sym in symbols) {
        NSString* decoded_text = sym.data;
        if ([decoded_text length]>0) {
            // Vibrate
            DLog(@"decoded %@: %@",sym.typeName, decoded_text);
            
            if (sym.type == ZBAR_QRCODE) {
                NSURL* urlcheck = [NSURL URLWithString:decoded_text];
                if (urlcheck!=nil && ![urlcheck isFileURL]) {
                    [_capture stop];
                    BrowserViewController* bvc = [BrowserViewController new];
                    bvc.startUrl = decoded_text;
                    [self addChildViewController:bvc];
                    bvc.view.frame = captureView.frame;
                    [self.view addSubview:bvc.view];
                    bvc.view.alpha=0;
                    [UIView animateWithDuration:0.5 animations:^{
                        bvc.view.alpha=1;
                    }];
                    break;
                }
            } else {
                //if ([decoded_text rangeOfCharacterFromSet:disAllowedScanSymbols].location==NSNotFound) {
                    //DLog(@"allowed");
                    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    AudioServicesPlaySystemSound(cameraSoundRef);
                    captureView.hidden=YES;
                    [_capture stop];
                    
                    [loadingIndicator startAnimating];
                    [[LibraryXmlRpcClient instance] getObjectByBarcodeId:[NSArray arrayWithObject:decoded_text] delegate:self];
                //} else {
                    [_capture flushCache];
                //}
                    
            }
            break;
        }
    }
}

-(void)readerView:(ZBarReaderView *)readerView didStopWithError:(NSError *)error
{
    if (error!=nil) {
        NSLog(@"ZBAR ERROR: %@",error);
        [self dismissModalViewControllerAnimated:NO];
    }
}
#endif

#pragma mark -

- (IBAction)closeButtonClicked:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
    [_capture stop];
}

-(void)dealloc
{
    [_capture stop];
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
        [self resumeScanning];
	} else {
		DLog(@"Parsed response for method %@: %@",[request method], [response object]);
        if ([[request method] isEqualToString:@"getObjectByBarcodeId"]) {
            [self.loadingIndicator stopAnimating];
            @try {
                NSDictionary* dict = [response object];
                EXPECT_OBJECT(NSDictionary, dict);
                
                NSNumber* result = [dict objectForKey:@"result"];
                EXPECT_OBJECT(NSNumber, result);
                
                if (![result boolValue]) {
                    NSString* message = [dict objectForKey:@"message"];
                    NSLog(@"Error result from getObjectByBarcodeId, %@",message);
                    
                    [self resumeScanning];

                } else {
                    NSDictionary* datadict = [dict objectForKey:@"data"];
                    EXPECT_OBJECT(NSDictionary, datadict);

                    for (NSDictionary* datadictdict in [datadict allValues]) {
                        EXPECT_OBJECT(NSDictionary, datadictdict);
                        
                        result = [datadictdict objectForKey:@"result"];
                        EXPECT_OBJECT(NSNumber, result);
                        if (![result boolValue]) {
                            NSString* message = [datadictdict objectForKey:@"message"];
                            NSLog(@"Error result from getObjectByBarcodeId->getObject, %@",message);
                            [self resumeScanning];
                        } else {
                            NSDictionary* datadatadictdict = [datadictdict objectForKey:@"data"];
                            EXPECT_OBJECT(NSDictionary, datadatadictdict);
                            
                            //[_capture stop];
                            [self dismissModalViewControllerAnimated:YES];
                            
                            SearchResultObject* res = [SearchResultObject createFromRecordStructure:datadatadictdict];
                            AboutDetailsViewController* advc = [AboutDetailsViewController new];
                            [self.parentNavigationController showSearchScanResultsRootView:advc];
                            [advc updateFromResultObject:res];
                            [advc view];
                            advc.detailsButton.hidden=NO;
                            break;
                        }

                    }
                    

                }
            }
            @catch (NSException* exception) {
                NSLog(@"EXCEPTION: %@",exception);
                [self resumeScanning];
            }
            
        } else {
            NSLog(@"ERROR: unhandled response from: %@",[request method]);
            [self resumeScanning];
        }
    }
}

-(void)resumeScanning
{
    //continue scanning
    captureView.hidden=NO;
    [_capture start];
    [self.loadingIndicator stopAnimating];
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
