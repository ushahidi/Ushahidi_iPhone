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

#import "BaseSortTableViewController.h"
#import "Deployment.h"
#import "ItemPicker.h"

@interface BaseSortTableViewController()

@end

@implementation BaseSortTableViewController

@synthesize tableSort, refreshButton, filterButton, itemPicker;

- (IBAction) sortChanged:(id)sender {
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == TableSortDate) {
		DLog(@"TableSortDate");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortTitle) {
		DLog(@"TableSortTitle");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortVerified) {
		DLog(@"TableSortVerified");
	}
	[self filterRows:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
	[tableSort release];
	[itemPicker release];
	[super dealloc];
}

@end
