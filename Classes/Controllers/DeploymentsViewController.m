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

#import "DeploymentsViewController.h"
#import "IncidentsViewController.h"
#import "AddDeploymentViewController.h"
#import "InfoViewController.h"
#import "DeploymentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Deployment.h"b

@interface DeploymentsViewController ()

@end

@implementation DeploymentsViewController

@synthesize incidentsViewController, addDeploymentViewController, infoViewController, editButton, refreshButton, tableSort;

typedef enum {
	TableSortDate,
	TableSortName
} TableSort;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.addDeploymentViewController animated:YES];
}

- (IBAction) edit:(id)sender {
	if (self.tableView.editing) {
		self.tableView.editing = NO;
		self.editButton.title = NSLocalizedString(@"Edit", nil);
	}
	else {
		self.tableView.editing = YES;
		self.editButton.title = NSLocalizedString(@"Done", nil);
	}
}

- (IBAction) refresh:(id)sender {
	DLog(@"");
	self.tableView.editing = NO;
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getDeploymentsForDelegate:self];
}

- (void) info:(id)sender {
	DLog(@"");
	self.tableView.editing = NO;
	self.infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:self.infoViewController animated:YES];
}

- (IBAction) tableSortChanged:(id)sender {
	DLog(@"");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == TableSortDate) {
		DLog(@"TableSortDate");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortName) {
		DLog(@"TableSortTitle");
	}
	[self filterRows:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiDarkTan];
	self.evenRowColor = [UIColor ushahidiLiteBrown];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search deployments...", nil)];
	
	UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarButton = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    self.navigationItem.leftBarButtonItem = infoBarButton;
    [infoBarButton release];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"willBePushed: %d", self.willBePushed);
	if (self.willBePushed || self.modalViewController != nil) {
		SEL sorter = self.tableSort.selectedSegmentIndex == TableSortDate
			? @selector(compareByDate:) : @selector(compareByName:);
		NSArray *deployments = [[[Ushahidi sharedUshahidi] getDeploymentsForDelegate:self] sortedArrayUsingSelector:sorter];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:deployments];
		[self.filteredRows removeAllObjects];
		NSString *searchText = [self getSearchText];
		for (Deployment *deploment in deployments) {
			if ([deploment matchesString:searchText]) {
				[self.filteredRows addObject:deploment];
			}
		}
		DLog(@"Re-Adding Rows: %d", [deployments count]);
	}
	if (animated) {
		[[Ushahidi sharedUshahidi] loadDeployment:nil];
	}
	[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Info button to view app settings, the Plus button to add a deployment or the Edit button to remove a deployment.", nil)];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)dealloc {
	[addDeploymentViewController release];
	[incidentsViewController release];
	[infoViewController release];
	[editButton release];
	[refreshButton release];
	[tableSort release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [DeploymentTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DeploymentTableCell *cell = [TableCellFactory getDeploymentTableCellForTable:theTableView indexPath:indexPath];
	Deployment *deployment = [self filteredRowAtIndexPath:indexPath];
	if (deployment != nil) {
		[cell setTitle:deployment.name];
		[cell setUrl:deployment.url];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	else {
		[cell setTitle:nil];
		[cell setUrl:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tableView.editing) {
		self.tableView.editing = NO;
		self.editButton.title = NSLocalizedString(@"Edit", nil);
	}
	[self.view endEditing:YES];
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
	[[Ushahidi sharedUshahidi] loadDeployment:deployment];
	self.incidentsViewController.deployment = deployment;
	[self.navigationController pushViewController:self.incidentsViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
		if([[Ushahidi sharedUshahidi] removeDeployment:deployment]) {
			DLog(@"Removed Deployment");
			[self.allRows removeObject:deployment];
			[self.filteredRows removeObject:deployment];
			[self.tableView reloadData];
		}
		else {
			[self.alertView showOkWithTitle:NSLocalizedString(@"Error", nil) 
								 andMessage:NSLocalizedString(@"Unable to remove deployment", nil)];	
		}
	}	
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi deployments:(NSArray *)deployments error:(NSError *)error hasChanges:(BOOL)hasChanges {
	DLog(@"");
	[self.loadingView hide];
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showOkWithTitle:NSLocalizedString(@"Error", nil) 
							 andMessage:[error localizedDescription]];
	}
	else if (hasChanges) {
		DLog(@"Has Changes: %d", [deployments count]);
		NSArray *sortedDeployments;
		if (self.tableSort.selectedSegmentIndex == TableSortDate) {
			sortedDeployments = [deployments sortedArrayUsingSelector:@selector(compareByDate:)];
		}
		else {
			sortedDeployments = [deployments sortedArrayUsingSelector:@selector(compareByName:)];
		}
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:sortedDeployments];
		NSString *searchText = [self getSearchText];
		[self.filteredRows removeAllObjects];
		for (Deployment *deployment in sortedDeployments) {
			if ([deployment matchesString:searchText]) {
				[self.filteredRows addObject:deployment];
			}
		}
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
	else {
		DLog(@"No Changes");
	}
	[self.loadingView hide];
	self.refreshButton.enabled = YES;
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	NSString *searchText = [self getSearchText];
	NSArray *deployments;
	if (self.tableSort.selectedSegmentIndex == TableSortDate) {
		deployments = [self.allRows sortedArrayUsingSelector:@selector(compareByDate:)];
	}
	else {
		deployments = [self.allRows sortedArrayUsingSelector:@selector(compareByName:)];
	}
	[self.filteredRows removeAllObjects];
	for (Deployment *deployment in deployments) {
		if ([deployment matchesString:searchText]) {
			[self.filteredRows addObject:deployment];
		}
	}
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
}

@end
