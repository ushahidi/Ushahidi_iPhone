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

#import "AddIncidentViewController.h"
#import "MapViewController.h"
#import "TableCellFactory.h"
#import "Device.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Category.h"
#import "Location.h"
#import "Incident.h"

#define kCancel @"Cancel"
#define kTakePhoto @"Take Photo"
#define kFromLibrary @"From Library"

typedef enum {
	TableSectionTitle,
	TableSectionDescription,
	TableSectionCategory,
	TableSectionLocation,
	TableSectionDate,
	TableSectionPhotos,
	TableSectionNews
} TableSection;

typedef enum {
	TableSectionDateRowDate,
	TableSectionDateRowTime
} TableSectionDateRow;

@interface AddIncidentViewController ()

@property(nonatomic, retain) NSMutableArray *categories;
@property(nonatomic, retain) NSMutableArray *countries;
@property(nonatomic, retain) NSMutableArray *locations;
@property(nonatomic, retain) DatePicker *datePicker;
@property(nonatomic, retain) Incident *incident;
@end

@implementation AddIncidentViewController

@synthesize mapViewController, cancelButton, doneButton, imagePickerController, datePicker;
@synthesize categories, countries, locations, incident;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"cancel");
	[incident release];
	[self.view endEditing:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"done");
	[self.view endEditing:YES];
	[[Ushahidi sharedUshahidi] addIncident:self.incident];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.incident = [[Incident alloc] initWithDefaultValues];
	
	[self.categories removeAllObjects];
	[self.categories addObjectsFromArray:[[Ushahidi sharedUshahidi] getCategoriesWithDelegate:self]];

	[self.locations removeAllObjects];
	[self.locations addObjectsFromArray:[[Ushahidi sharedUshahidi] getLocationsWithDelegate:self]];
	
//	[self.countries removeAllObjects];
//	[self.countries addObjectsFromArray:[[Ushahidi sharedUshahidi] getCountriesWithDelegate:self]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.imagePickerController = [[ImagePickerController alloc] initWithController:self];
	self.datePicker = [[DatePicker alloc] initWithDelegate:self forController:self];
	self.categories = [[NSMutableArray alloc] initWithCapacity:0];
	self.countries = [[NSMutableArray alloc] initWithCapacity:0];
	self.locations = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)dealloc {
	[mapViewController release];
	[cancelButton release];
	[doneButton release];
	[imagePickerController release];
	[categories release];
	[countries release];
	[locations release];
	[incident release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 6;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionCategory) {
		return [self.categories count];
	}
	if (section == TableSectionLocation) {
		return 2;
	}
	if (section == TableSectionDate) {
		return 2;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionCategory) {
		CheckBoxTableCell *cell = [TableCellFactory getCheckBoxTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		Category *category = [self.categories objectAtIndex:indexPath.row];
		if (category != nil) {
			[cell setTitle:category.title];	
			[cell setDescription:category.description];
			[cell setTextColor:category.color];
			[cell setChecked:[self.incident hasCategory:category]];
		}
		else {
			[cell setTitle:nil];
			[cell setDescription:nil];
			[cell setChecked:NO];
		}
		return cell;
	}
	else if (indexPath.section == TableSectionDescription) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setPlaceholder:@"Enter description"];
		[cell setText:self.incident.description];
		return cell;
	}
	else if (indexPath.section == TableSectionPhotos) {
		UITableViewCell *cell = [TableCellFactory getDefaultTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.text = @"Add New Incident Photo";
		return cell;
	}
	else if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		MapTableCell *cell = [TableCellFactory getMapTableCellWithDelegate:self table:theTableView];
		[cell setScrollable:YES];
		[cell setZoomable:YES];
		[cell setAnimatesDrop:YES];
		[cell setShowRightCallout:YES];
		if ([cell numberOfPins] == 0) {
			[cell removeAllPins];
			for (Location *location in self.locations) {
				NSString *subtitle = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude];
				[cell addPinWithTitle:location.name subtitle:subtitle latitude:location.latitude longitude:location.longitude];
			}
			[cell resizeRegionToFitAllPins:YES];	
		}
		return cell;
	}
	else if (indexPath.section == TableSectionDate) {
		DateTableCell *cell = [TableCellFactory getDateTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		if (indexPath.row == TableSectionDateRowDate) {
			[cell setPlaceholder:@"Enter date"];
			[cell setDate:self.incident.date timeFormat:NO];	
		}
		else if (indexPath.row == TableSectionDateRowTime){
			[cell setPlaceholder:@"Enter time"];
			[cell setDate:self.incident.date timeFormat:YES];
		}
		return cell;
	}
	else {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		if (indexPath.section == TableSectionTitle) {
			[cell setPlaceholder:@"Enter title"];
			[cell setText:self.incident.title];
		}
		else if (indexPath.section == TableSectionLocation) {
			[cell setPlaceholder:@"Select location"];
			if (self.incident.location != nil) {
				[cell setText:self.incident.location.name];
			}
			else {
				[cell setText:@""];
			}
		}
		else if (indexPath.section == TableSectionNews) {
			[cell setPlaceholder:@"Add news"];
		}
		return cell;	
	}
}

- (NSString *)tableView:(UITableView *)theTableView titleForHeaderInSection:(NSInteger)section {
	if (section == TableSectionTitle) {
		return @"Title";
	}
	if (section == TableSectionCategory) {
		return @"Category";
	}
	if (section == TableSectionLocation) {
		return @"Location";
	}
	if (section == TableSectionDate) {
		return @"Date";
	}
	if (section == TableSectionDescription) {
		return @"Description";
	}
	if (section == TableSectionPhotos) {
		return @"Photos";
	}
	if (section == TableSectionNews) {
		return @"News";
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		return 120;
	}
	if (indexPath.section == TableSectionLocation && indexPath.row == 1) {
		return 260;
	}
	return 45;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == TableSectionPhotos) {
		[self.imagePickerController showImagePicker];
	}
}

#pragma mark -
#pragma mark CheckBoxTableCellDelegate

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked {
	Category *category = [self.categories objectAtIndex:indexPath.row];
	DLog(@"checkBoxTableCellChanged:%@ index:[%d, %d] checked:%d", category.title, indexPath.section, indexPath.row, checked)
	if (checked) {
		[self.incident addCategory:category];
	}
	else {
		[self.incident removeCategory:category];
	}
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"indexPath:[%d, %d] text: %@", indexPath.section, indexPath.row, text);
	if (indexPath.section == TableSectionTitle) {
		self.incident.title = text;
	}
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"indexPath:[%d, %d] text: %@", indexPath.section, indexPath.row, text);
	if (indexPath.section == TableSectionTitle) {
		self.incident.title = text;
	}
}

#pragma mark -
#pragma mark TextViewTableCellDelegate

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"indexPath:[%d, %d] text: %@", indexPath.section, indexPath.row, text);
	self.incident.description = text;
}

- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"indexPath:[%d, %d] text: %@", indexPath.section, indexPath.row, text);
	self.incident.description = text;
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi countries:(NSArray *)theCountries error:(NSError *)error hasChanges:(BOOL)hasChanges{
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else if(hasChanges) {
		DLog(@"countries: %@", theCountries);
		[self.countries removeAllObjects];
		[self.countries addObjectsFromArray:theCountries];
	}
	else {
		DLog(@"No Changes");
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi locations:(NSArray *)theLocations error:(NSError *)error hasChanges:(BOOL)hasChanges{
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		//[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else if(hasChanges) {
		DLog(@"locations: %@", theLocations);
		[self.locations removeAllObjects];
		[self.locations addObjectsFromArray:theLocations];
		MapTableCell *cell = (MapTableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:TableSectionLocation]];
		if (cell != nil) {
			[cell removeAllPins];
			for (Location *location in theLocations) {
				NSString *subtitle = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude];
				[cell addPinWithTitle:location.name subtitle:subtitle latitude:location.latitude longitude:location.longitude];
			}
			[cell resizeRegionToFitAllPins:YES];
		}
	}
	else {
		DLog(@"No Changes");
	}
}

- (void) downloadedFromUshahidi:(Ushahidi *)ushahidi categories:(NSArray *)theCategories error:(NSError *)error hasChanges:(BOOL)hasChanges {
	if (error != nil) {
		DLog(@"error: %@", [error localizedDescription]);
		//[self.alertView showWithTitle:@"Error" andMessage:[error localizedDescription]];
	}
	else if (hasChanges){
		DLog(@"categories: %@", categories);
		[self.categories removeAllObjects];
		[self.categories addObjectsFromArray:theCategories];
		[self.tableView reloadData];
	}
	else {
		DLog(@"No Changes");
	}
}

#pragma mark -
#pragma mark MapTableCellDelegate

- (void) mapTableCell:(MapTableCell *)mapTableCell pinSelectedAtIndex:(NSInteger)index {
	DLog(@"index:%d", index);
	Location *location = [self.locations objectAtIndex:index];
	if (location != nil) {
		self.incident.location = location;
		DLog(@"location:%@ latitude:%@ longitude:%@", location.name, location.latitude, location.longitude);
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:TableSectionLocation];
		TextFieldTableCell *cell = (TextFieldTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
		if (cell != nil) {
			[cell setText:location.name];	
		}
	}
}

#pragma mark -
#pragma mark DateTableCellDelegate

- (void) dateTableCellClicked:(DateTableCell *)cell date:(NSDate *)date indexPath:(NSIndexPath *)indexPath {
	DLog(@"%@", date);
	if (indexPath.row == TableSectionDateRowDate) {
		[self.datePicker showWithDate:date mode:UIDatePickerModeDate indexPath:indexPath];
	}
	else if (indexPath.row == TableSectionDateRowTime) {
		[self.datePicker showWithDate:date mode:UIDatePickerModeTime indexPath:indexPath];
	}
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark DatePickerDelegate

- (void) datePickerReturned:(DatePicker *)theDatePicker date:(NSDate *)date indexPath:(NSIndexPath *)indexPath {
	self.incident.date = date;
	[self.tableView reloadData];
}

@end
