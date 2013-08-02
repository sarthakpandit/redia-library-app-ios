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


#import "libraryappAppDelegate.h"
#import "LibraryAuthenticationManager.h"
#import "UrlCacheManager.h"
//#import "ConnectionTester.h"
#import "ChannelFetchManager.h"
#import "WebserviceVersionTester.h"
#import "LibraryXmlRpcClient.h"

#ifdef REDIA_APP_USE_ERROR_REPORTER
#import "errorreporter.h"
#import "ErrorReporterExceptionHandler.h"
#else
#   ifndef REDIA_APP_DONT_WARN_ON_MISSING_ERROR_REPORTER
#       warning Error reporting is disabled in this build.
#   endif
#endif

#import "DefaultImageSingleton.h"
#import "InfoGalleriImageUrlUtils.h"
#import "LibraryAppSetttings.h"
#import "BibSearchSingleton.h"

@implementation libraryappAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

	[application setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    LibraryAppSetttings* settings = [LibraryAppSetttings instance];
    [settings loadSettings];
    
#ifdef REDIA_APP_USE_ERROR_REPORTER
    [ErrorReporter instance].projectName = [NSString stringWithFormat:@"%@ iOS app v. %@",
                                            [settings getCustomerId],
                                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    installErrorReporterExceptionHandler();
#endif
    
    [InfoGalleriImageUrlUtils instance].wsApiKey = REDIA_APP_IMAGE_UTILS_API_KEY;
    
    [[LibraryXmlRpcClient instance] setWsCustomerId:[settings getCustomerId]];
    [[LibraryXmlRpcClient instance] setWsApiKey:REDIA_APP_LIBRARY_XMLRPC_CLIENT_API_KEY];
    
    NSString* noimagename = [settings getNoImageName];
    if (noimagename!=nil && [noimagename length]>0) {
        [[DefaultImageSingleton instance] setDefaultImageName:noimagename];
    }
    
    [[[WebserviceVersionTester alloc] init] checkWebserviceVersion];
	
	[[ChannelFetchManager instance] setCustomerDB:[settings getGalleryCustomerId] withGallery:[settings getGalleryId]];
    //[[ChannelFetchManager instance] setCustomerDB:@"demo" withGallery:@"bbduh"];
	
    
	//[[UrlCacheManager instance] clearEntireCacheDatabase];
	
	[[UrlCacheManager instance] checkConsistency];
    
	[[LibraryAuthenticationManager instance] setAppTabBar:self.tabBarController]; //NB: initializing instance requires that LibraryAppSetttings is already initialized!
    [[LibraryAuthenticationManager instance] updateReservationBranches]; //start fetching list of reservation branches
	
	//ConnectionTester* tester = [[ConnectionTester alloc] initWithNibName:@"ConnectionTester" bundle:nil];
	//[self.window addSubview:tester.view];
    
	// Set the tab bar controller as the window's root view controller and display.
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    /* old code, going to dep
    int idx = tabBarController.selectedIndex;
    if (idx == 0 || idx==1 || idx==4) {
        //bibstore, arrangements or opening hours

        //reselect the tab bar controller to rerequest any data
        [self tabBarController:tabBarController didSelectViewController:tabBarController.selectedViewController];
    }
    */
    if (![LibraryAuthenticationManager instance].isShowingAuthenticationDialog) {
        UIViewController* tabs_selected = tabBarController.selectedViewController;
        if ([tabs_selected isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navc = (UINavigationController*)tabs_selected;
            UIViewController* curctrl = [navc topViewController];
            if ([curctrl conformsToProtocol:@protocol(MyTabBarNotificationDelegate)]) {
                id<MyTabBarNotificationDelegate> tbnd = (id<MyTabBarNotificationDelegate>)curctrl;
                [tbnd checkForUpdate];
            }
        }
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark UITabBarControllerDelegate methods

// Optional UITabBarControllerDelegate method.
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if ([LibraryAuthenticationManager instance].isShowingAuthenticationDialog) {
		return FALSE;
	} else {
		return TRUE;
	}
}

-(UIViewController*)rootViewForNavigationController:(UINavigationController*)nav
{
    NSArray* navctrls = nav.viewControllers;
    if ([navctrls count]>0) {
        return [navctrls objectAtIndex:0];
    }
    return nil;
}

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)_tabBarController didSelectViewController:(UIViewController *)viewController {
    [[BibSearchSingleton instance] dismissSearchResultsView];
    
    UIViewController* selectedRoot = [self rootViewForNavigationController:(UINavigationController*)viewController];
    
	NSArray* tabctrls = [_tabBarController viewControllers];
	if (tabctrls != nil) {
        for (UINavigationController* topnav in tabctrls) {
            NSObject<MyTabBarNotificationDelegate>* nav_root = (NSObject<MyTabBarNotificationDelegate>*) [self rootViewForNavigationController:topnav];
            
            if ([nav_root respondsToSelector:@selector(tabBarControllerSelected:)] ) {
                [nav_root performSelector:@selector(tabBarControllerSelected:) withObject:selectedRoot afterDelay:0];
            }
            
        }
	}
}


/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



@end

