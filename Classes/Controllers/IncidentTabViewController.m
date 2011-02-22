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
#import "Deployment.h"
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
	DLog(@"");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == ViewModeTable) {
		DLog(@"ViewModeTable");
		self.incidentTableViewController.deployment = self.deployment;
		[self showViewController:self.incidentTableViewController animated:YES];
		[self.incidentTableViewController populate:NO];
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeMap) {
		DLog(@"ViewModeMap");
		self.incidentMapViewController.deployment = self.deployment;
		[self showViewController:self.incidentMapViewController animated:YES];
		[self.incidentMapViewController populate:NO resize:NO];
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeCheckin) {
		DLog(@"ViewModeCheckin");
		self.checkinMapViewController.deployment = self.deployment;
		[self showViewController:self.checkinMapViewController animated:YES];
		[self.checkinMapViewController populate:NO resize:NO];
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

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
	if (animated) {
		[[Settings sharedSettings] setLastIncident:nil];
	}
	if ([[Ushahidi sharedUshahidi] supportsCheckins:self.deployment]) {
		if ([self.viewMode numberOfSegments] < ViewModeCheckin + 1) {
			[self.viewMode insertSegmentWithImage:[UIImage imageNamed:@"checkin.png"] 
										  atIndex:ViewModeCheckin 
										 animated:NO];
			CGRect rect = self.viewMode.frame;
			rect.size.width = 115;
			self.viewMode.frame = rect;
		}
	}
	else {
		[self.viewMode removeSegmentAtIndex:ViewModeCheckin animated:NO];
		CGRect rect = self.viewMode.frame;
		rect.size.width = 80;
		self.viewMode.frame = rect;
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
