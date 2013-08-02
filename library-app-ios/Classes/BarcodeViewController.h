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


#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

#ifdef REDIA_APP_USE_SCANNER_OPTION

#define USE_ZBAR_SCANNING_LIBRARY 1

#if USE_ZBAR_SCANNING_LIBRARY
#import <ZBarSDK/ZBarReaderView.h>

#define LIBRARY_APP_SCANNER_DELEGATE ZBarReaderViewDelegate
#endif

#import "XMLRPCConnectionDelegate.h"
#import "CustomNavigationController.h"

@interface BarcodeViewController : UIViewController <LIBRARY_APP_SCANNER_DELEGATE, XMLRPCConnectionDelegate>
{
    //NSCharacterSet* disAllowedScanSymbols;
    SystemSoundID cameraSoundRef;
}

@property (weak, nonatomic) IBOutlet UIView *captureView;

#if USE_ZBAR_SCANNING_LIBRARY
@property (nonatomic, retain) ZBarReaderView* capture;
#endif

@property (nonatomic, weak) IBOutlet UILabel* decodedLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) CustomNavigationController* parentNavigationController;

- (IBAction)closeButtonClicked:(id)sender;

@end

#endif
