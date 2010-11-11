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

@property(nonatomic, retain) NSString *location;
@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;

@end

@implementation LocationsViewController

@synthesize mapView, cancelButton, doneButton, incident, location, latitude, longitude, locationType, toolBar, textField;

typedef enum {
	LocationTypeTable,
	LocationTypeMap
} LocationType;

#pragma mark -
#pragma mark Handlers

- (IBAction) locate:(id)sender {
	DLog(@"");
	[self.mapView removeAllPins];
	[self.mapView resizeRegionToFitAllPins];
	self.location = nil;
	self.latitude = nil;
	self.longitude = nil;
	self.textField.text = nil;
	self.mapView.showsUserLocation = YES;
	self.tableView.hidden = YES;
	self.mapView.hidden = NO;
	self.toolBar.hidden = NO;
	self.locationType.selectedSegmentIndex = LocationTypeMap;
	[self.tableView reloadData];
}

- (IBAction) locationTypeChanged:(id)sender {
	if (self.locationType.selectedSegmentIndex == LocationTypeTable) {
		self.tableView.hidden = NO;
		self.mapView.hidden = YES;
		self.toolBar.hidden = YES;
	} 
	else if (self.locationType.selectedSegmentIndex == LocationTypeMap) {
		self.tableView.hidden = YES;
		self.mapView.hidden = NO;
		self.toolBar.hidden = NO;
		[self.mapView removeAllPins];
		if (self.location != nil && self.latitude != nil && self.longitude != nil) {
			[self.mapView addPinWithTitle:self.location 
								 subtitle:[NSString stringWithFormat:@"%@, %@", self.latitude, self.longitude] 
								 latitude:self.latitude 
								longitude:self.longitude];	
			[self.mapView performSelector:@selector(resizeRegionToFitAllPins) withObject:nil afterDelay:0.8];
		}
		self.textField.text = self.location;
	}
}

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

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self showSearchBarWithPlaceholder:[Messages searchLocations]];
}

- (void)viewWillAppear:(BOOL)animated {
	self.location = self.incident.location;
	self.latitude = self.incident.latitude;
	self.longitude = self.incident.longitude;
	self.mapView.showsUserLocation = NO;
	[self.mapView removeAllPins];
	self.locationType.selectedSegmentIndex = LocationTypeTable;
	[self.allRows removeAllObjects];
	[self.filteredRows removeAllObjects];
	[self.allRows addObjectsFromArray:[[Ushahidi sharedUshahidi] getLocationsForDelegate:self]];
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
	[textField release];
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
	CheckBoxTableCell *cell = [TableCellFactory getCheckBoxTableCellForDelegate:self table:theTableView indexPath:indexPath];
	Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
	if (theLocation != nil) {
		[cell setTitle:theLocation.name];	
		[cell setDescription:[NSString stringWithFormat:@"%@, %@", theLocation.latitude, theLocation.longitude]];
		[cell setChecked:[theLocation equals:self.location
									latitude:self.latitude
								   longitude:self.longitude]];
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
	if (cell.checked) {
		[cell setChecked:NO];
		self.location = nil;
		self.latitude = nil;
		self.longitude = nil;
	}
	else {
		[cell setChecked:YES];
		Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
		self.location = theLocation.name;
		self.latitude = theLocation.latitude;
		self.longitude = theLocation.longitude;
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark CheckBoxTableCellDelegate

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
	Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
	DLog(@"checkBoxTableCellChanged:%@ index:[%d, %d] checked:%d", theLocation.name, indexPath.section, indexPath.row, checked)
	self.mapView.showsUserLocation = NO;
	[self.mapView removeAllPins];
	if (checked) {
		self.location = theLocation.name;
		self.latitude = theLocation.latitude;
		self.longitude = theLocation.longitude;
	}
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
	for (Location *loc in self.allRows) {
		if ([loc matchesString:searchText]) {
			[self.filteredRows addObject:loc];
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
	self.textField.text = [NSString stringWithFormat:@"%f, %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude];
	self.location = [NSString stringWithFormat:@"%f, %f", userLocation.coordinate.latitude, userLocation.coordinate.longitude];
	self.latitude = [NSString stringWithFormat:@"%f", userLocation.coordinate.latitude];
	self.longitude = [NSString stringWithFormat:@"%f", userLocation.coordinate.longitude];
	[theMapView performSelector:@selector(resizeRegionToFitAllPins) withObject:nil afterDelay:1.0];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	self.location = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	self.location = theTextField.text;
}

@end