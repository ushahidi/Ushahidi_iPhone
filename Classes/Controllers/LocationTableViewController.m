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

#import "LocationTableViewController.h"
#import "LoadingViewController.h"
#import "Incident.h"
#import "Location.h"
#import "TableCellFactory.h"
#import "MKMapView+Extension.h"
#import "MKPinAnnotationView+Extension.h"
#import "MapAnnotation.h"
#import "NSString+Extension.h"
#import "Settings.h"

@interface LocationTableViewController ()

@property(nonatomic, retain) NSString *location;
@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;
@property(nonatomic, retain) NSString *currentLatitude;
@property(nonatomic, retain) NSString *currentLongitude;

- (void) populateMapPins:(BOOL)centerMap;

@end

@implementation LocationTableViewController

@synthesize cancelButton, doneButton, refreshButton;
@synthesize incident, location, latitude, longitude, currentLatitude, currentLongitude;
@synthesize mapView, viewMode, containerView;

typedef enum {
	TableSectionNewLocation,
	TableSectionExistingLocations
} TableSection;

typedef enum {
	ViewModeTable,
	ViewModeMap
} ViewMode;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	[self setEditing:NO];
	self.incident.location = self.location;
	self.incident.latitude = self.latitude;
	self.incident.longitude = self.longitude;	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) viewModeChanged:(id)sender {
	if (self.viewMode.selectedSegmentIndex == ViewModeTable) {
		DLog(@"ViewModeTable");
		CGRect rect = self.containerView.frame;
		rect.origin = CGPointMake(0, 0);
		self.tableView.frame = rect;
		[UIView beginAnimations:@"ViewModeTable" context:nil];
		[UIView setAnimationDuration:0.6];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.containerView cache:YES];
		[self.mapView removeFromSuperview];
		[self.containerView addSubview:self.tableView];
		[UIView commitAnimations];
		[self.tableView reloadData];
	}
	else if (self.viewMode.selectedSegmentIndex == ViewModeMap) {
		DLog(@"ViewModeMap");
		CGRect rect = self.containerView.frame;
		rect.origin = CGPointMake(0, 0);
		self.mapView.frame = rect;
		[UIView beginAnimations:@"ViewModeMap" context:nil];
		[UIView setAnimationDuration:0.6];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.containerView cache:YES];
		[self.tableView removeFromSuperview];
		[self.containerView addSubview:self.mapView];
		[UIView commitAnimations];
		[self populateMapPins:YES];
	}
}

- (void) populateMapPins:(BOOL)centerMap {
	[self.mapView removeAllPins];
	for (Location *theLocation in self.allRows) {
		MapAnnotation *mapAnnotation = [self.mapView addPinWithTitle:theLocation.name 
															subtitle:theLocation.coordinates 
															latitude:theLocation.latitude 
														   longitude:theLocation.longitude
															  object:theLocation
															pinColor:MKPinAnnotationColorRed];
		if (centerMap && self.incident.userLocation == NO &&
			[theLocation.name isEqualToString:self.location] &&
			[theLocation.latitude isEqualToString:self.latitude] &&
			[theLocation.longitude isEqualToString:self.longitude]) {
			[self.mapView centerAtCoordinate:mapAnnotation.coordinate withDelta:0.4 animated:NO];
			[self.mapView selectAnnotation:mapAnnotation animated:NO];
		}
	}
	if (self.currentLatitude != nil && self.currentLongitude != nil) {
		MapAnnotation *mapAnnotation = [self.mapView addPinWithTitle:NSLocalizedString(@"Current Location", nil) 
															subtitle:[NSString stringWithFormat:@"%@, %@", self.currentLatitude, self.currentLongitude] 
															latitude:self.currentLatitude
														   longitude:self.currentLongitude
															  object:nil
															pinColor:MKPinAnnotationColorGreen];
		if (centerMap && self.incident.userLocation) {
			[self.mapView centerAtCoordinate:mapAnnotation.coordinate withDelta:0.4 animated:NO];
			[self.mapView selectAnnotation:mapAnnotation animated:NO];
		}
	}
}

- (IBAction) locate:(id)sender {
	[self.loadingView showWithMessage:NSLocalizedString(@"Locating...", nil)];
	self.refreshButton.enabled = NO;
	[[Locator sharedLocator] detectLocationForDelegate:self];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search locations...", nil)];
	[self setHeader:NSLocalizedString(@"New Location", nil) atSection:TableSectionNewLocation];
	[self setHeader:NSLocalizedString(@"Existing Location", nil) atSection:TableSectionExistingLocations];
	[self.containerView addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.location = self.incident.location;
	self.latitude = self.incident.latitude;
	self.longitude = self.incident.longitude;
	self.currentLatitude = [[Locator sharedLocator] latitude];
	self.currentLongitude = [[Locator sharedLocator] longitude];
	[self.allRows removeAllObjects];
	[self.filteredRows removeAllObjects];
	[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getLocationsForDelegate:self]];
	[self.filteredRows addObjectsFromArray:self.allRows];
	if (self.viewMode.selectedSegmentIndex == ViewModeTable) {
		[self.tableView reloadData];
	}
	else if (self.viewMode.selectedSegmentIndex == ViewModeMap) {
		[self populateMapPins:YES];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[refreshButton release];
	[incident release];
	[location release];
	[currentLatitude release];
	[currentLongitude release];
	[mapView release];
	[viewMode release];
	[containerView release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionNewLocation) {
		return 1;
	}
	return self.filteredRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	CheckBoxTableCell *cell = [TableCellFactory getCheckBoxTableCellForDelegate:self table:theTableView indexPath:indexPath];
	if (indexPath.section == TableSectionNewLocation) {
		[cell setTitle:NSLocalizedString(@"Current Location", nil)];
		if (self.currentLatitude != nil &&  self.currentLongitude != nil) {
			[cell setDescription:[NSString stringWithFormat:@"%@, %@", self.currentLatitude, self.currentLongitude]];	
		}
		else {
			[cell setDescription:NSLocalizedString(@"Locating...", nil)];
		}
		if (self.incident.userLocation) {
			[cell setChecked:YES];
		}
		else {
			[cell setChecked:NO];
		}
	}
	else {
		Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
		if (theLocation != nil) {
			[cell setTitle:theLocation.name];	
			[cell setDescription:theLocation.coordinates];
			[cell setChecked:[theLocation equals:self.location
										latitude:self.latitude
									   longitude:self.longitude]];
		}
		else {
			[cell setTitle:nil];
			[cell setDescription:nil];
			[cell setChecked:NO];
		}	
	}
	return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	CheckBoxTableCell *cell = (CheckBoxTableCell *)[theTableView cellForRowAtIndexPath:indexPath];
	if (cell.checked) {
		[cell setChecked:NO];
		self.location = nil;
		self.latitude = nil;
		self.longitude = nil;
	}
	else {
		[cell setChecked:YES];
		if (indexPath.section == TableSectionNewLocation) {
			self.location = [[Locator sharedLocator] address];
			self.latitude = self.currentLatitude;
			self.longitude = self.currentLongitude;
			self.incident.userLocation = YES;
		}
		else {
			Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
			self.location = theLocation.name;
			self.latitude = theLocation.latitude;
			self.longitude = theLocation.longitude;	
			self.incident.userLocation = NO;
		}
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark CheckBoxTableCellDelegate

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
	if (indexPath.section == TableSectionNewLocation) {
		DLog(@"location:%@", [[Locator sharedLocator] address]);
		if (checked) {
			self.location = [[Locator sharedLocator] address];
			self.latitude = self.currentLatitude;
			self.longitude = self.currentLongitude;
			self.incident.userLocation = YES;
		}
	}
	else {
		Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
		DLog(@"location:%@ index:[%d, %d] checked:%d", theLocation.name, indexPath.section, indexPath.row, checked)
		if (checked) {
			self.location = theLocation.name;
			self.latitude = theLocation.latitude;
			self.longitude = theLocation.longitude;
			self.incident.userLocation = NO;
		}
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) filterRows:(BOOL)reloadTable {
	[self.filteredRows removeAllObjects];
	NSString *searchText = [self getSearchText];
	for (Location *theLocation in self.allRows) {
		if ([theLocation matchesString:searchText]) {
			[self.filteredRows addObject:theLocation];
		}
	}
	DLog(@"Re-Adding Rows");
	if (reloadTable) {
		[self.tableView reloadData];	
		[self.tableView flashScrollIndicators];
	}
} 

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		if ([self.allRows count] == 0) {
			[self.alertView showOkWithTitle:@"Server Error" andMessage:[error localizedDescription]];
		}
	}
	else if (hasChanges) {
		DLog(@"locations: %@", locations);
		[self.allRows removeAllObjects];
		[self.filteredRows removeAllObjects];
		[self.allRows addObjectsFromArray:locations];
		[self.filteredRows addObjectsFromArray:self.allRows];
		[self.tableView reloadData];
		[self.tableView flashScrollIndicators];
	}
	else {
		DLog(@"No Changes");
	}
}

#pragma mark -
#pragma mark LocatorDelegate

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)userLatitude longitude:(NSString *)userLongitude {
	DLog(@"locator: %@, %@", userLatitude, userLongitude);
	[self.loadingView hide];
	self.incident.userLocation = YES;
	self.latitude = userLatitude;
	self.longitude = userLongitude;
	self.currentLatitude = userLatitude;
	self.currentLongitude = userLongitude;
	if (self.viewMode.selectedSegmentIndex == ViewModeTable) {
		[self.tableView reloadData];
	}
	else if (self.viewMode.selectedSegmentIndex == ViewModeMap) {
		[self populateMapPins:YES];
	}
	self.refreshButton.enabled = YES;
}

- (void) locatorFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self.loadingView showWithMessage:NSLocalizedString(@"Location Error", )];
	[self.loadingView hideAfterDelay:1.5];
	self.refreshButton.enabled = YES;
}

- (void) lookupFinished:(Locator *)locator address:(NSString *)address {
	DLog(@"address:%@", address);
	self.location = address;
}

- (void) lookupFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark MKMapView

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
	for (NSObject<MKAnnotation> *annotation in theMapView.annotations) {
		if ([annotation isKindOfClass:[MapAnnotation class]]) {
			MapAnnotation *mapAnnotation = (MapAnnotation *)annotation;
			Location *theLocation = (Location *)mapAnnotation.object;
			if (theLocation != nil &&
				[theLocation.name isEqualToString:self.location] &&
				[theLocation.latitude isEqualToString:self.latitude] &&
				[theLocation.longitude isEqualToString:self.longitude]) {
				[self.mapView selectAnnotation:annotation animated:NO];
				break;
			}
			else if (theLocation == nil && self.incident.userLocation) {
				[self.mapView selectAnnotation:annotation animated:NO];
				break;
			}
		}
	}
}

- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (newState == MKAnnotationViewDragStateEnding) {
		DLog("%f, %f", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude);
		self.latitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.latitude];
		self.longitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.longitude];
		self.currentLatitude = self.latitude;
		self.currentLongitude = self.longitude;
		MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
		mapAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude];
	}
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	return [MKPinAnnotationView getPinForMap:theMapView andAnnotation:annotation];
}

- (void)mapView:(MKMapView *)theMapView didSelectAnnotationView:(MKAnnotationView *)annotationView {
	MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
	DLog(@"title:%@ latitude:%f longitude:%f", mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
	Location *theLocation = (Location *)mapAnnotation.object;
	if (theLocation != nil) {
		self.incident.userLocation = NO;
		annotationView.draggable = NO;
		self.location = theLocation.name;
		self.latitude = theLocation.latitude;
		self.longitude = theLocation.longitude;	
	}
	else {
		self.incident.userLocation = YES;
		annotationView.draggable = YES;
		self.location = nil;
		self.latitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.latitude];
		self.longitude = [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.longitude]; 
	}
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	DLog(@"latitude:%f longitude:%f", userLocation.coordinate.latitude, userLocation.coordinate.longitude);
	if (self.incident.userLocation) {
		[self.mapView centerAtCoordinate:userLocation.coordinate withDelta:0.4 animated:NO];
		[self.mapView selectAnnotation:userLocation animated:YES];	
	}
}

@end