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


#import "SearchResultItem.h"
#import "LibraryXmlRpcClient.h"
#import "SearchResultsView.h"
#import "defines.h"
#import "SearchDetailView.h"
#import "InfoObject.h"
#import "NSString+LibUtils.h"
#import "InfoGalleriImageUrlUtils.h"
#import "LibraryAppSetttings.h"
#import "LazyLoadImageView.h"

@implementation SearchResultItem

@synthesize coverImageView;
@synthesize titleLabel;
@synthesize authorLabel;
@synthesize unavailLabel;
@synthesize typeLabel1;
@synthesize showDetailButton;
@synthesize reserveButton;
@synthesize allInfoView;
@synthesize loadingIndicator;

//@synthesize coverImageDownloaded;
@synthesize resultObject;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    /* moved into hidden button in background:
    UITapGestureRecognizer* gest2    */
    //self.coverImageDownloaded=FALSE;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)setBookTitle:(NSString *)s
{
	[self.titleLabel setVerticalAlign:MultiLineLabelVerticalAlignTop];
	NSString* resulttitle = s; //was: [s stringByTruncatingToRect:self.titleLabel.frame withFont:self.titleLabel.font];
	self.titleLabel.text = resulttitle;
	CGRect t_rect = [self.titleLabel textRectForBounds:self.titleLabel.frame limitedToNumberOfLines:2];
	if (t_rect.size.height<30) {
		CGRect other_frame = self.authorLabel.frame;
		other_frame.origin.y -= 18;
		other_frame.size.height += 18;
		[self.authorLabel setFrame:other_frame];
	}
}

- (void)setOtherInfo:(NSString *)s
{
	[self.authorLabel setVerticalAlign:MultiLineLabelVerticalAlignTop];
	self.authorLabel.text = s; //was: [s stringByTruncatingToRect:self.authorLabel.frame withFont:self.authorLabel.font];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.coverImageView=nil;
	self.titleLabel=nil;
	self.authorLabel=nil;
	self.unavailLabel=nil;
	self.typeLabel1=nil;
	//self.typeLabel2=nil;
	//self.typeLabel3=nil;
	self.showDetailButton=nil;
	self.reserveButton=nil;
	self.allInfoView=nil;
    self.loadingIndicator=nil;
    
	//self.identifier=nil;
	//self.superViewController=nil;
}

- (void)dealloc {
	//self.typeLabel2=nil;
	//self.typeLabel3=nil;
	

	DLog(@"dealloced");
}


- (IBAction)addReservation:(id)sender
{
	//[self.superViewController addReservation:self.reservationId withTitle:self.titleLabel.text];
    //[self.navigationController pushViewController:[AddReservationView requestReservation:self.reservationId withTitle:self.titleLabel.text delegate:self inNavigationController:self.navigationController] animated:NO];
    currentReservationView = [AddReservationView requestReservation:resultObject.reservationId withTitle:self.titleLabel.text delegate:self inNavigationController:self.navigationController];
    [[self.tabBarController selectedViewController].view addSubview:currentReservationView.view];

}

-(void)addReservationViewDismissed:(id)sender
{
    [currentReservationView.view removeFromSuperview];
    currentReservationView = nil;
}

- (void)updateFromRecordStructure:(NSDictionary*)cur_item
{

    resultObject = [SearchResultObject createFromRecordStructure:cur_item];
    
    [self setBookTitle:resultObject.origTitle];
    
    //[[HTMLEntityResolver alloc] initWithString:otherinfo resultTarget:self selector:@selector(setOtherInfo:)];
    [self setOtherInfo:[InfoObject unescapeString:resultObject.otherInfo]];

    NSString* type_string = resultObject.typeString;
    UIImageView* image_view = self.coverImageView;
    image_view.image = resultObject.coverImage; //was:  [SearchResultsView getDefaultImageForType:type_string];
    
    if ([type_string isEqualToString:@"Collection"]) {
        type_string = @"Værk";
    }
    
    self.typeLabel1.text = type_string;

}

-(void)updateCoverUrl:(NSString*)coverurl
{
    NSString* resizeurl_thumb = [InfoGalleriImageUrlUtils getResizedImageUrl:coverurl
                                                                     toWidth:[LibraryAppSetttings instance].isRetinaDisplay ? 80*2 : 80
                                                                    toHeight:[LibraryAppSetttings instance].isRetinaDisplay ? 117*2 : 117
                                                                usingQuality:4
                                                                    withMode:IMAGE_URL_UTILS_RESIZE_MODE_CROP_EDGES];
    UIImageView* image_view = self.coverImageView;
    [image_view setContentMode: UIViewContentModeScaleAspectFit];
    [LazyLoadImageView createLazyLoaderWithView:image_view url:[[NSURL alloc] initWithString:resizeurl_thumb] animationTime:0 delegate:self];
    resultObject.coverImageDownloaded=TRUE;

}

-(void)imageLoaded:(UIImage *)theImage
{
    resultObject.coverImage=theImage;
}
-(void)loadImageError
{
    //do nothing
}

-(void)updateFromObjectExtras:(NSDictionary *)extras_dict
{
    if (extras_dict!=nil && [extras_dict isKindOfClass:[NSDictionary class]]) {
        resultObject.reservationId = [extras_dict objectForKey:@"reservationId"];
        bool isReservable = [[extras_dict objectForKey:@"isReservable"] boolValue];
        if (resultObject.reservationId!=nil && [resultObject.reservationId length]>0) {
            [self.loadingIndicator stopAnimating];
            if (!isReservable) {
                self.reserveButton.hidden=YES;
            } else {
                self.reserveButton.hidden=NO;
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

- (IBAction)showDetails:(id)sender
{
    SearchDetailView* sdv = [[SearchDetailView alloc] initWithNibName:nil bundle:nil];

    [self.navigationController pushViewController:sdv animated:YES];
    
    [sdv updateFromResultObject:self.resultObject];
    
    /*was:
    sdv.identifier = self.identifier;
    sdv.children = self.children;
    sdv.coverImageView.image = self.coverImageView.image;
    sdv.titleLabel.text = self.origTitle;
    sdv.authorLabel.text = self.origAuthor;
    sdv.abstract = self.abstract;
    sdv.date = self.date;
    sdv.coverImageDownloaded = self.coverImageDownloaded;
    
    [sdv updateAllInfoView:nil];
    [sdv fetchDetails];
     */
}

@end
