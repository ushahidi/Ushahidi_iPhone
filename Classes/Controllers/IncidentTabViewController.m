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

#import "IncidentTabViewController.h"
#import "IncidentTableViewController.h";
#import "IncidentMapViewController.h";
#import "CheckinMapViewController.h";
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"

@interface IncidentTabViewController ()

- (void) showViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *) getViewControllerForView:(UIView *)view;

@end

@implementation IncidentTabViewController

@synthesize incidentTableViewController, incidentMapViewController, checkinMapViewController, viewMode, deployment;

#pragma mark -
#pragma mark Enums

typedef enum {
	ViewModeTable,
	ViewModeMap,
	ViewModeCheckin
} ViewMode;

#pragma mark -
#pragma mark Handlers

- (IBAction) viewModeChanged:(id)sender {
	BOOL shouldPopulate = self.willBePushed;
	BOOL shouldAnimate = self.wasPushed;
	BOOL shouldResize = self.willBePushed;
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == ViewModeTable) {
		DLog(@"ViewModeTable populate:%d animate:%d resize:%d", shouldPopulate, shouldAnimate, shouldResize);
		self.incidentTableViewController.deployment = self.deployment;
		[self showViewController:self.incidentTableViewController animated:shouldAnimate];
		[self.incidentTableViewController populate:shouldPopulate];
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeMap) {
		DLog(@"ViewModeMap populate:%d animate:%d resize:%d", shouldPopulate, shouldAnimate, shouldResize);
		self.incidentMapViewController.deployment = self.deployment;
		[self showViewController:self.incidentMapViewController animated:shouldAnimate];
		[self.incidentMapViewController populate:shouldPopulate resize:shouldResize];
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeCheckin) {
		DLog(@"ViewModeCheckin populate:%d animate:%d resize:%d", shouldPopulate, shouldAnimate, shouldResize);
		self.checkinMapViewController.deployment = self.deployment;
		[self showViewController:self.checkinMapViewController animated:shouldAnimate];
		[self.checkinMapViewController populate:shouldPopulate resize:shouldResize];
	}
}

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

#pragma mark -
#pragma mark UIViewController

- (void)viewDidUnload {
    [super viewDidUnload];
	incidentTableViewController = nil;
	incidentMapViewController = nil;
	checkinMapViewController = nil;
	viewMode = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.deployment != nil) {
		self.title = self.deployment.name;
	}
	if (self.incidentTableViewController.view.superview == nil && 
		self.incidentMapViewController.view.superview == nil && 
		self.checkinMapViewController.view.superview == nil) {
		self.incidentTableViewController.deployment = self.deployment;
		[self.incidentTableViewController populate:self.willBePushed];
		[self showViewController:self.incidentTableViewController animated:NO];
	}
	else if (self.incidentTableViewController.view.superview != nil) {
		[self.incidentTableViewController populate:self.willBePushed];
	}
	else if(self.incidentMapViewController.view.superview != nil) {
		[self.incidentMapViewController populate:self.willBePushed resize:self.willBePushed];
	}
	else if (self.checkinMapViewController.view.superview != nil) {
		[self.checkinMapViewController populate:self.willBePushed resize:self.willBePushed];	
	}	
	if ([[Ushahidi sharedUshahidi] supportsCheckins:self.deployment]) {
		if ([self.viewMode numberOfSegments] < ViewModeCheckin + 1) {
			[self.viewMode insertSegmentWithImage:[UIImage imageNamed:@"checkin.png"] 
										  atIndex:ViewModeCheckin 
										 animated:NO];
		}
		if ([Device isIPad]) {
			[self.viewMode setFrameWidth:225];
		}
		else {
			[self.viewMode setFrameWidth:115];
		}
	}
	else {
		if ([self.viewMode numberOfSegments] > ViewModeMap + 1) {
			[self.viewMode removeSegmentAtIndex:ViewModeCheckin animated:NO];
			[self.viewMode setSelectedSegmentIndex:ViewModeTable];
		}
		if ([Device isIPad]) {
			[self.viewMode setFrameWidth:150];
		}
		else {
			[self.viewMode setFrameWidth:80];
		}
	}
	if (animated) {
		[[Settings sharedSettings] setLastIncident:nil];
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([[Ushahidi sharedUshahidi] supportsCheckins:self.deployment]) {
		[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Map button to view the report map, the Pin button to view checkins, the Filter button to filter by category or the Compose button to create a new incident report.", nil)];
	}
	else {
		[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Map button to view the report map, the Filter button to filter by category or the Compose button to create a new incident report.", nil)];
	}	
}

- (void)dealloc {
	[incidentTableViewController release];
	[incidentMapViewController release];
	[checkinMapViewController release];
	[viewMode release];
	[deployment release];
    [super dealloc];
}

@end
