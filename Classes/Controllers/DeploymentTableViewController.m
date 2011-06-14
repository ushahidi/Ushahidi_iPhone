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

#import "DeploymentTableViewController.h"
#import "IncidentTabViewController.h"
#import "CheckinTabViewController.h"
#import "DeploymentAddViewController.h"
#import "SettingsViewController.h"
#import "DeploymentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "UIView+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Deployment.h"
#import "NSString+Extension.h"
#import "Settings.h"

@interface DeploymentTableViewController ()

@property(nonatomic, retain) UIButton *settingsButton;

- (void) setTableEdit:(BOOL)edit;
- (void) settings:(id)sender;

@end

@implementation DeploymentTableViewController

@synthesize incidentTabViewController, deploymentAddViewController, settingsViewController, checkinTabViewController;
@synthesize addButton, editButton, refreshButton, settingsButton, tableSort;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSortDate,
	TableSortName
} TableSort;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.deploymentAddViewController animated:YES];
}

- (IBAction) edit:(id)sender {
	if (self.tableView.editing) {
		[self setTableEdit:NO];
	}
	else {
		[self setTableEdit:YES];
	}
}

- (IBAction) refresh:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
	[[Ushahidi sharedUshahidi] getVersionsForDelegate:self];
}

- (void) settings:(id)sender {
	DLog(@"");
	self.settingsViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:self.settingsViewController animated:YES];
}

- (IBAction) tableSortChanged:(id)sender {
	DLog(@"");
	[self setTableEdit:NO];
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == TableSortDate) {
		DLog(@"TableSortDate");
	}
	else if (segmentControl.selectedSegmentIndex == TableSortName) {
		DLog(@"TableSortName");
	}
	[self filterRows:YES];
}

- (void) setTableEdit:(BOOL)tableEdit {
	if (tableEdit) {
		self.tableView.editing = YES;
		self.editButton.title = NSLocalizedString(@"Done", nil);
		self.refreshButton.enabled = NO;
		self.tableSort.enabled = NO;
		self.settingsButton.enabled = NO;
		self.addButton.enabled = NO;
	}
	else {
		self.tableView.editing = NO;
		self.editButton.title = NSLocalizedString(@"Edit", nil);
		self.refreshButton.enabled = YES;
		self.tableSort.enabled = YES;
		self.settingsButton.enabled = YES;
		self.addButton.enabled = YES;
	}
}

- (void) loadedFromUshahidi:(Ushahidi *)ushahidi deployment:(Deployment *)deployment {
	DLog(@"");
	if (deployment.supportsCheckins) {
		self.checkinTabViewController.deployment = deployment;
		[self.navigationController pushViewController:self.checkinTabViewController animated:YES];
	}
	else {
		self.incidentTabViewController.deployment = deployment;
		[self.navigationController pushViewController:self.incidentTabViewController animated:YES];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search maps...", nil)];
	self.title = NSLocalizedString(@"Ushahidi Maps", nil);
	[self setBackButtonTitle:NSLocalizedString(@"Maps", nil)];
	self.settingsButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [self.settingsButton addTarget:self action:@selector(settings:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
} 

- (void)viewDidUnload {
    [super viewDidUnload];
	self.settingsButton = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setTableEdit:NO];
	DLog(@"willBePushed: %d", self.willBePushed);
	if (self.willBePushed || self.modalViewController != nil) {
		SEL sorter = self.tableSort.selectedSegmentIndex == TableSortDate
			? @selector(compareByDate:) : @selector(compareByName:);
		NSArray *deployments = [[Ushahidi sharedUshahidi] getDeploymentsUsingSorter:sorter];
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
		[[Ushahidi sharedUshahidi] unloadDeployment];
	}
	[self.tableView reloadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainQueueFinished) name:kMainQueueFinished object:nil];
	[self.loadingView hide];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Click the Info button to view app settings, Plus button to add a map or Edit button to remove a map.", nil)];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
}

- (void)dealloc {
	[incidentTabViewController release];
	[checkinTabViewController release];
	[deploymentAddViewController release];
	[settingsViewController release];
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
		if ([NSString isNilOrEmpty:deployment.description]) {
			[cell setDescription:deployment.name];
		}
		else {
			[cell setDescription:deployment.description];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	else {
		[cell setTitle:nil];
		[cell setUrl:nil];
		[cell setDescription:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.tableView.editing == NO) {
		[self.view endEditing:YES];
		[theTableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.loadingView showWithMessage:NSLocalizedString(@"Loading...", nil)];
		Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
		[[Ushahidi sharedUshahidi] loadDeployment:deployment forDelegate:self];
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
		@try {
			if([[Ushahidi sharedUshahidi] removeDeployment:deployment]) {
				[self.loadingView showWithMessage:NSLocalizedString(@"Removed", nil)];
				[self.loadingView hideAfterDelay:1.0];
				DLog(@"Removed Deployment");
				[self.allRows removeObject:deployment];
				[self.filteredRows removeObject:deployment];
				[self.tableView reloadData];
			}
			else {
				[self.alertView showOkWithTitle:NSLocalizedString(@"Remove Error", nil) 
									 andMessage:NSLocalizedString(@"There was a problem removing the map.", nil)];	
			}
		}
		@catch (NSException * e) {
			[self.alertView showOkWithTitle:NSLocalizedString(@"Remove Error", nil) 
								 andMessage:NSLocalizedString(@"There was a problem removing the map.", nil)];
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

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:0.0];
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
