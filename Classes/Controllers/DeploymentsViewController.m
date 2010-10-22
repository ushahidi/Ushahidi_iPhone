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
#import "Deployment.h"
#import "Messages.h"

@interface DeploymentsViewController ()

@end

@implementation DeploymentsViewController

@synthesize incidentsViewController, addDeploymentViewController, infoViewController;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.addDeploymentViewController animated:YES];
}
	 
- (IBAction) refresh:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:@"Loading..."];
	[[Ushahidi sharedUshahidi] getDeploymentsWithDelegate:self];
}

- (void) info:(id)sender {
	DLog(@"info");
	self.infoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:self.infoViewController animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiDarkTan];
	self.evenRowColor = [UIColor ushahidiLiteBrown];
	[self showSearchBarWithPlaceholder:[Messages searchServers]];
	
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
		NSArray *deployments = [[Ushahidi sharedUshahidi] getDeploymentsWithDelegate:self];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:deployments];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:deployments];
		DLog(@"Re-Adding Rows: %d", [deployments count]);
	}
	[self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)dealloc {
	[addDeploymentViewController release];
	[incidentsViewController release];
	[infoViewController release];
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
	return [DeploymentTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	DeploymentTableCell *cell = [TableCellFactory getDeploymentTableCellForTable:theTableView];
	Deployment *deployment = [self filteredRowAtIndexPath:indexPath];
	if (deployment != nil) {
		[cell setTitle:deployment.name];
		[cell setURL:deployment.url];
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
	Deployment *deployment = [self.filteredRows objectAtIndex:indexPath.row];
	[[Ushahidi sharedUshahidi] loadForDomain:deployment.url];
	self.incidentsViewController.deployment = deployment;
	[self.navigationController pushViewController:self.incidentsViewController animated:YES];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi deployments:(NSArray *)theDeployments error:(NSError *)error hasChanges:(BOOL)hasChanges {
	DLog(@"");
	[self.loadingView hide];
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else if (hasChanges) {
		DLog(@"deployments: %@", theDeployments);
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:theDeployments];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:theDeployments];
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
	for (Deployment *deployment in self.allRows) {
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
