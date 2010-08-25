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

#import "IncidentsViewController.h"
#import "AddIncidentViewController.h"
#import "ViewIncidentViewController.h"
#import "SubtitleTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Instance.h"

typedef enum {
	ViewModeReports,
	ViewModeMap
} ViewMode;

@interface IncidentsViewController ()

@end

@implementation IncidentsViewController

@synthesize addIncidentViewController, viewIncidentViewController, mapView, instance;

#pragma mark -
#pragma mark Handlers

- (IBAction) action:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle: @"Cancel" 
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
	[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
	[actionSheet showInView:[self view]];
	[actionSheet release];
}

- (IBAction) add:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.addIncidentViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:@"Loading..."];
	[[Ushahidi sharedUshahidi] getIncidentsWithDelegate:self];
}

- (IBAction) search:(id)sender {
	DLog(@"");
	[self toggleSearchBar:self.searchBar animated:YES];
}

- (IBAction) toggleReportsAndMap:(id)sender {
	DLog(@"");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == ViewModeReports) {
		self.tableView.hidden = NO;
		self.mapView.hidden = YES;
		self.searchButton.enabled = YES;
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeMap) {
		self.tableView.hidden = YES;
		self.mapView.hidden = NO;
		self.searchButton.enabled = NO;
		if (self.searchBar.frame.origin.y == 0) {
			[self toggleSearchBar:self.searchBar animated:NO];
		}
	}
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
		[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getIncidentsWithDelegate:self]];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.tableView reloadData];	
	}
	if (self.instance != nil) {
		self.title = self.instance.name;
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
	[addIncidentViewController release];
	[viewIncidentViewController release];
	[mapView release];
	[instance release];
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
	SubtitleTableCell *cell = [TableCellFactory getSubtitleTableCellWithDefaultImage:[UIImage imageNamed:@"no_image.png"] table:theTableView];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	Incident *incident = [self.filteredRows objectAtIndex:indexPath.row];
	if (incident != nil && [incident isKindOfClass:[Incident class]]) {
		[cell setText:incident.title];
		[cell setDescription:incident.description];
	}
	else {
		[cell setText:nil];
		[cell setDescription:nil];	
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	self.viewIncidentViewController.incident = [self.filteredRows objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:self.viewIncidentViewController animated:YES];
}

- (void)tableView:(UITableView *)theTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = (indexPath.row % 2) ? [UIColor ushahidiLiteBrown] : [UIColor ushahidiDarkBrown];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
	DLog(@"searchText: %@", searchText);
	[self.filteredRows removeAllObjects];
	for (Incident *incident in self.allRows) {
		if ([incident matchesString:searchText]) {
			[self.filteredRows addObject:incident];
		}
	}
	[self.tableView reloadData];	
	[self.tableView flashScrollIndicators];
}   

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	DLog(@"searchText: %@", theSearchBar.text);
	[self.filteredRows removeAllObjects];
	for (Incident *incident in self.allRows) {
		if ([incident matchesString:theSearchBar.text]) {
			[self.filteredRows addObject:incident];
		}
	}
	[self.tableView reloadData];	
	[self.tableView flashScrollIndicators];
	[theSearchBar resignFirstResponder];
}   
#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)theIncidents error:(NSError *)error {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else {
		DLog(@"incidents: %d", [theIncidents count]);
		[self.loadingView hide];
		[self.allRows removeAllObjects];
		[self.allRows addObjectsFromArray:theIncidents];
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];
	}
}

@end
