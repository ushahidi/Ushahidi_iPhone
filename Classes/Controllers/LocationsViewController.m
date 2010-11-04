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

#import "LocationsViewController.h"
#import "LoadingViewController.h"
#import "Incident.h"
#import "Location.h"
#import "Messages.h"
#import "TableCellFactory.h"
#import "MKMapView+Extension.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController

@synthesize mapView, cancelButton, doneButton, incident, location, locationType, toolBar;

typedef enum {
	LocationTypeExisting,
	LocationTypeNew
} LocationType;

#pragma mark -
#pragma mark Handlers

- (IBAction) locate:(id)sender {
	DLog(@"");
	[self.mapView removeAllPins];
	self.mapView.showsUserLocation = YES;
	self.tableView.hidden = YES;
	self.mapView.hidden = NO;
	self.toolBar.hidden = NO;
	self.locationType.selectedSegmentIndex = LocationTypeNew;
}

- (IBAction) locationTypeChanged:(id)sender {
	if (self.locationType.selectedSegmentIndex == LocationTypeExisting) {
		//self.mapView.showsUserLocation = NO;
		self.tableView.hidden = NO;
		self.mapView.hidden = YES;
		self.toolBar.hidden = YES;
	} 
	else if (self.locationType.selectedSegmentIndex == LocationTypeNew) {
		self.tableView.hidden = YES;
		self.mapView.hidden = NO;
		self.toolBar.hidden = NO;
		self.location = nil;
	}
}

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	if (self.location != nil) {
		self.incident.location = [location name];
		self.incident.latitude = [location latitude];
		self.incident.longitude = [location longitude];	
	}
	else {
		[self setEditing:NO];
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showSearchBarWithPlaceholder:[Messages searchLocations]];
}

- (void)viewWillAppear:(BOOL)animated {
	self.mapView.showsUserLocation = NO;
	[self.mapView removeAllPins];
	self.locationType.selectedSegmentIndex = LocationTypeExisting;
	[self.allRows removeAllObjects];
	[self.filteredRows removeAllObjects];
	[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getLocationsWithDelegate:self]];
	[self.filteredRows addObjectsFromArray:self.allRows];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[mapView release];
	[incident release];
	[location release];
	[locationType release];
	[toolBar release];
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
	CheckBoxTableCell *cell = [TableCellFactory getCheckBoxTableCellWithDelegate:self table:theTableView];
	cell.indexPath = indexPath;
	Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
	if (theLocation != nil) {
		[cell setTitle:theLocation.name];	
		[cell setDescription:[NSString stringWithFormat:@"%@, %@", theLocation.latitude, theLocation.longitude]];
		[cell setChecked:theLocation == self.location];
	}
	else {
		[cell setTitle:nil];
		[cell setDescription:nil];
		[cell setChecked:NO];
	}
	return cell;
}

#pragma mark -
#pragma mark CheckBoxTableCellDelegate

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
	self.location = (Location *)[self filteredRowAtIndexPath:indexPath];
	DLog(@"checkBoxTableCellChanged:%@ index:[%d, %d] checked:%d", location.name, indexPath.section, indexPath.row, checked)
	[self.mapView removeAllPins];
	if (checked) {
		self.incident.location = location.name;
		self.incident.latitude = location.latitude;
		self.incident.longitude = location.longitude;
		NSString *subtitle = [NSString stringWithFormat:@"%@, %@", location.latitude, location.longitude];
		[self.mapView addPinWithTitle:location.name subtitle:subtitle latitude:location.latitude longitude:location.longitude];
	}
	[self.mapView resizeRegionToFitAllPins:YES];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)categories error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if(hasChanges) {
		DLog(@"categories: %d", [categories count]);
		[self.loadingView hide];
		[self replaceRows:categories];
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

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations error:(NSError *)error hasChanges:(BOOL)hasChanges{
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		//[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else if(hasChanges) {
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
#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	DLog(@"");
	self.incident.latitude = [NSString stringWithFormat:@"%f", userLocation.coordinate.latitude];
	self.incident.longitude = [NSString stringWithFormat:@"%f", userLocation.coordinate.longitude];
	[theMapView performSelector:@selector(resizeRegionToFitAllPins) withObject:nil afterDelay:0.8];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.incident.location = [textField.text stringByReplacingCharactersInRange:range withString:string];
	DLog(@"location: %@", self.incident.location);
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	DLog(@"");
	self.incident.location = textField.text;
}

@end