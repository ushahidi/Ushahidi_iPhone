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

#import "IncidentAddViewController.h"
#import "MapViewController.h"
#import "TableCellFactory.h"
#import "Device.h"
#import "LoadingViewController.h"
#import "CategoryTableViewController.h"
#import "LocationTableViewController.h"
#import "TextTableCell.h"
#import "AlertView.h"
#import "InputView.h"
#import "Category.h"
#import "Location.h"
#import "Incident.h"
#import "UIColor+Extension.h"
#import "Photo.h"
#import "News.h"
#import "ImageTableCell.h"
#import "ButtonTableCell.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "NSString+Extension.h"

@interface IncidentAddViewController ()

@property(nonatomic, retain) DatePicker *datePicker;
@property(nonatomic, retain) NSString *news;

- (void) dismissModalView;

@end

@implementation IncidentAddViewController

@synthesize cancelButton, doneButton, datePicker;
@synthesize categoryTableViewController, locationTableViewController, imagePickerController, news;
@synthesize incident;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionTitle,
	TableSectionDescription,
	TableSectionCategory,
	TableSectionDate,
	TableSectionLocation,
	TableSectionPhotos,
	TableSectionNews,
	TableSectionDelete
} TableSection;

typedef enum {
	TableSectionDateRowDate,
	TableSectionDateRowTime
} TableSectionDateRow;

typedef enum {
	TableSectionLocationName,
	TableSectionLocationCoordinates
} TableSectionLocationRow;

typedef enum {
	AlertViewUnsaved,
	AlertViewDelete
} AlertViewType;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"cancel");
	[self.alertView showYesNoWithTitle:NSLocalizedString(@"Unsaved Changes", nil) 
							andMessage:NSLocalizedString(@"Are you sure you want to cancel?", nil) 
								forTag:AlertViewUnsaved];
}

- (IBAction) done:(id)sender {
	DLog(@"done");
	NSMutableArray *missingFields = [NSMutableArray array];
	if (self.incident.hasTitle == NO) {
		[missingFields addObject:NSLocalizedString(@"Title", nil)]; 
	}
	if (self.incident.hasDescription == NO) {
		[missingFields addObject:NSLocalizedString(@"Description", nil)]; 
	}
	if (self.incident.hasCategory == NO) {
		[missingFields addObject:NSLocalizedString(@"Category", nil)]; 
	}
	if (self.incident.hasDate == NO) {
		[missingFields addObject:NSLocalizedString(@"Date", nil)]; 
	}
	if (self.incident.hasLocation == NO) {
		[missingFields addObject:NSLocalizedString(@"Location", nil)]; 
	}
	if (missingFields.count > 0) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Required Fields", nil) 
							 andMessage:[missingFields componentsJoinedByString:@", "]];
	}
	else {
		BOOL adding = [NSString isNilOrEmpty:self.incident.identifier];
		if (adding) {
			[self.loadingView showWithMessage:NSLocalizedString(@"Adding...", nil)];
		}
		else {
			[self.loadingView showWithMessage:NSLocalizedString(@"Saving...", nil)];
		}
		if (self.news != nil && [self.news isValidURL]) {
			[self.incident addNews:[News newsWithUrl:self.news]];
		}
		[self.view endEditing:YES];
		if ([[Ushahidi sharedUshahidi] addIncident:self.incident forDelegate:self]) {
			if (adding) {
				[self.loadingView showWithMessage:NSLocalizedString(@"Added", nil)];
			}
			else {
				[self.loadingView showWithMessage:NSLocalizedString(@"Saved", nil)];
			}
			[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.0];
		}
		else {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Error", nil) 
								 andMessage:NSLocalizedString(@"Unable to add incident", nil)];
		}
	}
}

- (void) dismissModalView {
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationBar.topItem.title = NSLocalizedString(@"Add Report", nil);
	self.imagePickerController = [[ImagePickerController alloc] initWithController:self];
	self.datePicker = [[DatePicker alloc] initForDelegate:self forController:self];
	[self setHeader:NSLocalizedString(@"Title", nil) atSection:TableSectionTitle];
	[self setHeader:NSLocalizedString(@"Description", nil) atSection:TableSectionDescription];
	[self setHeader:NSLocalizedString(@"Category", nil) atSection:TableSectionCategory];
	[self setHeader:NSLocalizedString(@"Date", nil) atSection:TableSectionDate];
	[self setHeader:NSLocalizedString(@"Location", nil) atSection:TableSectionLocation];
	[self setHeader:NSLocalizedString(@"Photos", nil) atSection:TableSectionPhotos];
	[self setHeader:NSLocalizedString(@"News", nil) atSection:TableSectionNews];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.imagePickerController = nil;
	self.datePicker = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.modalViewController == nil) {
		if (self.incident == nil) {
			self.cancelButton.enabled = YES;
			self.incident = [[Incident alloc] initWithDefaultValues];
			self.news = nil;
			self.willBePushed = NO;
			if ([[Locator sharedLocator] hasLocation] &&
				[[Locator sharedLocator] hasAddress]) {
				self.incident.latitude = [Locator sharedLocator].latitude;
				self.incident.longitude = [Locator sharedLocator].longitude;
				self.incident.location = [Locator sharedLocator].address;
				[self setFooter:[Locator sharedLocator].address 
					  atSection:TableSectionLocation];
			}
			else if ([[Locator sharedLocator] hasLocation]) {
				self.incident.latitude = [Locator sharedLocator].latitude;
				self.incident.longitude = [Locator sharedLocator].longitude;
				[self setFooter:[NSString stringWithFormat:@"%@, %@", self.incident.latitude, self.incident.longitude] 
					  atSection:TableSectionLocation];
			}
			else {
				[self setFooter:NSLocalizedString(@"Locating...", nil) 
					  atSection:TableSectionLocation];
			}
			[[Locator sharedLocator] detectLocationForDelegate:self];
		}
		else {
			self.cancelButton.enabled = NO;
		}
		[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	}
	[self.tableView reloadData];
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[imagePickerController release];
	[categoryTableViewController release];
	[locationTableViewController release];
	[incident release];
	[news release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 8;
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
	if (section == TableSectionDelete) {
		return self.incident.pending ? 1 : 0;
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDescription) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setPlaceholder:NSLocalizedString(@"Enter description", nil)];
		[cell setText:self.incident.description];
		[cell setReturnKeyType:UIReturnKeyDefault];
		[cell setKeyboardType:UIKeyboardTypeDefault];
		[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		return cell;
	}
	else if (indexPath.section == TableSectionPhotos) {
		if (indexPath.row > 0) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
			Photo *photo = [self.incident.photos objectAtIndex:indexPath.row - 1];
			if (photo != nil && photo.image != nil) {
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
			[cell setText:NSLocalizedString(@"Add Photo", nil)];
			[cell setTextColor:[UIColor lightGrayColor]];
			return cell;
		}
	}
	else if (indexPath.section == TableSectionNews) {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setText:self.news];
		[cell setPlaceholder:NSLocalizedString(@"Enter news URL", nil)];
		[cell setKeyboardType:UIKeyboardTypeURL];
		[cell setReturnKeyType:UIReturnKeyDefault];
		[cell setAutocorrectionType:UITextAutocorrectionTypeNo];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		return cell;
	}
	else if (indexPath.section == TableSectionLocation) {
		if (indexPath.row == TableSectionLocationName) {
			TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
			[cell setText:self.incident.location];
			[cell setPlaceholder:NSLocalizedString(@"Enter location name", nil)];
			[cell setReturnKeyType:UIReturnKeyDefault];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
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
				[cell setText:NSLocalizedString(@"Select location", nil)];
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
				[cell setText:NSLocalizedString(@"Enter date", nil)];
				[cell setTextColor:[UIColor lightGrayColor]];
			}
		}
		else if (indexPath.row == TableSectionDateRowTime){
			if (self.incident.date != nil) {
				[cell setText:[self.incident timeString]];
				[cell setTextColor:[UIColor blackColor]];
			}
			else {
				[cell setText:NSLocalizedString(@"Enter time", nil)];
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
			[cell setText:NSLocalizedString(@"Select category", nil)];
			[cell setTextColor:[UIColor lightGrayColor]];
		}
		return cell;
	}
	else if (indexPath.section == TableSectionDelete) {
		ButtonTableCell *cell = [TableCellFactory getButtonTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setText:NSLocalizedString(@"Delete Report", nil)];
		return cell;
	}
	else {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		if (indexPath.section == TableSectionTitle) {
			[cell setText:self.incident.title];
			[cell setPlaceholder:NSLocalizedString(@"Enter title", nil)];
			[cell setReturnKeyType:UIReturnKeyDefault];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		}
		return cell;	
	}
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionPhotos) {
		if (indexPath.row > 0) {
			return 200;
		}
		return [TextTableCell getCellSizeForText:NSLocalizedString(@"Add Photo", nil) forWidth:theTableView.contentSize.width].height;
	}
	if (indexPath.section == TableSectionDescription) {
		return [Device isIPad] ? 250 : 120;
	}
	if (indexPath.section == TableSectionLocation) {
		return 44;
	}
	if (indexPath.section == TableSectionCategory) {
		CGSize size = [TextTableCell getCellSizeForText:[self.incident categoryNames] forWidth:theTableView.contentSize.width];
		if (size.height > 44) {
			return size.height;
		}
	}
	return 44;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.section == TableSectionPhotos && indexPath.row == 0) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self.imagePickerController showImagePickerForDelegate:self width:[[Settings sharedSettings] imageWidth] forRect:cell.frame];
	}
	else if (indexPath.section == TableSectionPhotos && indexPath.row > 0) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
												   destructiveButtonTitle:NSLocalizedString(@"Remove Photo", nil)
														otherButtonTitles:nil];
		[actionSheet setTag:indexPath.row - 1];
		[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
		[actionSheet showInView:[self view]];
		[actionSheet release];
	}
	else if (indexPath.section == TableSectionCategory) {
		self.categoryTableViewController.incident = self.incident;
		[self presentModalViewController:self.categoryTableViewController animated:YES];
	}
	else if (indexPath.section == TableSectionLocation) {
		self.locationTableViewController.incident = self.incident;
		[self presentModalViewController:self.locationTableViewController animated:YES];
	}
	else if (indexPath.section == TableSectionDate){
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		CGRect rect = cell.frame;
		rect.origin.y += [TableHeaderView getViewHeight];
		rect.origin.y += 45 / 2;
		UIDatePickerMode datePickerMode = indexPath.row == TableSectionDateRowDate
			? UIDatePickerModeDate : UIDatePickerModeTime;
		[self.datePicker showWithDate:self.incident.date mode:datePickerMode indexPath:indexPath forRect:rect];
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
	else if (indexPath.section == TableSectionLocation) {
		self.incident.location = text;
	}
	else if (indexPath.section == TableSectionNews) {
		self.news = text;
	}
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionTitle) {
		self.incident.title = text;
	}
	else if (indexPath.section == TableSectionLocation) {
		self.incident.location = text;
	}
	else if (indexPath.section == TableSectionNews) {
		self.news = text;
		if ([NSString isNilOrEmpty:text] || [text isValidURL]) {
			[self setFooter:nil atSection:TableSectionNews];
		}
		else {
			[self setFooter:NSLocalizedString(@"Invalid News URL", nil) atSection:TableSectionNews];
		}
		[self.tableView reloadData];
	}
	[cell hideKeyboard];
}

#pragma mark -
#pragma mark TextViewTableCellDelegate

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionDescription) {
		self.incident.description = text;
	}
}

- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionDescription) {
		self.incident.description = text;
		[cell hideKeyboard];
	}
}

#pragma mark -
#pragma mark DatePickerDelegate

- (void) datePickerReturned:(DatePicker *)theDatePicker date:(NSDate *)date indexPath:(NSIndexPath *)indexPath {
	self.incident.date = date;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ImagePickerDelegate

- (void) imagePickerDidSelect:(ImagePickerController *)imagePicker {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Resizing Photo...", nil)];
}

- (void) imagePickerDidFinish:(ImagePickerController *)imagePicker image:(UIImage *)image {
	DLog(@"");
	if (image != nil && image.size.width > 0 && image.size.height > 0) {
		[self.loadingView showWithMessage:NSLocalizedString(@"Photo Added", nil)];
		[self.loadingView hideAfterDelay:1.0];
		[self.incident addPhoto:[Photo photoWithImage:image]];
		[self.tableView reloadData];	
	}
	else {
		[self.loadingView hide];
		[self.tableView reloadData];
		[self.alertView showOkWithTitle:NSLocalizedString(@"Photo Error", nil) 
							 andMessage:NSLocalizedString(@"There was a problem adding the photo.", nil)];
	}
}

- (void) imagePickerDidCancel:(ImagePickerController *)imagePicker {
	DLog(@"");
	[self.loadingView hide];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.cancelButtonIndex != buttonIndex) {
		[self.incident removePhotoAtIndex:actionSheet.tag];
		[self.tableView reloadData];	
	}
}

#pragma mark -
#pragma mark LocatorDelegate

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)userLatitude longitude:(NSString *)userLongitude {
	DLog(@"locator: %@, %@", userLatitude, userLongitude);
	if (self.incident.latitude == nil && self.incident.longitude == nil) {
		self.incident.latitude = userLatitude;
		self.incident.longitude = userLongitude;
	}
	[[Locator sharedLocator] lookupAddressForDelegate:self];
	[self setFooter:[NSString stringWithFormat:@"%@, %@", userLatitude, userLongitude] 
		  atSection:TableSectionLocation];
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
}

- (void) locatorFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self setFooter:NSLocalizedString(@"Error Detecting Location", nil) atSection:TableSectionLocation];
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
}

- (void) lookupFinished:(Locator *)locator address:(NSString *)address {
	DLog(@"address:%@", address);
	[self setFooter:address atSection:TableSectionLocation];
	if ([NSString isNilOrEmpty:self.incident.location]) {
		self.incident.location = address;
	}
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
}

- (void) lookupFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

#pragma mark -
#pragma mark ButtonTableCellDelegate

- (void) buttonCellClicked:(ButtonTableCell *)cell {
	DLog(@"");
	[self.alertView showYesNoWithTitle:NSLocalizedString(@"Delete Report", nil) 
							andMessage:NSLocalizedString(@"Are you sure you want to delete?", nil)
								forTag:AlertViewDelete];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != theAlertView.cancelButtonIndex) {
		if (theAlertView.tag == AlertViewUnsaved) {
			self.incident = nil;
			if (self.editing) {
				[self.view endEditing:YES];
				[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:0.3];	
			}
			else {
				[self dismissModalView];
			}	
		}
		else if (theAlertView.tag == AlertViewDelete){
			DLog(@"DELETE");
			[[Ushahidi sharedUshahidi] removeIncident:self.incident];
			self.incident = nil;
			if (self.editing) {
				[self.view endEditing:YES];
				[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:0.3];	
			}
			else {
				[self dismissModalView];
			}	
		}
	}
}

@end
