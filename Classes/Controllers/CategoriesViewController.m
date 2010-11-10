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

#import "CategoriesViewController.h"
#import "LoadingViewController.h"
#import "Incident.h"
#import "Category.h"
#import "Messages.h"
#import "TableCellFactory.h"

@interface CategoriesViewController ()

@end

@implementation CategoriesViewController

@synthesize cancelButton, doneButton, incident;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showSearchBarWithPlaceholder:[Messages searchCategories]];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.allRows removeAllObjects];
	[self.filteredRows removeAllObjects];
	[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategoriesForDelegate:self]];
	[self.filteredRows addObjectsFromArray:self.allRows];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[incident release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return self.filteredRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CheckBoxTableCell *cell = [TableCellFactory getCheckBoxTableCellForDelegate:self table:theTableView];
	cell.indexPath = indexPath;
	Category *category = (Category *)[self filteredRowAtIndexPath:indexPath];
	if (category != nil) {
		[cell setTitle:category.title];	
		[cell setDescription:category.description];
		[cell setTextColor:category.color];
		[cell setChecked:[self.incident hasCategory:category]];
	}
	else {
		[cell setTitle:nil];
		[cell setDescription:nil];
		[cell setChecked:NO];
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	CheckBoxTableCell *cell = (CheckBoxTableCell *)[theTableView cellForRowAtIndexPath:indexPath];
	Category *category = (Category *)[self filteredRowAtIndexPath:indexPath];
	if (cell.checked) {
		[cell setChecked:NO];
		[self.incident removeCategory:category];
	}
	else {
		[cell setChecked:YES];
		[self.incident addCategory:category];
	}
}

#pragma mark -
#pragma mark CheckBoxTableCellDelegate

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
	Category *category = (Category *)[self filteredRowAtIndexPath:indexPath];
	DLog(@"checkBoxTableCellChanged:%@ index:[%d, %d] checked:%d", category.title, indexPath.section, indexPath.row, checked)
	if (checked) {
		[self.incident addCategory:category];
	}
	else {
		[self.incident removeCategory:category];
	}
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if(hasChanges) {
		DLog(@"categories: %d", [categories count]);
		[self.loadingView hide];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:categories];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:categories];
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];
		[self.loadingView hide];
		DLog(@"Re-Adding Rows");
	}
	else {
		[self.loadingView hide];
		DLog(@"No Changes");
	}
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	for (Category *category in self.allRows) {
		if ([category matchesString:searchText]) {
			[self.filteredRows addObject:category];
		}
	}
	DLog(@"Re-Adding Rows");
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
} 

@end
