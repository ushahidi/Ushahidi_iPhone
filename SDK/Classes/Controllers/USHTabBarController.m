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

#import "USHTabBarController.h"
#import "USHViewController.h"
#import "USHDevice.h"
#import "UIViewController+USH.h"
#import "UIImage+USH.h"

@interface USHTabBarController ()

@property (strong, nonatomic) UIViewController *hostingViewController;

@end

@implementation USHTabBarController

@synthesize navBarColor = _navBarColor;
@synthesize tabBarColor = _tabBarColor;
@synthesize hostingViewController = _hostingViewController;

-(void) addMiddleButtonWithImage:(UIImage*)normalImage highlightImage:(UIImage*)highlightImage action:(SEL)action {
    [self addMiddleButtonWithImage:normalImage highlightImage:highlightImage tintColor:nil action:action];
}

-(void) addMiddleButtonWithImage:(UIImage*)normalImage highlightImage:(UIImage*)highlightImage tintColor:(UIColor*)tintColor action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, normalImage.size.width, normalImage.size.height);
    button.showsTouchWhenHighlighted = YES;
    if (tintColor != nil) {
        [button setBackgroundImage:[normalImage tintedWithColor:tintColor]
                          forState:UIControlStateNormal];
        [button setBackgroundImage:[highlightImage tintedWithColor:tintColor]
                          forState:UIControlStateHighlighted];
    }
    else {
        [button setBackgroundImage:normalImage
                          forState:UIControlStateNormal];
        [button setBackgroundImage:highlightImage
                          forState:UIControlStateHighlighted];
    }
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.tintColor = [UIColor redColor];
    CGFloat heightDifference = normalImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    }
    else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    [self.view addSubview:button];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_navBarColor release];
    [_tabBarColor release];
    [_hostingViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidLoad" object:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidUnload" object:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewWillAppear" object:self];
    self.tabBar.tintColor = self.tabBarColor;
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController*)viewController;
            navigationController.navigationBar.tintColor = self.navBarColor;
        }
        else {
            viewController.navigationController.navigationBar.tintColor = self.navBarColor;   
        }
    }
    self.navigationController.navigationBar.tintColor = self.navBarColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidAppear" object:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewWillDisappear" object:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidDisappear" object:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else {
        return YES;
    }
}

#pragma mark - UITabBarController

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    DLog(@"%@", viewController.class);
}

- (void) presentModalViewController:(USHViewController *)viewController {
    [self presentModalViewController:viewController animated:YES];
}

- (void) presentModalViewController:(USHViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[USHViewController class]]) {
        viewController.hostingViewController = self;
    }
    if (viewController.modalPresentationStyle == UIModalPresentationFormSheet || 
        viewController.modalPresentationStyle == UIModalPresentationPageSheet) {
        if ([USHDevice isIPad]) {
            [self viewWillDisappear:animated];
        }
    }
    UIViewController *modalController = nil;
    if ([viewController isKindOfClass:UINavigationController.class]) {
        DLog(@"UINavigationController %@", viewController.nibName);
        modalController = viewController;
        modalController.modalPresentationStyle = viewController.modalPresentationStyle;
        modalController.modalTransitionStyle = viewController.modalTransitionStyle;
    }
    else if (viewController.navigationItem != nil) {
        DLog(@"Has UINavigationItem %@", viewController.nibName);
        UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidLoad" object:navigationController];
        modalController = navigationController;
        modalController.modalPresentationStyle = viewController.modalPresentationStyle;
        modalController.modalTransitionStyle = viewController.modalTransitionStyle;
    }
    else {
        DLog(@"No UINavigationItem  %@", viewController.nibName);
        modalController = viewController;
        modalController.modalPresentationStyle = viewController.modalPresentationStyle;
        modalController.modalTransitionStyle = viewController.modalTransitionStyle;
    }
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        DLog(@"presentViewController:%@ animated:%d", viewController.nibName, animated);
        [self presentViewController:modalController animated:animated completion:nil];
    } 
    else {
        DLog(@"presentModalViewController:%@ animated:%d", viewController.nibName, animated);
        [super presentModalViewController:modalController animated:animated]; 
    } 
    if (viewController.modalPresentationStyle == UIModalPresentationFormSheet || 
        viewController.modalPresentationStyle == UIModalPresentationPageSheet) {
        if ([USHDevice isIPad]) {
            [self viewDidDisappear:animated];
        }
    }
}

- (void) dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) dismissModalViewControllerAnimated:(BOOL)animated {
    if (self.hostingViewController && [USHDevice isIPad]) {
        [self.hostingViewController viewWillAppear:animated];
    }
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        DLog(@"dismissViewControllerAnimated:%d", animated);
        [self dismissViewControllerAnimated:animated completion:nil];    
    } 
    else {
        DLog(@"dismissModalViewControllerAnimated:%d", animated);
        [super dismissModalViewControllerAnimated:animated];    
    }
    if (self.hostingViewController && [USHDevice isIPad]) {
        [self.hostingViewController viewDidAppear:animated];
    }
}

#pragma mark - UIBarButtonItems

- (UIBarButtonItem*) leftBarButtonItem {
    return self.navigationItem.leftBarButtonItem;
}

- (void) setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (UIBarButtonItem*) rightBarButtonItem {
    return self.navigationItem.rightBarButtonItem;
}

- (void) setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void) setBackBarButtonTitle:(NSString*)title {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
    [backButton release];
}

- (NSString*) backBarButtonTitle {
    return self.navigationItem.backBarButtonItem.title;
}

- (void) setTitleViewWithImage:(NSString*)imageName orText:(NSString*)title {
    UIImage *image = [UIImage imageNamed:imageName];
    if (image != nil){
        self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:image] autorelease];
    }
    else {
        self.navigationItem.title = title;
    }
}

@end
