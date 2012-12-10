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

#import "USHViewController.h"
#import "USHLoadingView.h"
#import "USHMessageView.h"
#import "USHDevice.h"
#import "UIViewController+USH.h"

@interface USHViewController ()

@property (strong, nonatomic) USHLoadingView *loadingView;
@property (strong, nonatomic) USHMessageView *messageView;
@property (assign, nonatomic) BOOL willBePushed;
@property (assign, nonatomic) BOOL wasPushed;

- (void) loadViewColors;

@end

@implementation USHViewController

@synthesize toolBar = _toolBar;
@synthesize loadingView = _loadingView;
@synthesize messageView = _messageView;
@synthesize hostingViewController = _hostingViewController;
@synthesize willBePushed = _willBePushed;
@synthesize wasPushed = _wasPushed;
@synthesize navBarColor = _navBarColor;
@synthesize toolBarColor = _toolBarColor;
@synthesize buttonDoneColor = _buttonDoneColor;

typedef enum {
    AlertViewError,
    AlertViewWebsite
} AlertView;

#pragma mark -
#pragma mark Handlers

- (void)viewWillBePushed {
	DLog(@"%@", self.nibName);
	self.willBePushed = YES;
}

- (void)viewWasPushed {
	DLog(@"%@", self.nibName);
	self.wasPushed = YES;
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
        DLog(@"UINavigationItem %@", viewController.nibName);
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

#pragma mark - USHMessageView

- (void) showMessage:(NSString*)message {
    [self.messageView showWithMessage:message];
}

- (void) showMessage:(NSString*)message hide:(NSTimeInterval)delay {
    [self.messageView showWithMessage:message]; 
    [self.messageView hideAfterDelay:delay];
}

- (void) hideMessage {
    [self.messageView hide];
}

- (void) hideMessageAfterDelay:(NSTimeInterval)delay {
    [self.messageView hideAfterDelay:delay];
}

#pragma mark - USHLoadingView

- (void) showLoading {
    [self.loadingView show];
}

- (void) showLoadingWithMessage:(NSString *)message {
    [self.loadingView showWithMessage:message];
}

- (void) showLoadingWithMessage:(NSString *)message hide:(NSTimeInterval)delay {
    [self.loadingView showWithMessage:message];
    [self.loadingView hideAfterDelay:delay];
}

- (void) hideLoading {
    [self.loadingView hide];
}

- (void) hideLoadingAfterDelay:(NSTimeInterval)delay {
    [self.loadingView hideAfterDelay:delay];
}

- (void) hideMessageIfEquals:(NSString *)message {
    [self.loadingView hideIfMessage:message];
}

#pragma mark - View Colors

- (void) loadViewColors {
    self.toolBar.tintColor = self.toolBarColor;
//    self.navigationBar.tintColor = self.navBarColor;
//    self.navigationBar.topItem.title = self.title;
//    for (UIView *subView in self.navigationBar.items){
//        if ([subView isKindOfClass:UIBarButtonItem.class]) {
//            UIBarButtonItem *barButtonItem = (UIBarButtonItem*)subView;
//            if ([barButtonItem respondsToSelector:@selector(tintColor)] &&
//                barButtonItem.style == UIBarButtonItemStyleDone) {
//                barButtonItem.tintColor = self.buttonDoneColor;
//            }
//        }
//    }
//    if (self.navigationBar.topItem.leftBarButtonItem.style == UIBarButtonItemStyleDone &&
//        [self.navigationBar.topItem.leftBarButtonItem respondsToSelector:@selector(tintColor)]) {
//        self.navigationBar.topItem.leftBarButtonItem.tintColor = self.buttonDoneColor;
//    }
//    if (self.navigationBar.topItem.rightBarButtonItem.style == UIBarButtonItemStyleDone &&
//        [self.navigationBar.topItem.rightBarButtonItem respondsToSelector:@selector(tintColor)]) {
//        self.navigationBar.topItem.rightBarButtonItem.tintColor = self.buttonDoneColor;
//    }
    if (self.navigationItem.leftBarButtonItem.style == UIBarButtonItemStyleDone &&
        [self.navigationItem.leftBarButtonItem respondsToSelector:@selector(tintColor)]) {
        self.navigationItem.leftBarButtonItem.tintColor = self.buttonDoneColor;
    }
    if (self.navigationItem.rightBarButtonItem.style == UIBarButtonItemStyleDone &&
        [self.navigationItem.rightBarButtonItem respondsToSelector:@selector(tintColor)]) {
        self.navigationItem.rightBarButtonItem.tintColor = self.buttonDoneColor;
    }
}

#pragma mark - UIViewController

- (void)dealloc {
    [_toolBar release];
    [_loadingView release];
    [_messageView release];
    [_hostingViewController release];
    [_navBarColor release];
    [_toolBarColor release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    DLog(@"%@", self.nibName);
    self.loadingView = [USHLoadingView viewWithController:self];
    self.messageView = [USHMessageView viewWithController:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidLoad" object:self];
    [self loadViewColors];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    DLog(@"%@", self.nibName);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidUnload" object:self];
    self.loadingView = nil;
    self.messageView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewWillAppear" object:self];
    DLog(@"%@", self.nibName);
    [self loadViewColors];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"%@", self.nibName);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidAppear" object:self];
    [self.loadingView centerView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    DLog(@"%@", self.nibName);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewWillDisappear" object:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    DLog(@"%@", self.nibName);
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewWebsite && buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.message]];
    }
}

#pragma mark - UIBarButtonItems

- (UIBarButtonItem*) leftBarButtonItem {
//    if (self.navigationBar != nil) {
//        return self.navigationBar.topItem.leftBarButtonItem;
//    }
    return self.navigationItem.leftBarButtonItem;
}

- (void) setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
//    if (self.navigationBar != nil) {
//        self.navigationBar.topItem.leftBarButtonItem = leftBarButtonItem;
//    }
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (UIBarButtonItem*) rightBarButtonItem {
//    if (self.navigationBar != nil) {
//        return self.navigationBar.topItem.rightBarButtonItem;
//    }
    return self.navigationItem.rightBarButtonItem;
}

- (void) setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
//    if (self.navigationBar != nil) {
//        self.navigationBar.topItem.rightBarButtonItem = rightBarButtonItem;
//    }
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
        UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
        CGRect frame = imageView.frame;
        frame.size.height = 40;
        imageView.frame = frame;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.navigationItem.titleView = imageView;
    }
    else {
        self.navigationItem.title = title;
    }
}

@end
