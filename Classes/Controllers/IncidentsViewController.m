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
#import "MapViewController.h"
#import "IncidentTableCell.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Incident.h"
#import "Deployment.h"
#import "MKMapView+Extension.h"
#import "MapAnnotation.h"
#import "Messages.h"
#import "Settings.h"

typedef enum {
	ViewModeReports,
	ViewModeMap
} ViewMode;

@interface IncidentsViewController ()

@end

@implementation IncidentsViewController

@synthesize addIncidentViewController, viewIncidentViewController, mapViewController, mapView, deployment, sortOrder, refreshButton;

typedef enum {
	TableSectionPending,
	TableSectionIncidents,
	TableSectionDownload
} TableSection;

typedef enum {
	SortByDate,
	SortByTitle
} SortBy;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender {
	DLog(@"");
	[self presentModalViewController:self.addIncidentViewController animated:YES];
}

- (IBAction) refresh:(id)sender {
	DLog(@"");
	self.refreshButton.enabled = NO;
	[self.loadingView showWithMessage:@"Loading..."];
	[[Ushahidi sharedUshahidi] getIncidentsWithDelegate:self];
	if ([[Settings sharedSettings] downloadMaps]) {
		[[Ushahidi sharedUshahidi] downloadIncidentMaps];	
	}
}

- (IBAction) sortOrder:(id)sender {
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == SortByDate) {
		DLog(@"SortByDate");
	}
	else if (segmentControl.selectedSegmentIndex == SortByTitle) {
		DLog(@"SortByTitle");
	}
	[self filterRows:YES];
}

- (IBAction) map:(id)sender {
	DLog(@"");
	self.mapViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:self.mapViewController animated:YES];
}

- (IBAction) toggleReportsAndMap:(id)sender {
	DLog(@"");
	UISegmentedControl *segmentControl = (UISegmentedControl *)sender;
	if (segmentControl.selectedSegmentIndex == ViewModeReports) {
		self.tableView.hidden = NO;
		self.mapView.hidden = YES;
		self.sortOrder.enabled = YES;
	}
	else if (segmentControl.selectedSegmentIndex == ViewModeMap) {
		self.tableView.hidden = YES;
		self.mapView.hidden = NO;
		[self.mapView removeAllPins];
		self.mapView.showsUserLocation = YES;
		for (Incident *incident in self.allRows) {
			[self.mapView addPinWithTitle:incident.title subtitle:[incident dateString] latitude:incident.latitude longitude:incident.longitude];
		}
		[self.mapView resizeRegionToFitAllPins:YES];
		self.sortOrder.enabled = NO
		;
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiLiteTan];
	self.oddRowColor = [UIColor ushahidiDarkTan];
	self.evenRowColor = [UIColor ushahidiLiteBrown];
	[self showSearchBarWithPlaceholder:[Messages searchIncidents]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.deployment != nil) {
		self.title = self.deployment.name;
	}
	DLog(@"willBePushed: %d", self.willBePushed);
	if (self.willBePushed) {
		NSArray *incidents = [[Ushahidi sharedUshahidi] getIncidentsWithDelegate:self];
		[self.allRows removeAllObjects];
		if (self.sortOrder.selectedSegmentIndex == SortByDate) {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByDate:)]];
		}
		else {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByTitle:)]];
		}
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:incidents];
		DLog(@"Adding Rows: %d", [incidents count]);
	}
	else if (self.modalViewController != nil) {
		DLog(@"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
		NSArray *incidents = [[Ushahidi sharedUshahidi] getIncidents];
		[self.allRows removeAllObjects];
		if (self.sortOrder == SortByDate) {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByDate:)]];
		}
		else {
			[self.allRows addObjectsFromArray:[incidents sortedArrayUsingSelector:@selector(compareByTitle:)]];
		}
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:incidents];
		DLog(@"Re-Adding Rows: %d", [incidents count]);
	}
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.view endEditing:YES];
}

- (void)dealloc {
	[addIncidentViewController release];
	[viewIncidentViewController release];
	[mapView release];
	[deployment release];
	[sortOrder release];
	[refreshButton release];
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

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [IncidentTableCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	IncidentTableCell *cell = [TableCellFactory getIncidentTableCellForTable:theTableView];
	Incident *incident = [self filteredRowAtIndexPath:indexPath];
	if (incident != nil) {
		[cell setTitle:incident.title];
		[cell setLocation:incident.location];
		[cell setCategory:[incident categoryNames]];
		[cell setDate:[incident dateString]];
		Photo *photo = [incident getFirstPhoto];
		if (photo != nil) {
			if (photo.thumbnail != nil) {
				[cell setImage:photo.thumbnail];
			}
			else {
				[cell setImage:nil];
				[photo downloadWithDelegate:self];
			}
		}
		else {
			[cell setImage:nil];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	else {
		[cell setTitle:nil];
		[cell setLocation:nil];
		[cell setCategory:nil];
		[cell setDate:nil];
		[cell setImage:nil];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	self.viewIncidentViewController.incident = [self.filteredRows objectAtIndex:indexPath.row];
	self.viewIncidentViewController.incidents = self.filteredRows;
	[self.navigationController pushViewController:self.viewIncidentViewController animated:YES];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	NSArray *incidents = (self.sortOrder.selectedSegmentIndex == SortByDate)
		? [self.allRows sortedArrayUsingSelector:@selector(compareByDate:)]
		: [self.allRows sortedArrayUsingSelector:@selector(compareByTitle:)];
	for (Incident *incident in incidents) {
		if ([incident matchesString:searchText]) {
			[self.filteredRows addObject:incident];
		}
	}
	DLog(@"Re-Adding Rows");
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
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

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi incidents:(NSArray *)theIncidents pending:(NSArray *)pending error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		if ([self.loadingView isShowing]) {
			[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
		}
		[self.loadingView hide];
	}
	else if(hasChanges) {
		DLog(@"incidents: %d", [theIncidents count]);
		[self.loadingView hide];
		[self.allRows removeAllObjects];
		if (self.sortOrder.selectedSegmentIndex == SortByDate) {
			[self.allRows addObjectsFromArray:[theIncidents sortedArrayUsingSelector:@selector(compareByDate:)]];
		}
		else {
			[self.allRows addObjectsFromArray:[theIncidents sortedArrayUsingSelector:@selector(compareByTitle:)]];
		}
		[self.filteredRows removeAllObjects];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];
		[self.loadingView hide];
		DLog(@"Re-Adding Rows");
	}
	else {
		[self.loadingView hide];
		DLog(@"No Changes");
	}
	self.refreshButton.enabled = YES;
}

- (void) uploadedToUshahidi:(Ushahidi *)ushahidi incident:(Incident *)incident error:(NSError *)error {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
	}
	else if (incident != nil){
		DLog(@"Incident: %@", incident.title);
	}
	else {
		DLog(@"Incident is NULL");
	}
}

#pragma mark -
#pragma mark MKMapView

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MKPinAnnotationView"] autorelease];
	annotationView.animatesDrop = YES;
	annotationView.canShowCallout = YES;
	if ([annotation class] == MKUserLocation.class) {
		annotationView.pinColor = MKPinAnnotationColorGreen;
	}
	else {
		annotationView.pinColor = MKPinAnnotationColorRed;
		UIButton *annotationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[annotationButton addTarget:self action:@selector(annotationClicked:) forControlEvents:UIControlEventTouchUpInside];
		annotationView.rightCalloutAccessoryView = annotationButton;
	}
	return annotationView;
}

- (void) annotationClicked:(UIButton *)button {
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[[button superview] superview];
	MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
	DLog(@"title:%@ latitude:%f longitude:%f", mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
	self.viewIncidentViewController.incident = [self rowAtIndex:mapAnnotation.index];
	self.viewIncidentViewController.incidents = self.allRows;
	[self.navigationController pushViewController:self.viewIncidentViewController animated:YES];	
}

#pragma mark -
#pragma mark PhotoDelegate

- (void)photoDownloaded:(Photo *)photo indexPath:(NSIndexPath *)indexPath {
	DLog(@"photoDownloaded: %@", photo.url);
	IncidentTableCell *cell = (IncidentTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	if (cell != nil && photo != nil && photo.thumbnail != nil) {
		[cell setImage:photo.thumbnail];
	}
}

@end
