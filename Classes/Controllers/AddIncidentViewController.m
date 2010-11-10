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
#import "Messages.h"
#import "UIColor+Extension.h"
#import "Photo.h"
#import "ImageTableCell.h"
#import "Settings.h"

#define kCancel @"Cancel"
#define kTakePhoto @"Take Photo"
#define kFromLibrary @"From Library"

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
	[self addHeaders:[Messages title], [Messages description], [Messages category], [Messages date], [Messages location], [Messages photos], [Messages news], nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.modalViewController == nil) {
		DLog(@"XXXXXXXXXXXXXX initWithDefaultValues XXXXXXXXXXXXXX");
		self.incident = [[Incident alloc] initWithDefaultValues];
		self.willBePushed = NO;
	}
	self.doneButton.enabled = [self.incident hasRequiredValues];
	[self.tableView reloadData];
	
	DLog(@"self.incident.categories: %@", [self.incident categoryNames]);
	DLog(@"self.incident.location: %@", self.incident.location);
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
		return 1;
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
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setPlaceholder:@"Enter description"];
		[cell setText:self.incident.description];
		return cell;
	}
	else if (indexPath.section == TableSectionPhotos) {
		if (indexPath.row > 0) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView];
			cell.indexPath = indexPath;
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
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			[cell setText:[Messages addPhoto]];
			[cell setTextColor:[UIColor lightGrayColor]];
			return cell;
		}
	}
	else if (indexPath.section == TableSectionLocation) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if (self.incident.location != nil) {
			[cell setText:self.incident.location];
			[cell setTextColor:[UIColor blackColor]];
		}
		else {
			[cell setText:@"Select location"];
			[cell setTextColor:[UIColor lightGrayColor]];
		}
		return cell;
	}
	else if (indexPath.section == TableSectionDate) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if (indexPath.row == TableSectionDateRowDate) {
			if (self.incident.date != nil) {
				[cell setText:[self.incident dateString]];
				[cell setTextColor:[UIColor blackColor]];
			}
			else {
				[cell setText:@"Enter date"];
				[cell setTextColor:[UIColor lightGrayColor]];
			}
		}
		else if (indexPath.row == TableSectionDateRowTime){
			if (self.incident.date != nil) {
				[cell setText:[self.incident timeString]];
				[cell setTextColor:[UIColor blackColor]];
			}
			else {
				[cell setText:@"Enter time"];
				[cell setTextColor:[UIColor lightGrayColor]];
			}
		}
		return cell;
	}
	else if (indexPath.section == TableSectionCategory) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		if ([self.incident.categories count] > 0) {
			[cell setText:[self.incident categoryNames]];
			[cell setTextColor:[UIColor blackColor]];
		}
		else {
			[cell setText:@"Select category"];
			[cell setTextColor:[UIColor lightGrayColor]];
		}
		return cell;
	}
	else {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		if (indexPath.section == TableSectionTitle) {
			[cell setPlaceholder:@"Enter title"];
			[cell setText:self.incident.title];
		}
		else if (indexPath.section == TableSectionLocation) {
			[cell setPlaceholder:@"Select location"];
			if (self.incident.location != nil) {
				[cell setText:self.incident.location];
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
		return [Messages title];
	}
	if (section == TableSectionCategory) {
		return [Messages category];
	}
	if (section == TableSectionLocation) {
		return [Messages location];
	}
	if (section == TableSectionDate) {
		return [Messages date];
	}
	if (section == TableSectionDescription) {
		return [Messages description];
	}
	if (section == TableSectionPhotos) {
		return [Messages photos];
	}
	if (section == TableSectionNews) {
		return [Messages news];
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionPhotos) {
		if (indexPath.row > 0) {
			return 200;
		}
		return [TextTableCell getCellSizeForText:[Messages addPhoto] forWidth:theTableView.contentSize.width].height;
	}
	if (indexPath.section == TableSectionDescription) {
		return 120;
	}
	if (indexPath.section == TableSectionLocation) {
		CGSize size = [TextTableCell getCellSizeForText:self.incident.location forWidth:theTableView.contentSize.width];
		if (size.height > 45) {
			return size.height;
		}
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
														cancelButtonTitle:@"Cancel" 
												   destructiveButtonTitle:@"Remove Photo"
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
	[self.loadingView showWithMessage:[Messages resizing]];
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

@end
