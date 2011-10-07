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
#import "BaseTabViewController.h"
#import "IncidentTableViewController.h"
#import "IncidentMapViewController.h"
#import "SettingsViewController.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"

@interface IncidentTabViewController ()

@end

@implementation IncidentTabViewController

@synthesize incidentTableViewController, incidentMapViewController;

#pragma mark -
#pragma mark Handlers

- (IBAction) viewModeChanged:(id)sender {
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	BOOL populate = NO;
	BOOL animate = (segmentControl.tag == ShouldAnimateYes);
	BOOL resize = NO;
	if (segmentControl.selectedSegmentIndex == ViewModeTable) {
		if (self.incidentTableViewController.deployment != self.deployment) {
			self.incidentTableViewController.deployment = self.deployment;
			populate = YES;
			resize = YES;
		}
		DLog(@"ViewModeTable populate:%d animate:%d", populate, animate);
		[self showViewController:self.incidentTableViewController animated:animate];
		[self.incidentTableViewController populate:populate];
		segmentControl.tag = ShouldAnimateYes;
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeMap) {
		if (self.incidentMapViewController.deployment != self.deployment) {
			self.incidentMapViewController.deployment = self.deployment;
			populate = YES;
			resize = YES;
		}
		DLog(@"ViewModeMap populate:%d animate:%d resize:%d", populate, animate, resize);
		[self showViewController:self.incidentMapViewController animated:animate];
		[self.incidentMapViewController populate:populate resize:resize];
		segmentControl.tag = ShouldAnimateYes;
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setBackButtonTitle:NSLocalizedString(@"Reports", nil)];
} 

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"willBePushed: %d", self.willBePushed);
	if (self.incidentTableViewController.view.superview == nil && 
		self.incidentMapViewController.view.superview == nil) {
		self.incidentTableViewController.deployment = self.deployment;
		[self.incidentTableViewController populate:self.willBePushed];
		[self showViewController:self.incidentTableViewController animated:NO];
	}
	else if (self.incidentTableViewController.view.superview != nil) {
		[self.incidentTableViewController populate:self.willBePushed];
	}
	else if(self.incidentMapViewController.view.superview != nil) {
		[self.incidentMapViewController populate:self.willBePushed 
										  resize:self.willBePushed];
	}
	if ([self.viewMode numberOfSegments] >= ViewModeCheckin + 1) {
		self.viewMode.tag = ShouldAnimateNo;
		if (self.viewMode.selectedSegmentIndex == ViewModeCheckin) {
			[self.viewMode setSelectedSegmentIndex:ViewModeTable];
		}
		else {
			NSInteger selectedSegmentIndex = self.viewMode.selectedSegmentIndex;
			[self.viewMode setSelectedSegmentIndex:UISegmentedControlNoSegment];
			[self.viewMode setSelectedSegmentIndex:selectedSegmentIndex];
		}
		[self.viewMode removeSegmentAtIndex:ViewModeCheckin animated:NO];
	}
	if ([Device isIPad]) {
		[self.viewMode setFrameWidth:150];
	}
	else {
		[self.viewMode setFrameWidth:80];
	}
	if (animated) {
		[[Settings sharedSettings] setLastIncident:nil];
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Map button to view the report map, the Filter button to filter by category or the Compose button to create a new incident report.", nil)];
}

- (void)dealloc {
	[incidentTableViewController release];
	[incidentMapViewController release];
	[super dealloc];
}

@end
