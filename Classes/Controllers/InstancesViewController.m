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

typedef enum {
	TableSectionSearch,
	TableSectionInstances
} TableSection;

@interface InstancesViewController (Internal)

@end

@implementation InstancesViewController

@synthesize incidentsViewController, addInstanceViewController;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"add");
	[self presentModalViewController:self.addInstanceViewController animated:YES];
}
	 
- (IBAction) refresh:(id)sender {
	DLog(@"refresh");
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionSearch) {
		return 1;
	}
	if (section == TableSectionInstances) {
		return 20;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionSearch) {
		SearchTableCell *cell = [TableCellFactory getSearchTableCellWithDelegate:self table:theTableView];
		[cell setPlaceholder:@"Search instances..."];
		return cell;
	}
	else if (indexPath.section == TableSectionInstances) {
		SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"logo_image.png"] table:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		[cell setText:@"Ushahidi Demo"];
		[cell setDescription:@"http://demo.ushahidi.com"];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	[self.navigationController pushViewController:self.incidentsViewController animated:YES];
}

- (void)tableView:(UITableView *)theTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = (indexPath.row % 2) ? [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] : [UIColor clearColor];
}

#pragma mark -
#pragma mark UISearchCellDelegate

- (void) searchCellChanged:(SearchTableCell *)cell searchText:(NSString *)text {
	DLog(@"searchCellChanged: %@", text);
}

@end
