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

#import "BaseTabViewController.h"
#import "SettingsViewController.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"

@interface BaseTabViewController() 

@property(nonatomic, retain) UIButton *settingsButton;
	
@end

@implementation BaseTabViewController

@synthesize viewMode, deployment, settingsButton, settingsViewController;

#pragma mark -
#pragma mark Handlers

- (void) settings:(id)sender {
	DLog(@"");
	self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:self.settingsViewController animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	if ([NSString isNilOrEmpty:[[Settings sharedSettings] mapURL]] == NO && 
		[NSString isNilOrEmpty:[[Settings sharedSettings] mapName]] == NO) {
		self.settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
		[self.settingsButton addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
	}
} 

- (void)viewDidUnload {
    [super viewDidUnload];
	self.settingsButton = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.deployment != nil) {
		self.title = self.deployment.name;
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)dealloc {
	[settingsViewController release];
	[viewMode release];
	[deployment release];
	[settingsButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Helpers

- (void) showViewController:(UIViewController *)viewController animated:(BOOL)animated {
	viewController.view.frame = self.view.frame;
	if (animated) {
		[UIView beginAnimations:[viewController nibName] context:nil];
		[UIView setAnimationDuration:0.6];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
	}
	if ([self.view.subviews count] > 0) {
		UIView *subview = [self.view.subviews objectAtIndex:0];
		if (subview != nil) {
			UIViewController *subViewController = [self getViewControllerForView:subview];
			if (subViewController != nil) {
				[subViewController viewWillDisappear:animated];
			}
			[subview removeFromSuperview];
			if (subViewController != nil) {
				[subViewController viewDidDisappear:animated];
			}
		}
	}
	[viewController viewWillAppear:animated];
	[self.view addSubview:viewController.view];
	[viewController viewDidAppear:animated];
	if (animated) {
		[UIView commitAnimations];
	}
}

- (UIViewController *) getViewControllerForView:(UIView *)theView {
	for (UIView* next = [theView superview]; next; next = next.superview) {
		UIResponder* nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}

@end
