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

#import "InstancesViewController.h"
#import "IncidentsViewController.h"
#import "AddInstanceViewController.h"
#import "InstanceTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Instance.h"
#import "Messages.h"

@interface InstancesViewController ()

@end

@implementation InstancesViewController

@synthesize incidentsViewController, addInstanceViewController;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.addInstanceViewController animated:YES];
}
	 
- (IBAction) refresh:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:@"Loading..."];
	[[Ushahidi sharedUshahidi] getInstancesWithDelegate:self];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiDarkTan];
	self.evenRowColor = [UIColor ushahidiLiteBrown];
	[self showSearchBarWithPlaceholder:[Messages searchInstances]];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"willBePushed: %d", self.willBePushed);
	if (self.willBePushed || self.modalViewController != nil) {
		NSArray *instances = [[Ushahidi sharedUshahidi] getInstancesWithDelegate:self];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:instances];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:instances];
		DLog(@"Re-Adding Rows: %d", [instances count]);
	}
	[self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)dealloc {
	[addInstanceViewController release];
	[incidentsViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [self.filteredRows count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [InstanceTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	InstanceTableCell *cell = [TableCellFactory getInstanceTableCellForTable:theTableView];
	Instance *instance = [self filteredRowAtIndexPath:indexPath];
	if (instance != nil) {
		[cell setTitle:instance.name];
		[cell setURL:instance.url];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	else {
		[cell setTitle:nil];
		[cell setURL:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	Instance *instance = [self.filteredRows objectAtIndex:indexPath.row];
	[[Ushahidi sharedUshahidi] loadForDomain:instance.url];
	self.incidentsViewController.instance = instance;
	[self.navigationController pushViewController:self.incidentsViewController animated:YES];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi instances:(NSArray *)theInstances error:(NSError *)error hasChanges:(BOOL)hasChanges {
	DLog(@"");
	[self.loadingView hide];
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else if (hasChanges) {
		DLog(@"instances: %@", theInstances);
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:theInstances];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:theInstances];
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
	else {
		DLog(@"No Changes");
	}
	[self.loadingView hide];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	for (Instance *instance in self.allRows) {
		if ([instance matchesString:searchText]) {
			[self.filteredRows addObject:instance];
		}
	}
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
}

@end
