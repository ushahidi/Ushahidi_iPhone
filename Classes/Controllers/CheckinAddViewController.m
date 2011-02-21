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

#import "CheckinAddViewController.h"
#import "LoadingViewController.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "ImageTableCell.h"
#import "TextTableCell.h"
#import "Checkin.h"
#import "Ushahidi.h"
#import "Photo.h"
#import "Settings.h"
#import "Device.h"

@interface CheckinAddViewController ()

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;	
@property (nonatomic, retain) Photo *photo;

@end

@implementation CheckinAddViewController

@synthesize cancelButton, doneButton, message, latitude, longitude, photo, imagePickerController;

typedef enum {
	TableSectionMessage,
	TableSectionLocation,
	TableSectionPhoto
} TableSection;


#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"");
	self.message = nil;
	self.latitude = nil;
	self.longitude = nil;
	self.photo = nil;
	[self.view endEditing:YES];
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"");
	[self.view endEditing:YES];
	Checkin *checkin = [[Checkin alloc] initWithMessage:self.message latitude:self.latitude longitude:self.longitude photo:self.photo];
	if ([[Ushahidi sharedUshahidi] uploadCheckin:checkin forDelegate:self]) {
		[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nill)];
	}
	else {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Checkin Error", nil) 
							 andMessage:NSLocalizedString(@"Unable to checkin, please try again later.", nil)];
	}
	[checkin release];
}

- (void) dismissModalView {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	self.imagePickerController = [[ImagePickerController alloc] initWithController:self];
	[self setHeader:NSLocalizedString(@"Message", nil) atSection:TableSectionMessage];
	[self setHeader:NSLocalizedString(@"Location", nil) atSection:TableSectionLocation];
	[self setHeader:NSLocalizedString(@"Photo", nil) atSection:TableSectionPhoto];
	DLog(@"%@", [Device deviceIdentifier]);
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.imagePickerController = nil;
	self.cancelButton = nil;
	self.doneButton = nil;
	self.message = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([[Locator sharedLocator] hasLocation]) {
		self.latitude = [[Locator sharedLocator] latitude];
		self.longitude = [[Locator sharedLocator] longitude];
		[self setFooter:[NSString stringWithFormat:@"%@, %@", self.latitude, self.longitude] atSection:TableSectionLocation];
	}
	else {
		[self setFooter:NSLocalizedString(@"Locating...", nil) atSection:TableSectionLocation];
		[[Locator sharedLocator] detectLocationForDelegate:self];
	}
	[self.tableView reloadData];
	[self.loadingView hide];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"To checkin, enter optional message and photo, then click the Send button.", nil)];
}

- (void)dealloc {
	[imagePickerController release];
	[cancelButton release];
	[doneButton release];
	[message release];
	[latitude release];
	[longitude release];
	[photo release];
	[super dealloc];
}

#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionMessage) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setPlaceholder:NSLocalizedString(@"Enter message", nil)];
		[cell setText:self.message];
		return cell;	
	}
	else if (indexPath.section == TableSectionLocation) {
		MapTableCell *cell = [TableCellFactory getMapTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setScrollable:YES];
		[cell setZoomable:YES];
		[cell removeAllPins];
		if (self.latitude != nil && self.longitude != nil) {
			[cell addPinWithTitle:NSLocalizedString(@"User Location", nill) 
						 subtitle:[NSString stringWithFormat:@"%@, %@", self.latitude, self.longitude] 
						 latitude:self.latitude 
						longitude:self.longitude];
			[cell resizeRegionToFitAllPins:YES];
		}
		return cell;
	}
	else if (indexPath.section == TableSectionPhoto) {
		if (self.photo) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
			[cell setImage:self.photo.image];
			return cell;
		}
		else {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			[cell setText:NSLocalizedString(@"Select photo", nil)];
			return cell;
		}
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionMessage) {
		return 80;
	}
	if (indexPath.section == TableSectionLocation) {
		return 150;
	}
	if (indexPath.section == TableSectionPhoto) {
		return self.photo == nil ? 45 : 200;
	}
	return 0;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
	if (indexPath.section == TableSectionPhoto) {
		if (self.photo) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																	 delegate:self 
															cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
													   destructiveButtonTitle:NSLocalizedString(@"Remove Photo", nil)
															otherButtonTitles:nil];
			[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
			[actionSheet showInView:[self view]];
			[actionSheet release];
		}
		else {
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			[self.imagePickerController showImagePickerForDelegate:self width:[[Settings sharedSettings] imageWidth] forRect:cell.frame];
		}
	}
}

#pragma mark -
#pragma mark TextViewCellDelegate

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	self.message = text;
}

- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	self.message = text;
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ImagePickerDelegate

- (void) imagePickerDidSelect:(ImagePickerController *)imagePicker {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Resizing...", nil)];
}

- (void) imagePickerDidFinish:(ImagePickerController *)imagePicker image:(UIImage *)image {
	DLog(@"");
	if (image != nil && image.size.width > 0 && image.size.height > 0) {
		self.photo = [Photo photoWithImage:image];
		[self.loadingView showWithMessage:NSLocalizedString(@"Resized", nil)];
		[self.loadingView hideAfterDelay:1.0];
	}
	else {
		self.photo = nil;
		[self.loadingView hide];
		[self.alertView showOkWithTitle:NSLocalizedString(@"Photo Error", nil) 
							 andMessage:NSLocalizedString(@"There was a problem resizing the photo.", nil)];
	}
	[self.tableView reloadData];
}

- (void) imagePickerDidCancel:(ImagePickerController *)imagePicker {
	DLog(@"");
}

#pragma mark -
#pragma mark UshahidiDelegate

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi checkin:(Checkin *)checkin {
	[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nil)];
}

- (void) uploadedToUshahidi:(Ushahidi *)ushahidi checkin:(Checkin *)checkin error:(NSError *)error {
	if (error != nil) {
		[self.loadingView hide];
		[self.alertView showOkWithTitle:NSLocalizedString(@"Checkin Error", nil) 
							 andMessage:[error localizedDescription]];
	}
	else {
		self.message = nil;
		self.latitude = nil;
		self.longitude = nil;
		self.photo = nil;
		[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
		[self.loadingView hideAfterDelay:1.0];
		[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:1.2];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.cancelButtonIndex != buttonIndex) {
		self.photo = nil;
		[self.tableView reloadData];	
	}
}

#pragma mark -
#pragma mark LocatorDelegate

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)userLatitude longitude:(NSString *)userLongitude {
	DLog(@"locator: %@, %@", userLatitude, userLongitude);
	self.latitude = userLatitude;
	self.longitude = userLongitude;
	[self setFooter:[NSString stringWithFormat:@"%@, %@", userLatitude, userLongitude] atSection:TableSectionLocation];
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
}

- (void) locatorFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

@end
