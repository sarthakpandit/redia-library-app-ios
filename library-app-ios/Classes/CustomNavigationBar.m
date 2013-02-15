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


#import "CustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "defines.h"

@implementation CustomNavigationBar

@synthesize theSearchBar;

-(void)setupCustomNavigationBar{
    
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setupCustomNavigationBar];
    }
    return self;
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupCustomNavigationBar];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    CGRect search_frame = CGRectMake(0, 0, 320, 44);
    
    origBackButtonPos = _backButton.layer.position;
    
    origSearchBarSuperViewPos = _theSearchBarSuperView.center;
#ifdef REDIA_APP_USE_SCANNER_OPTION
    _scanButton.hidden=NO;
    [_scanButton.superview bringSubviewToFront:self.scanButton];
    
    CGRect scan_frame = _scanButton.frame;
    
    CGFloat delta = scan_frame.origin.x + scan_frame.size.width;
    search_frame.origin.x += delta;
    search_frame.size.width -= delta;
    
#endif
    
    theSearchBar = [[UISearchBar alloc] initWithFrame:search_frame];
    //[theSearchBar setBackgroundColor:[UIColor clearColor]];
    //[theSearchBar setTintColor:[UIColor clearColor]];
    theSearchBar.barStyle=UIBarStyleBlackOpaque;
    [theSearchBar setClearsContextBeforeDrawing:YES];
    [theSearchBar setPlaceholder:@"Søg i bibliotekets materialer"];
    [theSearchBar setDelegate:self];
    [theSearchBar setOpaque:YES];
    [_theSearchBarSuperView addSubview:theSearchBar];
    origSearchBarFrame = search_frame;
    
    //compute frames and positions when showing back button
    int move_x=80;
    showingBackButtonSearchBarSuperViewPos = _theSearchBarSuperView.center; //was: newPoint
    showingBackButtonSearchBarSuperViewPos.x += move_x;
    
    showingBackButtonBackButtonPos = CGPointMake(320/2, 44/2); //was: newbuttonpos
    showingBackButtonSearchBarFrame = CGRectMake(theSearchBar.frame.origin.x, theSearchBar.frame.origin.y, theSearchBar.frame.size.width-move_x, theSearchBar.frame.size.height); //was: newrect3

}


-(void)viewDidAppear:(BOOL)animated
{
    //DLog(@"search super view pos %@",NSStringFromCGRect(self.theSearchBarSuperView.frame));

    [super viewDidAppear:animated];
    //DLog(@"search super view pos %@",NSStringFromCGRect(self.theSearchBarSuperView.frame));

    //hack for fixing bug when dismissing modal view:
    if (showingBackButton) {
        [self showBackButtonInternal];
    }
}


- (void)showBackButtonAnimated:(BOOL)animated
{
    if (!showingBackButton) {
        _backButton.hidden=FALSE;
        _backButton.layer.opacity=0.0;
        
        /* was:
         int move_x=80;
         CGPoint newPoint= _theSearchBarSuperView.center;
         //newrect2.size.width = 320-move_x;
         newPoint.x += move_x;
         
         //newrect2=CGRectMake(move_x, 0, 320-move_x, 44);
         
         CGPoint newbuttonpos = CGPointMake(320/2, 44/2);
         CGRect newrect3 = CGRectMake(theSearchBar.frame.origin.x, theSearchBar.frame.origin.y, theSearchBar.frame.size.width-move_x, theSearchBar.frame.size.height);
         
         _backButton.layer.position = newbuttonpos;
         */
        
        _backButton.layer.position = showingBackButtonBackButtonPos; //was: newbuttonpos
        
        if (animated) {
            [UIView animateWithDuration:0.35
                             animations:^{
                                 [self showBackButtonInternal]; //was: :newPoint rect:newrect3];
                             }
             ];

        } else {
            [self showBackButtonInternal]; //was: :newPoint rect:newrect3];
        }
        
        showingBackButton=TRUE;
    }
}

-(void)showBackButtonInternal //:(CGPoint)newPoint rect:(CGRect)newrect3
{
    _backButton.layer.opacity=1.0;
    _backButton.layer.position = origBackButtonPos;
    _theSearchBarSuperView.center = showingBackButtonSearchBarSuperViewPos; //was: newPoint
    theSearchBar.frame = showingBackButtonSearchBarFrame; //was: newrect3
    [theSearchBar layoutSubviews];
    //[_theSearchBarSuperView layoutSubviews];

}

- (void)repeatBackButtonAnimationDescending:(bool)left_dir
{
    CGPoint right = CGPointMake(320/2, 44/2);
    CGPoint left = CGPointMake(-320/2, 44/2);
    
    CGPoint newbuttonpos1;
    CGPoint newbuttonpos2;
    
    if (left_dir) {
        newbuttonpos1 = left;
        newbuttonpos2 = right;
    } else {
        newbuttonpos1 = right;
        newbuttonpos2 = left;
    }
    
    [UIView animateWithDuration:0.16
                          delay:0
                        options:UIViewAnimationOptionOverrideInheritedDuration
     
                     animations:^{
                         _backButton.layer.position = newbuttonpos1;
                     }
                     completion:^(BOOL c) {
                         _backButton.layer.position = newbuttonpos2;
                         [UIView animateWithDuration:0.16
                                               delay:0
                                             options:UIViewAnimationOptionOverrideInheritedDuration
                                          animations:^{
                                              _backButton.layer.position = origBackButtonPos;
                                          }
                                          completion:^(BOOL c) {
                                              
                                          }
                          ];
                         
                     }
     ];
    
}


-(void)hideBackButton
{
    CGPoint newbuttonpos = CGPointMake(320/2, 44/2);
    _backButton.layer.opacity=0.0;
    _backButton.layer.position = newbuttonpos;
    _theSearchBarSuperView.center = origSearchBarSuperViewPos;
    theSearchBar.frame = origSearchBarFrame;
    [theSearchBar layoutSubviews];
    
}

- (void)hideBackButtonAnimated:(BOOL)animated
{
    if (showingBackButton) {
        
        if (animated) {
            
            [UIView animateWithDuration:0.35
                             animations:^{
                                 [self hideBackButton];
                             }
             ];

        } else {
            [self hideBackButton];
        }
        
        showingBackButton=FALSE;
    }
    
}

@end
