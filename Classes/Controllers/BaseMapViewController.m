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

#import "BaseMapViewController.h"
#import "Settings.h"

@interface BaseMapViewController()

@end

@implementation BaseMapViewController

@synthesize refreshButton, filterButton, mapType, itemPicker, mapView, filterLabel;

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
	self.itemPicker = [[ItemPicker alloc] initWithDelegate:self forController:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.itemPicker = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[mapType release];
	[filterButton release];
	[mapView release];
	[filterLabel release];
	[itemPicker release];
	[super dealloc];
}

#pragma mark -
#pragma mark Handlers

- (IBAction) mapTypeChanged:(id)sender {
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	self.mapView.mapType = segmentedControl.selectedSegmentIndex;
}

@end
