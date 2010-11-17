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
#import "TableCellFactory.h"
#import "MKMapView+Extension.h"

@interface LocationsViewController ()

@property(nonatomic, retain) NSString *location;
@property(nonatomic, retain) NSString *latitude;
@property(nonatomic, retain) NSString *longitude;
@property(nonatomic, retain) NSString *currentLatitude;
@property(nonatomic, retain) NSString *currentLongitude;

@end

@implementation LocationsViewController

@synthesize cancelButton, doneButton, incident, location, latitude, longitude, currentLatitude, currentLongitude;

typedef enum {
	TableSectionNewLocation,
	TableSectionExistingLocations
} TableSection;

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
	[self showSearchBarWithPlaceholder:NSLocalizedString(@"Search locations...", @"Search locations...")];
	[self addHeaders:NSLocalizedString(@"New Location", @"New Location"),
					 NSLocalizedString(@"Existing Locations", @"Existing Locations"), nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[[Locator sharedLocator] detectLocationForDelegate:self];
	self.location = self.incident.location;
	self.latitude = self.incident.latitude;
	self.longitude = self.incident.longitude;
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
	[incident release];
	[location release];
	[currentLatitude release];
	[currentLongitude release];
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
		[cell setTitle:NSLocalizedString(@"Current Location", @"Current Location")];
		if (self.currentLatitude != nil) {
			[cell setDescription:[NSString stringWithFormat:@"%@, %@", self.currentLatitude, self.currentLongitude]];	
		}
		else {
			[cell setDescription:@""];
		}
		[cell setChecked:self.location == nil];
	}
	else {
		Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
		if (theLocation != nil) {
			[cell setTitle:theLocation.name];	
			[cell setDescription:[NSString stringWithFormat:@"%@, %@", theLocation.latitude, theLocation.longitude]];
			if (self.location == nil) {
				[cell setChecked:NO];
			}
			else {
				[cell setChecked:[theLocation equals:self.location
											latitude:self.latitude
										   longitude:self.longitude]];
			}
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
	if (indexPath.section == TableSectionNewLocation) {
		self.location = nil;
		self.latitude = self.currentLatitude;
		self.longitude = self.currentLongitude;
	}
	else {
		Location *theLocation = (Location *)[self filteredRowAtIndexPath:indexPath];
		DLog(@"checkBoxTableCellChanged:%@ index:[%d, %d] checked:%d", theLocation.name, indexPath.section, indexPath.row, checked)
		if (checked) {
			self.location = theLocation.name;
			self.latitude = theLocation.latitude;
			self.longitude = theLocation.longitude;
		}
	}
	[self.tableView reloadData];
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

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)locations error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		//[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
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

- (void) locator:(Locator *)locator latitude:(NSString *)userLatitude longitude:(NSString *)userLongitude {
	DLog(@"locator: %@, %@", userLatitude, userLongitude);
	self.currentLatitude = userLatitude;
	self.currentLongitude = userLongitude;
	[self.tableView reloadData];
}

@end