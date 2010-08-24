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
#import "SubtitleTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Instance.h"

@interface InstancesViewController ()

@end

@implementation InstancesViewController

@synthesize incidentsViewController, addInstanceViewController;

- (void) filterRowsWithSearchText:(NSString *)searchText {

}

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

- (IBAction) search:(id)sender {
	DLog(@"");
	[self toggleSearchBar:self.searchBar animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiTan];
	[self toggleSearchBar:self.searchBar animated:NO];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.navigationController.topViewController == self) {
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getInstancesWithDelegate:self]];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.tableView reloadData];
	}
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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
	[addInstanceViewController release];
	[incidentsViewController release];
	[searchBar release];
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

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"logo_image.png"] table:theTableView];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	Instance *instance = [self.filteredRows objectAtIndex:indexPath.row];
	if (instance != nil) {
		[cell setText:instance.name];
		[cell setDescription:instance.url];	
		[cell setImage:instance.logo];
	}
	else {
		[cell setText:nil];
		[cell setDescription:nil];	
		[cell setImage:nil];
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

- (void)tableView:(UITableView *)theTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = (indexPath.row % 2) ? [UIColor ushahidiLiteBrown] : [UIColor ushahidiDarkBrown];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi instances:(NSArray *)theInstances error:(NSError *)error {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else {
		DLog(@"instances: %@", theInstances);
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:theInstances];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	DLog(@"searchText: %@", searchText);
	[self.filteredRows removeAllObjects];
	for (Instance *instance in self.allRows) {
		if ([instance matchesString:searchText]) {
			[self.filteredRows addObject:instance];
		}
	}
	[self.tableView reloadData];	
	[self.tableView flashScrollIndicators];
}   

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	DLog(@"searchText: %@", theSearchBar.text);
	[self.filteredRows removeAllObjects];
	for (Instance *instance in self.allRows) {
		if ([instance matchesString:theSearchBar.text]) {
			[self.filteredRows addObject:instance];
		}
	}
	[self.tableView reloadData];	
	[self.tableView flashScrollIndicators];
	[theSearchBar resignFirstResponder];
}   

@end
