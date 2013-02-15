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

@interface CustomNavigationBar : UIViewController<UISearchBarDelegate>{
    BOOL showingBackButton;
    
    //back button
    CGPoint origBackButtonPos;
    CGPoint showingBackButtonBackButtonPos;
    
    //search bar
    CGRect origSearchBarFrame;
    CGRect showingBackButtonSearchBarFrame;

    //superview
    CGPoint origSearchBarSuperViewPos;
    CGPoint showingBackButtonSearchBarSuperViewPos;
    CGRect showingBackButtonSearchBarSuperViewFrame;
    
}

@property (weak, nonatomic) IBOutlet UIView *theSearchBarSuperView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (strong, nonatomic) UISearchBar* theSearchBar;

- (void)showBackButtonAnimated:(BOOL)animated;
- (void)repeatBackButtonAnimationDescending:(bool)left_dir;
- (void)hideBackButtonAnimated:(BOOL)animated;

@end
