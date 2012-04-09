/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
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

#import "BaseViewController.h"
#import "WebViewController.h"
#import "LoadingViewController.h"
#import "Settings.h"
#import "AppDelegate.h"
#import "Device.h"
#import "UIView+Extension.h"

@interface BaseViewController ()

@property(nonatomic, retain) UIViewController *hostingViewController;

- (void) deviceShaken;
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardDidShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) keyboardDidHide:(NSNotification *)notification;

@end

@implementation BaseViewController

@synthesize loadingView, inputView, alertView, willBePushed, wasPushed, webViewController, navigationBar, toolBar;
@synthesize editing, hostingViewController;

#pragma mark -
#pragma mark Handlers

- (void) presentModalViewController:(BaseViewController *)viewController {
    [self presentModalViewController:viewController animated:YES];
}

- (void) presentModalViewController:(BaseViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        viewController.hostingViewController = self;
    }
    if (viewController.modalPresentationStyle == UIModalPresentationFormSheet || 
        viewController.modalPresentationStyle == UIModalPresentationPageSheet) {
        if ([Device isIPad]) {
            [self viewWillDisappear:animated];
        }
    }
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]) {
        DLog(@"presentViewController:%@ animated:%d", viewController.nibName, animated);
        [self presentViewController:viewController animated:animated completion:nil];
    } 
    else {
        DLog(@"presentModalViewController:%@ animated:%d", viewController.nibName, animated);
        [super presentModalViewController:viewController animated:animated]; 
    } 
    if (viewController.modalPresentationStyle == UIModalPresentationFormSheet || 
        viewController.modalPresentationStyle == UIModalPresentationPageSheet) {
        if ([Device isIPad]) {
            [self viewDidDisappear:animated];
        }
    }
}

- (void) dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) dismissModalViewControllerAnimated:(BOOL)animated {
    if (self.hostingViewController && [Device isIPad]) {
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
    if (self.hostingViewController && [Device isIPad]) {
        [self.hostingViewController viewDidAppear:animated];
    }
}

- (void) deviceShaken {
	DLog(@"deviceShaken");
	if ([[Settings sharedSettings] becomeDiscrete]) {
		if ([self isKindOfClass:[WebViewController class]]) {
			[self dismissModalViewControllerAnimated:YES];
		}
		else {
			self.webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            self.webViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			[self presentModalViewController:self.webViewController animated:YES];
		}
	}
}

- (void) setBackButtonTitle:(NSString *)text {
	self.navigationItem.backBarButtonItem = 
	[[[UIBarButtonItem alloc] initWithTitle:text
									  style:UIBarButtonItemStyleBordered
									 target:nil
									 action:nil] autorelease];
}

- (void)pushDetailsViewController:(BaseViewController *)viewController {
    [self pushDetailsViewController:viewController animated:YES];
}

- (void)pushDetailsViewController:(BaseViewController *)viewController animated:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate pushDetailsViewController:viewController animated:animated];
}

- (void)setDetailsViewController:(BaseViewController *)viewController {
    [self setDetailsViewController:viewController animated:YES];
}

- (void)setDetailsViewController:(BaseViewController *)viewController animated:(BOOL)animated {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setDetailsViewController:viewController animated:animated];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.tintColor = [[Settings sharedSettings] navBarTintColor];
	self.navigationBar.tintColor = [[Settings sharedSettings] navBarTintColor];
    self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
	self.alertView = [[AlertView alloc] initWithController:self];
	self.inputView = [[InputView alloc] initForDelegate:self];
    self.loadingView = [[LoadingViewController alloc] initWithController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	DLog(@"%@", self.nibName);
	self.loadingView = nil;
	self.inputView = nil;
	self.alertView = nil;
}

- (void)dealloc {
	[webViewController release];
	[navigationBar release];
	[loadingView release];
	[inputView release];
	[alertView release];
	[toolBar release];
    [super dealloc];
}

- (void)viewWillBePushed {
	//DLog(@"%@", self.nibName);
	self.willBePushed = YES;
}

- (void)viewWasPushed {
	//DLog(@"%@", self.nibName);
	self.wasPushed = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"%@", self.nibName);
    if (self.view.superview != nil || [Device isIPhone]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
     	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    DLog(@"%@", self.nibName);
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    DLog(@"%@", self.nibName);
	self.willBePushed = NO;
	self.wasPushed = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
    DLog(@"%@", self.nibName);
    if (self.view.superview != nil || [Device isIPhone]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	}
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	DLog(@"%@", self.nibName);
}

#pragma mark -
#pragma mark Keyboard

-(void) keyboardWillShow:(NSNotification *)notification {
    if ([self.view isInsidePopover] == NO) {
        CGRect keyboardBounds = CGRectMake(0, 0, 0, 0);
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
        CGFloat keyboardHeight;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                keyboardHeight = keyboardBounds.size.height;
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                keyboardHeight = keyboardBounds.size.width;
                break;
        }
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height -= keyboardHeight;
        [UIView beginAnimations:@"keyboardWillShow" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = viewFrame;
        //DLog(@"keyboardWillShow nib:%@ keyboard:%f view:%f", self.nibName, keyboardHeight, viewFrame.size.height);
        [UIView commitAnimations];
    }
}

-(void) keyboardDidShow:(NSNotification *)notification {
	self.editing = YES;
}

-(void) keyboardWillHide:(NSNotification *)notification {
    if ([self.view isInsidePopover] == NO) {
        CGRect keyboardBounds = CGRectMake(0, 0, 0, 0);
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
        CGFloat keyboardHeight = 0;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                keyboardHeight = keyboardBounds.size.height;
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                keyboardHeight = keyboardBounds.size.width;
                break;
        }
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect viewFrame = self.view.frame;
        viewFrame.size.height += keyboardHeight;
        [UIView beginAnimations:@"keyboardWillHide" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = viewFrame;
        //DLog(@"keyboardWillHide nib:%@ keyboard:%f view:%f", self.nibName, keyboardHeight, viewFrame.size.height);
        [UIView commitAnimations];
    }
}

-(void) keyboardDidHide:(NSNotification *)notification {
	self.editing = NO;
}

@end
