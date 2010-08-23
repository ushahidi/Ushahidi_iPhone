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

#import "TableViewController.h"
#import "TableCellFactory.h"

@interface TableViewController ()

@end

@implementation TableViewController

@synthesize tableView, allRows, filteredRows;

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.allRows = [[NSMutableArray alloc] initWithCapacity:0];
	self.filteredRows = [[NSMutableArray alloc] initWithCapacity:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[allRows release];
	[filteredRows release];
	[tableView release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 0;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [self.filteredRows count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [TableCellFactory getDefaultTableCellForTable:theTableView];
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

@end
