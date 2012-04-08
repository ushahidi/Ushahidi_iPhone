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
#import "NSString+Extension.h"
#import "MapAnnotation.h"

@interface CheckinAddViewController ()

@property (nonatomic, retain) Checkin *checkin;

@end

@implementation CheckinAddViewController

@synthesize imagePickerController, checkin;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionMessage,
	TableSectionPhoto,
	TableSectionLocation
} TableSection;

typedef enum {
	TableRowContactFirst,
	TableRowContactLast,
	TableRowContactEmail
} TableRowContact;

#pragma mark -
#pragma mark Handlers

- (void) setItem:(NSObject *)item {
    self.checkin = (Checkin *)item;
}

- (NSObject*) item {
    return self.checkin;
}

- (IBAction) cancel:(id)sender {
	DLog(@"");
	self.checkin = nil;
	[self.view endEditing:YES];
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"");
	[self.view endEditing:YES];
	if ([[Ushahidi sharedUshahidi] uploadCheckin:self.checkin forDelegate:self]) {
		[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nill)];
	}
	else {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Checkin Error", nil) 
							 andMessage:NSLocalizedString(@"Unable to checkin, please try again later.", nil)];
	}
}

- (void) hideKeyboard {
    [self.view endEditing:NO];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationBar.topItem.title = NSLocalizedString(@"Add Checkin", nil);
	self.doneButton.title = NSLocalizedString(@"Send", nil);
	self.imagePickerController = [[ImagePickerController alloc] initWithController:self];
	[self setHeader:NSLocalizedString(@"Message", nil) atSection:TableSectionMessage];
	[self setHeader:NSLocalizedString(@"Location", nil) atSection:TableSectionLocation];
	[self setHeader:NSLocalizedString(@"Photo", nil) atSection:TableSectionPhoto];
    
    UITapGestureRecognizer *gestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)] autorelease];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.imagePickerController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.modalViewController == nil) {
		self.checkin = [[Checkin alloc] initWithDefaultValues];
		self.checkin.mobile = [Device deviceIdentifierHashed];
		self.checkin.firstName = [[Settings sharedSettings] firstName];
		self.checkin.lastName = [[Settings sharedSettings] lastName];
		self.checkin.email = [[Settings sharedSettings] email];
        if ([[Locator sharedLocator] hasLocation]) {
			self.checkin.latitude = [[Locator sharedLocator] latitude];
			self.checkin.longitude = [[Locator sharedLocator] longitude];
			[self setFooter:[NSString stringWithFormat:@"%@, %@", self.checkin.latitude, self.checkin.longitude] atSection:TableSectionLocation];
		}
		else {
			[self setFooter:NSLocalizedString(@"Locating...", nil) atSection:TableSectionLocation];
		}
		[[Locator sharedLocator] detectLocationForDelegate:self];
		[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	}
	[self.tableView reloadData];
	[self.loadingView hide];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
}

- (void)dealloc {
	[imagePickerController release];
	[checkin release];
	[super dealloc];
}

#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    if (section == TableSectionMessage) {
		return 1;	
	}
	if (section == TableSectionLocation) {
		return 1;
	}
	if (section == TableSectionPhoto) {
		return 1;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionMessage) {
		TextViewTableCell *cell = [TableCellFactory getTextViewTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setPlaceholder:NSLocalizedString(@"Enter message", nil)];
		[cell setText:self.checkin.message];
        [cell setReturnKeyType:UIReturnKeyDefault];
		[cell setKeyboardType:UIKeyboardTypeDefault];
        [cell setAutocorrectionType:UITextAutocorrectionTypeYes];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
		return cell;	
	}
	else if (indexPath.section == TableSectionLocation) {
		MapTableCell *cell = [TableCellFactory getMapTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setScrollable:YES];
		[cell setZoomable:YES];
		[cell setAnimatesDrop:YES];
		[cell setCanShowCallout:YES];
		[cell setDraggable:YES];
        [cell setTappable:YES];
		if (self.checkin.latitude != nil && self.checkin.longitude != nil) {
			NSString *location = [NSString stringWithFormat:@"%@, %@", self.checkin.latitude, self.checkin.longitude];
			if ([location isEqualToString:cell.location] == NO) {
				[cell removeAllPins];
				[cell addPinWithTitle:NSLocalizedString(@"User Location", nil) 
							 subtitle:nil 
							 latitude:self.checkin.latitude 
							longitude:self.checkin.longitude];
				[cell resizeRegionToFitAllPins:YES];
				cell.location = location;
			}
		}
		return cell;
	}
	else if (indexPath.section == TableSectionPhoto) {
		if (self.checkin.hasPhotos) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:nil table:theTableView indexPath:indexPath];
			Photo *photo = [self.checkin.photos objectAtIndex:0];
			[cell setImage:photo.image];
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
		return [Device isIPad] ? 160 : 70;
	}
	if (indexPath.section == TableSectionLocation) {
        if ([Device isIPad]) {
            return [Device isPortraitMode] ? 600 : 350;
        }
        return 165;
    }
	if (indexPath.section == TableSectionPhoto) {
		if (self.checkin.hasPhotos) {
			Photo *photo = [self.checkin.photos objectAtIndex:indexPath.row];
			if (photo != nil && photo.image != nil) {
				return theTableView.frame.size.width * photo.image.size.height / photo.image.size.width;
			}
			return 200;	
		}
		return 44;
	}
	return 0;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"didSelectRowAtIndexPath:[%d, %d]", indexPath.section, indexPath.row);
    [self.view endEditing:YES];
	if (indexPath.section == TableSectionPhoto) {
		if ([self.checkin.photos count] > 0) {
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																	 delegate:self 
															cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
													   destructiveButtonTitle:NSLocalizedString(@"Remove Photo", nil)
															otherButtonTitles:nil];
			[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
			[actionSheet showInView:[self view]];
			[actionSheet release];
		}
		else {
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
			[self.imagePickerController showImagePickerForDelegate:self
															resize:[[Settings sharedSettings] resizePhotos]
															 width:[[Settings sharedSettings] imageWidth] 
														   forRect:cell.frame];
		}
	}
    [theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark TextViewCellDelegate

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath {
    DLog(@"textViewFocussed:[%d, %d]", indexPath.section, indexPath.row);
    [self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
    DLog(@"Table:%f,%f", self.tableView.frame.size.width, self.tableView.frame.size.height);
}

- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionMessage) {
		self.checkin.message = text;
	}
}

- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionMessage) {
		self.checkin.message = text;
	}
    //[cell hideKeyboard];
    DLog(@"Table:%f,%f", self.tableView.frame.size.width, self.tableView.frame.size.height);
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void) mapTableCellDragged:(MapTableCell *)cell latitude:(NSString *)latitude longitude:(NSString *)longitude {
	DLog(@"dragged:%@ %@, %@", [cell class], latitude, longitude);
	self.checkin.latitude = latitude;
	self.checkin.longitude = longitude;
	[self setFooter:[NSString stringWithFormat:@"%@, %@", latitude, longitude] atSection:TableSectionLocation];
}

- (void) mapTableCellTapped:(MapTableCell *)cell latitude:(NSString *)latitude longitude:(NSString *)longitude {
	DLog(@"tapped:%@ %@, %@", [cell class], latitude, longitude);
	self.checkin.latitude = latitude;
	self.checkin.longitude = longitude;
	if ([cell isKindOfClass:[MapTableCell class]]) {
		[cell removeAllPins];
		[cell addPinWithTitle:NSLocalizedString(@"User Location", nil) 
													subtitle:nil 
													latitude:self.checkin.latitude 
												   longitude:self.checkin.longitude];
		[cell setLocation:[NSString stringWithFormat:@"%@, %@", self.checkin.latitude, self.checkin.longitude]];
		
	}
	else {
		[self.tableView reloadData];
	}
	[self setFooter:[NSString stringWithFormat:@"%@, %@", latitude, longitude] atSection:TableSectionLocation];
}

#pragma mark -
#pragma mark ImagePickerDelegate

- (void) imagePickerDidSelect:(ImagePickerController *)imagePicker {
	DLog(@"");
	if ([[Settings sharedSettings] resizePhotos]) {
		[self.loadingView showWithMessage:NSLocalizedString(@"Resizing...", nil)];
	}
	else {
		[self.loadingView showWithMessage:NSLocalizedString(@"Adding...", nil)];
	}
}

- (void) imagePickerDidFinish:(ImagePickerController *)imagePicker image:(UIImage *)image {
	DLog(@"");
	if (image != nil && image.size.width > 0 && image.size.height > 0) {
		[self.checkin addPhoto:[Photo photoWithImage:image]];
		if ([[Settings sharedSettings] resizePhotos]) {
			[self.loadingView showWithMessage:NSLocalizedString(@"Resized", nil)];
		}
		else {
			[self.loadingView showWithMessage:NSLocalizedString(@"Added", nil)];
		}
		[self.loadingView hideAfterDelay:1.0];
	}
	else {
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

- (void) uploadingToUshahidi:(Ushahidi *)ushahidi checkin:(Checkin *)theCheckin {
	[self.loadingView showWithMessage:NSLocalizedString(@"Sending...", nil)];
}

- (void) uploadedToUshahidi:(Ushahidi *)ushahidi checkin:(Checkin *)theCheckin error:(NSError *)error {
	if (error != nil) {
		[self.loadingView hide];
		[self.alertView showOkWithTitle:NSLocalizedString(@"Checkin Error", nil) 
							 andMessage:[error localizedDescription]];
	}
	else {
		DLog(@"Checkin: %@", theCheckin.identifier);
		[self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
		[self.loadingView hideAfterDelay:1.0];
		[self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:1.2];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.cancelButtonIndex != buttonIndex) {
		[self.checkin removePhotos];
		[self.tableView reloadData];	
	}
}

#pragma mark -
#pragma mark LocatorDelegate

- (void) locatorFinished:(Locator *)locator latitude:(NSString *)userLatitude longitude:(NSString *)userLongitude {
	DLog(@"latitude:%@ longitude:%@", userLatitude, userLongitude);
	self.checkin.latitude = userLatitude;
	self.checkin.longitude = userLongitude;
	[self setFooter:[NSString stringWithFormat:@"%@, %@", userLatitude, userLongitude] atSection:TableSectionLocation];
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
	[[Locator sharedLocator] lookupAddressForDelegate:self];
}

- (void) locatorFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
	[self setFooter:NSLocalizedString(@"Error Detecting Location", nil) atSection:TableSectionLocation];
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
	[self.alertView showOkWithTitle:NSLocalizedString(@"Location Error", nil) 
						 andMessage:NSLocalizedString(@"There was a problem detecting your location. Please ensure that Location Services is enabled for Ushahidi in Settings > General > Location Services.", nil)];
}

- (void) lookupFinished:(Locator *)locator address:(NSString *)address {
	DLog(@"address:%@", address);
	[self setFooter:address atSection:TableSectionLocation];
	if (self.editing == NO) {
		[self.tableView reloadData];
	}
}

- (void) lookupFailed:(Locator *)locator error:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

@end
