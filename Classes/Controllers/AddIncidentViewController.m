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
#import "CategoriesViewController.h"
#import "LocationsViewController.h"
#import "IncidentsViewController.h"
#import "IncidentsViewController.h"
#import "TextTableCell.h"
#import "AlertView.h"
#import "InputView.h"
#import "Category.h"
#import "Location.h"
#import "Incident.h"
#import "UIColor+Extension.h"
#import "Photo.h"
#import "ImageTableCell.h"
#import "Settings.h"

typedef enum {
	TableSectionTitle,
	TableSectionDescription,
	TableSectionCategory,
	TableSectionDate,
	TableSectionLocation,
	TableSectionPhotos,
	TableSectionNews
} TableSection;

typedef enum {
	TableSectionDateRowDate,
	TableSectionDateRowTime
} TableSectionDateRow;

typedef enum {
	TableSectionLocationName,
	TableSectionLocationCoordinates
} TableSectionLocationRow;

@interface AddIncidentViewController ()

@property(nonatomic, retain) DatePicker *datePicker;
@property(nonatomic, retain) Incident *incident;

@end

@implementation AddIncidentViewController

@synthesize cancelButton, doneButton, datePicker;
@synthesize categoriesViewController, locationsViewController, imagePickerController, incidentsViewController;
@synthesize incident;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"cancel");
	[self.incident release];
	[self.view endEditing:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"done");
	[self.view endEditing:YES];
	if ([[Ushahidi sharedUshahidi] addIncident:self.incident forDelegate:self.incidentsViewController]) {
		[self dismissModalViewControllerAnimated:YES];
	}
	else {
		DLog(@"Unable to add incident");
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.imagePickerController = [[ImagePickerController alloc] initWithController:self];
	self.datePicker = [[DatePicker alloc] initForDelegate:self forController:self];
	[self addHeaders:NSLocalizedString(@"Title", @"Title"),
					 NSLocalizedString(@"Description", @"Description"),
					 NSLocalizedString(@"Category", @"Category"),
					 NSLocalizedString(@"Date", @"Date"),
					 NSLocalizedString(@"Location", @"Location"),
					 NSLocalizedString(@"Photos", @"Photos"),
					 NSLocalizedString(@"News", @"News"), nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[Locator sharedLocator] detectLocationForDelegate:self];
	if (self.modalViewController == nil) {
		self.incident = [[Incident alloc] initWithDefaultValues];
		self.willBePushed = NO;
	}
	self.doneButton.enabled = [self.incident hasRequiredValues];
	[self.tableView reloadData];
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[imagePickerController release];
	[categoriesViewController release];
	[locationsViewController release];
	[incidentsViewController release];
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
		return 1;
	}
	if (section == TableSectionLocation) {
		return 2;
	}
	if (section == TableSectionDate) {
		return 2;
	}
	if (section == TableSectionPhotos) {
		return [self.incident.photos count] + 1;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setPlaceholder:@"Enter description"];
		[cell setText:self.incident.description];
		[cell setKeyboardType:UIKeyboardTypeDefault];
		[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		return cell;
	}
	else if (indexPath.section == TableSectionPhotos) {
		if (indexPath.row > 0) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
			Photo *photo = [self.incident.photos objectAtIndex:indexPath.row - 1];
			if (photo != nil) {
				[cell setImage:photo.image];
			}
			else {
				[cell setImage:nil];
			}
			return cell;	
		}
		else {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			[cell setText:NSLocalizedString(@"Add Photo", @"Add Photo")];
			[cell setTextColor:[UIColor lightGrayColor]];
			return cell;
		}
	}
	else if (indexPath.section == TableSectionLocation) {
		if (indexPath.row == TableSectionLocationName) {
			TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
			[cell setText:self.incident.location];
			[cell setPlaceholder:NSLocalizedString(@"Enter location name", @"Enter location name")];
			return cell;
		}
		else {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			if (self.incident.coordinates != nil) {
				[cell setText:self.incident.coordinates];
				[cell setTextColor:[UIColor blackColor]];
			}
			else {
				[cell setText:NSLocalizedString(@"Select location", @"Select location")];
				[cell setTextColor:[UIColor lightGrayColor]];
			}
			return cell;	
		}
	}
	else if (indexPath.section == TableSectionDate) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if (indexPath.row == TableSectionDateRowDate) {
			if (self.incident.date != nil) {
				[cell setText:[self.incident dateString]];
				[cell setTextColor:[UIColor blackColor]];
			}
			else {
				[cell setText:NSLocalizedString(@"Enter date", @"Enter date")];
				[cell setTextColor:[UIColor lightGrayColor]];
			}
		}
		else if (indexPath.row == TableSectionDateRowTime){
			if (self.incident.date != nil) {
				[cell setText:[self.incident timeString]];
				[cell setTextColor:[UIColor blackColor]];
			}
			else {
				[cell setText:NSLocalizedString(@"Enter time", @"Enter time")];
				[cell setTextColor:[UIColor lightGrayColor]];
			}
		}
		return cell;
	}
	else if (indexPath.section == TableSectionCategory) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if ([self.incident.categories count] > 0) {
			[cell setText:[self.incident categoryNames]];
			[cell setTextColor:[UIColor blackColor]];
		}
		else {
			[cell setText:NSLocalizedString(@"Select category", @"Select category")];
			[cell setTextColor:[UIColor lightGrayColor]];
		}
		return cell;
	}
	else {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		if (indexPath.section == TableSectionTitle) {
			[cell setPlaceholder:NSLocalizedString(@"Enter title", @"Enter title")];
			[cell setText:self.incident.title];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		}
		else if (indexPath.section == TableSectionNews) {
			[cell setPlaceholder:NSLocalizedString(@"Add news", @"Add news")];
		}
		return cell;	
	}
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionPhotos) {
		if (indexPath.row > 0) {
			return 200;
		}
		return [TextTableCell getCellSizeForText:NSLocalizedString(@"Add Photo", @"Add Photo") forWidth:theTableView.contentSize.width].height;
	}
	if (indexPath.section == TableSectionDescription) {
		return 120;
	}
	if (indexPath.section == TableSectionLocation) {
		return 45;
	}
	if (indexPath.section == TableSectionCategory) {
		CGSize size = [TextTableCell getCellSizeForText:[self.incident categoryNames] forWidth:theTableView.contentSize.width];
		if (size.height > 45) {
			return size.height;
		}
	}
	return 45;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == TableSectionPhotos && indexPath.row == 0) {
		[self.imagePickerController showImagePickerForDelegate:self width:[[Settings sharedSettings] imageWidth]];
	}
	else if (indexPath.section == TableSectionPhotos && indexPath.row > 0) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") 
												   destructiveButtonTitle:NSLocalizedString(@"Remove Photo", @"Remove Photo")
														otherButtonTitles:nil];
		[actionSheet setTag:indexPath.row - 1];
		[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
		[actionSheet showInView:[self view]];
		[actionSheet release];
	}
	else if (indexPath.section == TableSectionCategory) {
		self.categoriesViewController.incident = self.incident;
		[self presentModalViewController:self.categoriesViewController animated:YES];
	}
	else if (indexPath.section == TableSectionLocation) {
		self.locationsViewController.incident = self.incident;
		[self presentModalViewController:self.locationsViewController animated:YES];
	}
	else if (indexPath.section == TableSectionDate){
		UIDatePickerMode datePickerMode = indexPath.row == TableSectionDateRowDate
			? UIDatePickerModeDate : UIDatePickerModeTime;
		[self.datePicker showWithDate:self.incident.date mode:datePickerMode indexPath:indexPath];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionTitle) {
		self.incident.title = text;
	}
	self.doneButton.enabled = [self.incident hasRequiredValues];
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionTitle) {
		self.incident.title = text;
	}
	self.doneButton.enabled = [self.incident hasRequiredValues];
}

#pragma mark -
#pragma mark TextViewTableCellDelegate

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	self.incident.description = text;
}

- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	self.incident.description = text;
}

#pragma mark -
#pragma mark DatePickerDelegate

- (void) datePickerReturned:(DatePicker *)theDatePicker date:(NSDate *)date indexPath:(NSIndexPath *)indexPath {
	self.incident.date = date;
	[self.tableView reloadData];
	self.doneButton.enabled = [self.incident hasRequiredValues];
}

#pragma mark -
#pragma mark ImagePickerDelegate

- (void) imagePickerDidCancel:(ImagePickerController *)imagePicker {
	[self.loadingView hide];
}

- (void) imagePickerDidSelect:(ImagePickerController *)imagePicker {
	[self.loadingView showWithMessage:NSLocalizedString(@"Resizing...", @"Resizing...")];
}

- (void) imagePickerDidFinish:(ImagePickerController *)imagePicker image:(UIImage *)image {
	[self.loadingView hideAfterDelay:0.5];
	[self.incident addPhoto:[Photo photoWithImage:image]];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.cancelButtonIndex != buttonIndex) {
		[self.incident removePhotoAtIndex:actionSheet.tag];
		[self.tableView reloadData];	
	}
}

#pragma mark -
#pragma mark LocatorDelegate

- (void) locator:(Locator *)locator latitude:(NSString *)latitude longitude:(NSString *)longitude {
	DLog(@"locator: %@, %@", latitude, longitude);
	if (self.incident.latitude == nil || self.incident.longitude == nil) {
		self.incident.latitude = latitude;
		self.incident.longitude = longitude;
		[self.tableView reloadData];
	}
}

@end
