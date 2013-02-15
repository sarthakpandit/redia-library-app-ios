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


#import "CustomZXCapture.h"
#import "ZXCapture.h"


#if !TARGET_IPHONE_SIMULATOR
#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
#define ZXCaptureDevice AVCaptureDevice
#define ZXCaptureOutput AVCaptureOutput
#define ZXMediaTypeVideo AVMediaTypeVideo
#define ZXCaptureConnection AVCaptureConnection
#else
#define ZXCaptureOutput QTCaptureOutput
#define ZXCaptureConnection QTCaptureConnection
#define ZXCaptureDevice QTCaptureDevice
#define ZXMediaTypeVideo QTMediaTypeVideo
#endif

@implementation CustomZXCapture

- (void)captureOutput:(ZXCaptureOutput*)captureOutput ZXQT(didOutputVideoFrame:(CVImageBufferRef)videoFrame  withSampleBuffer:(QTSampleBuffer*)sampleBuffer) ZXAV(didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer) fromConnection:(ZXCaptureConnection*)connection {
    
    [super captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection];

    [super setRotation:(rotate ? 90.0f : 0.0f)];
    rotate = ! rotate;
}

@end
#else
@implementation CustomZXCapture


@end
#endif