/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import "USHAppDelegate.h"
#import "USHDevice.h"
#import "USHWindow.h"
#import "UIViewController+USH.h"
#import "NSBundle+USH.h"
#import "USHDefaults.h"

@interface USHAppDelegate ()

@property (assign, nonatomic) BOOL keyboardDidShow;
@property (strong, nonatomic) USHDefaults *defaults;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

- (UIViewController*) modalViewController;
- (UIViewController*) topViewController;

@end

@implementation USHAppDelegate

@synthesize window = _window;
@synthesize keyboardDidShow = _keyboardDidShow;
@synthesize splitViewController = _splitViewController;
@synthesize defaults = _defaults;

#pragma mark - IBActions

- (IBAction)sidebar:(id)sender event:(UIEvent*)event {
    UIBarButtonItem *barButtonItem = (UIBarButtonItem*)sender;
    CGRect master = [[[self.splitViewController.viewControllers objectAtIndex:0] view] frame];
    CGRect split = self.splitViewController.view.frame;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    NSBundle *bundle = [NSBundle bundleWithName:@"Ushahidi.bundle"];
    
    NSString *showPath = [bundle pathForResource:@"show" ofType:@"png"];
    NSString *hidePath = [bundle pathForResource:@"hide" ofType:@"png"];
    
    DLog(@"Show:%@", showPath);
    
    UIImage *show = [UIImage imageWithContentsOfFile:showPath];
    UIImage *hide = [UIImage imageWithContentsOfFile:hidePath];
    
    BOOL restoreSplitFrame = NO;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        if (split.size.height > self.window.frame.size.height) {
            split.size.height = self.window.frame.size.height;
            barButtonItem.image = hide;
        }
        else {
            split.size.height += master.size.width;
            barButtonItem.image = show;
        }
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight) {
        if (split.origin.y < 0) {
            split.origin.y = 0;
            restoreSplitFrame = YES;
            barButtonItem.image = hide;
        }
        else {
            split.origin.y -= master.size.width;
            split.size.height += master.size.width;
            barButtonItem.image = show;
        }
    }
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.splitViewController.view.frame = split;
                     }
                     completion:^(BOOL finished){
                         if (restoreSplitFrame) {
                             DLog(@"restoreSplitFrame");
                             CGRect split = self.splitViewController.view.frame;
                             split.size.height = self.window.frame.size.height;
                             self.splitViewController.view.frame = split;
                         }
                     }];
}

#pragma mark - Helpers

- (void)statusBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if ([UIApplication sharedApplication].statusBarHidden != hidden) {
        if (animated) {
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationSlide];
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.3];
        }
        else {
            [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
        }
        CGRect frame = self.window.rootViewController.view.frame;
        DLog(@"Before:%@", NSStringFromCGRect(frame));
        if (hidden) {
            if ([USHDevice isPortraitMode]) {
                frame.origin.y = 0.0f;
            }
            else {
                frame.size.width += 20.0f;
            }
        }
        else {
            if ([USHDevice isPortraitMode]) {
                frame.origin.y = 20.0f;
            }
            else {
                frame.size.width -= 20.0f;
            }
        }
        self.window.rootViewController.view.frame = frame;
        [self.window.rootViewController.view setNeedsLayout];
        DLog(@"After:%@", NSStringFromCGRect(frame));
        if (animated) {
            [UIView commitAnimations];
        }
    }
}

#pragma mark - UIApplication

- (id) init {
    if ([super init]) {
        self.defaults = [[[USHDefaults alloc] init] autorelease];
    }
    return self;
}

- (void)dealloc {
    [_splitViewController release];
    [_window release];
    [_defaults release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self.defaults facebookAppID] != nil) {
        return [FBSession.activeSession handleOpenURL:url];
    }
    return NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    DLog(@"");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DLog(@"");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DLog(@"");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    DLog(@"");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if ([self.defaults facebookAppID] != nil) {
        [FBProfilePictureView class];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    DLog(@"");
    if ([self.defaults facebookAppID] != nil) {
        [FBSession.activeSession close];
    }
}

#pragma mark - UIKeyboardDidShowNotification

- (void)keyboardWillShow:(NSNotification *)notification {
    UIViewController *topViewController = self.topViewController;
    UIViewController *modalViewController = self.modalViewController;
    if (modalViewController.presentedViewController) {
        modalViewController = modalViewController.presentedViewController;
    }
    DLog(@"Top:%@ Modal:%@", topViewController, modalViewController);
    
    CGRect keyboard = CGRectMake(0, 0, 0, 0);
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboard];
    //NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (!self.keyboardDidShow) {
        self.keyboardDidShow = YES;
        CGRect topFrame = topViewController.view.frame;
        CGRect modalFrame = modalViewController.view.frame;
        if ([USHDevice isPortraitMode]) {
            topFrame.size.height -= keyboard.size.height;
            if (modalViewController.modalPresentationStyle == UIModalPresentationFullScreen ||
                modalViewController.modalPresentationStyle == UIModalPresentationPageSheet) {
                modalFrame.size.height -= keyboard.size.height;
            }
            else if ([USHDevice isIPhone]) {
                modalFrame.size.height -= keyboard.size.height;
            }
        }
        else if ([USHDevice isLandscapeMode]) {
            if (topFrame.size.width > topFrame.size.height) {
                topFrame.size.height -= keyboard.size.width;
            }
            else {
                topFrame.size.width -= keyboard.size.width;
                topFrame.origin.x += keyboard.size.width;                
            }
            if (modalViewController.modalPresentationStyle == UIModalPresentationFullScreen ||
                modalViewController.modalPresentationStyle == UIModalPresentationPageSheet) {
                modalFrame.size.height -= keyboard.size.width;
            }
            else if ([USHDevice isIPhone]) {
                modalFrame.size.height -= keyboard.size.width;
            }
        }
        [UIView beginAnimations:@"keyboardWillShow" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //[UIView setAnimationDuration:duration];
        topViewController.view.frame = topFrame;
        modalViewController.view.frame = modalFrame;
        [UIView commitAnimations];
    }   
}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIViewController *topViewController = self.topViewController;
    UIViewController *modalViewController = self.modalViewController;
    if (modalViewController.presentedViewController) {
        modalViewController = modalViewController.presentedViewController;
    }
    DLog(@"Top:%@ Modal:%@", topViewController, modalViewController);
    
    CGRect keyboard = CGRectMake(0, 0, 0, 0);
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboard];
    //NSTimeInterval duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.keyboardDidShow) {
        self.keyboardDidShow = NO;
        CGRect topFrame = topViewController.view.frame;
        CGRect modalFrame = modalViewController.view.frame;
        if ([USHDevice isPortraitMode]) {
            topFrame.size.height += keyboard.size.height;
            if (modalViewController.modalPresentationStyle == UIModalPresentationFullScreen ||
                modalViewController.modalPresentationStyle == UIModalPresentationPageSheet) {
                modalFrame.size.height += keyboard.size.height;    
            }
            else if ([USHDevice isIPhone]) {
                modalFrame.size.height += keyboard.size.height; 
            }
        }
        else if ([USHDevice isLandscapeMode]) {
            if (topFrame.size.width > topFrame.size.height) {
                topFrame.size.height += keyboard.size.width;
            }
            else {
                topFrame.size.width += keyboard.size.width;
                topFrame.origin.x -= keyboard.size.width;   
            }
            if (modalViewController.modalPresentationStyle == UIModalPresentationFullScreen ||
                modalViewController.modalPresentationStyle == UIModalPresentationPageSheet) {
                modalFrame.size.height += keyboard.size.width;    
            }
            else if ([USHDevice isIPhone]) {
                modalFrame.size.height += keyboard.size.width;
            }
        }
        [UIView beginAnimations:@"keyboardWillHide" context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //[UIView setAnimationDuration:duration];
        topViewController.view.frame = topFrame;
        modalViewController.view.frame = modalFrame;        
        [UIView commitAnimations];
    }
}
  
- (UIViewController*) topViewController {
    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:UISplitViewController.class]) {
        return rootViewController;
    }
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController*)rootViewController;
        return navigationController.viewControllers.lastObject;
    }
    if ([rootViewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarController = (UITabBarController*)rootViewController;
        UIViewController *selectedViewController = [tabBarController.viewControllers objectAtIndex:tabBarController.selectedIndex];
        if ([selectedViewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *navigationController = (UINavigationController*)selectedViewController;
            return navigationController.viewControllers.lastObject;
        }
        return selectedViewController.navigationController.viewControllers.lastObject;
    }
    return rootViewController.navigationController.viewControllers.lastObject;
}

- (UIViewController*) modalViewController {
    UIViewController *rootViewController = self.window.rootViewController;
    DLog(@"RootViewController:%@", rootViewController.class);
    if ([rootViewController isKindOfClass:UISplitViewController.class]) {
        UISplitViewController *splitViewController = (UISplitViewController*)rootViewController;
        
        UIViewController *detailsViewController = [splitViewController.viewControllers objectAtIndex:0];
        UINavigationController *detailsNavigationController;
        if ([detailsViewController isKindOfClass:UINavigationController.class]) {
            detailsNavigationController = (UINavigationController*)detailsViewController;
        }
        else {
            detailsNavigationController = detailsViewController.navigationController;
        }
        UIViewController *detailsVisibleViewController = detailsNavigationController.visibleViewController;
        UIViewController *masterViewController = [splitViewController.viewControllers objectAtIndex:1];
        UINavigationController *masterNavigationController;
        if ([masterViewController isKindOfClass:UINavigationController.class]) {
            masterNavigationController = (UINavigationController*)masterViewController;
        }
        else {
            masterNavigationController = masterViewController.navigationController;
        }
        UIViewController *masterVisibleViewController = masterNavigationController.visibleViewController;
        if ([masterVisibleViewController isModalViewController]) {
            return masterVisibleViewController; 
        }
        if ([detailsVisibleViewController isModalViewController]) {
            return detailsVisibleViewController; 
        }
    }
    else if ([rootViewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarController = (UITabBarController*)rootViewController;
        UIViewController *selectedViewController = [tabBarController.viewControllers objectAtIndex:tabBarController.selectedIndex];
        if ([selectedViewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *navigationController = (UINavigationController*)selectedViewController;
            if ([navigationController.visibleViewController isModalViewController]) {
                return navigationController.visibleViewController;
            }
        }
        if ([selectedViewController.navigationController.visibleViewController isModalViewController]) {
            return selectedViewController.navigationController.topViewController;
        }
    }
    else if ([rootViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController*)rootViewController;
        if ([navigationController.visibleViewController isModalViewController]) {
            return navigationController.visibleViewController;
        }
    }
    else {
        UINavigationController *navigationController = rootViewController.navigationController;
        if ([navigationController.visibleViewController isModalViewController]) {
            return navigationController.visibleViewController;
        }
    }
    return nil;
}

@end
