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

#import "SettingsViewController.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "ImageTableCell.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "TextTableCell.h"
#import "Email.h"
#import "Device.h"
#import "NSString+Extension.h"
#import "LoadingViewController.h"

@interface SettingsViewController()

@property(nonatomic, retain) NSString *userEmail;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, assign) BOOL downloadMaps;
@property(nonatomic, assign) BOOL becomeDiscrete;
@property(nonatomic, assign) BOOL resizePhotos;
@property(nonatomic, assign) NSInteger imageWidth;
@property(nonatomic, assign) NSInteger mapZoomLevel;
@property(nonatomic, retain) Email *email;
@property(nonatomic, retain) UIImage *logo;

- (void) dismissModalView;
- (void) hideKeyboard;

@end

@implementation SettingsViewController

@synthesize userEmail;
@synthesize firstName;
@synthesize lastName;
@synthesize downloadMaps;
@synthesize becomeDiscrete;
@synthesize imageWidth;
@synthesize mapZoomLevel;
@synthesize resizePhotos;
@synthesize email;
@synthesize logo;
@synthesize cancelButton;
@synthesize doneButton;

#pragma mark -
#pragma mark Enums

typedef enum {
	TableSectionContact,
	TableSectionPhoto,
	TableSectionMap,
	TableSectionPrivacy,
	TableSectionApp
} TableSection;

typedef enum {
	TableRowContactFirst,
	TableRowContactLast,
	TableRowContactEmail
} TableRowContact;

typedef enum {
	TableRowPhotoResize,
	TableRowPhotoSize
} TableRowPhoto;

typedef enum {
	TableRowMapDownload,
	TableRowMapSize
} TableRowMap;

typedef enum {
	TableRowPrivacyShake
} TableRowPrivacy;

typedef enum {
	TableRowAppVersion,
	TableRowAppShare,
	TableRowAppEmail,
	TableRowAppWebsite,
	TableRowAppLogo
} TableRowApp;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	if (self.editing) {
		[self.view endEditing:YES];
		[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:0.3];	
	}
	else {
		[self dismissModalView];
	}
}

- (IBAction) done:(id)sender {
	if ([NSString isNilOrEmpty:self.userEmail] == NO && [self.userEmail isValidEmail] == NO) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Invalid Email", nil) 
							 andMessage:NSLocalizedString(@"Please enter a valid email address.", nil)];
	}
	else {
		[[Settings sharedSettings] setEmail:self.userEmail];
		[[Settings sharedSettings] setFirstName:self.firstName];
		[[Settings sharedSettings] setLastName:self.lastName];
		[[Settings sharedSettings] setDownloadMaps:self.downloadMaps];
		[[Settings sharedSettings] setBecomeDiscrete:self.becomeDiscrete];
		[[Settings sharedSettings] setResizePhotos:self.resizePhotos];
		[[Settings sharedSettings] setImageWidth:self.imageWidth];
		[[Settings sharedSettings] setMapZoomLevel:self.mapZoomLevel];
		[[Settings sharedSettings] save];
		if (self.editing) {
			[self.view endEditing:YES];
			[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:0.3];
		}
		else {
			[self dismissModalView];
		}
	}
}

- (void) dismissModalView {
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

- (void) hideKeyboard {
    [self.view endEditing:NO];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationBar.topItem.title = NSLocalizedString(@"Settings", nil);
    self.doneButton.title = NSLocalizedString(@"Done", nil);
    if ([self.doneButton respondsToSelector:@selector(setTintColor:)]) {
        self.doneButton.tintColor = [[Settings sharedSettings] doneButtonColor];
    }
	self.email = [[Email alloc] initWithController:self];
	self.logo = [Device isIPad] ? [UIImage imageNamed:@"Logo_iPad.png"] : [UIImage imageNamed:@"Logo_iPhone.png"];
    [self setHeader:NSLocalizedString(@"Contact Settings", nil) atSection:TableSectionContact];
	[self setHeader:NSLocalizedString(@"Photo Settings", nil) atSection:TableSectionPhoto];
	[self setHeader:NSLocalizedString(@"Map Settings", nil) atSection:TableSectionMap];
	[self setHeader:NSLocalizedString(@"Privacy Settings", nil) atSection:TableSectionPrivacy];
	[self setHeader:NSLocalizedString(@"App Settings", nil) atSection:TableSectionApp];
    UITapGestureRecognizer *gestureRecognizer = [[[UITapGestureRecognizer alloc] 
                                                  initWithTarget:self action:@selector(hideKeyboard)] autorelease];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.email = nil;
	self.logo = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.userEmail = [[Settings sharedSettings] email];
	self.firstName = [[Settings sharedSettings] firstName];
	self.lastName = [[Settings sharedSettings] lastName];
	self.downloadMaps = [[Settings sharedSettings] downloadMaps];
	self.becomeDiscrete = [[Settings sharedSettings] becomeDiscrete];
	self.resizePhotos = [[Settings sharedSettings] resizePhotos];
	self.imageWidth = [[Settings sharedSettings] imageWidth];
	self.mapZoomLevel = [[Settings sharedSettings] mapZoomLevel];
	if ([NSString isNilOrEmpty:self.userEmail] || [self.userEmail isValidEmail]) {
		[self setFooter:nil atSection:TableSectionContact];
	}
	else {
		[self setFooter:NSLocalizedString(@"Invalid Email Address", nil) atSection:TableSectionContact];
	}
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
	[userEmail release];
	[firstName release];
	[lastName release];
	[email release];
	[logo release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 5;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (section == TableSectionContact) {
		return 3;
	}
	if (section == TableSectionPhoto) {
		return 2;
	}
	if (section == TableSectionMap) {
		return 2;
	}
	if (section == TableSectionPrivacy) {
		return 1;
	}
	if (section == TableSectionApp) {
		return 5;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionPhoto &&
		indexPath.row == TableRowPhotoSize) {
		return 60;
	}
	if (indexPath.section == TableSectionPhoto &&
		indexPath.row == TableRowPhotoResize) {
		return 60;
	}
	if (indexPath.section == TableSectionMap &&
		indexPath.row == TableRowMapSize) {
		return 60;
	}
	if (indexPath.section == TableSectionApp &&
		indexPath.row == TableRowAppLogo) {
		return theTableView.frame.size.width * self.logo.size.height / self.logo.size.width;
	}
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionContact) {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		if (indexPath.row == TableRowContactFirst) {
			[cell setText:self.firstName];
			[cell setLabel:NSLocalizedString(@"first name", nil)];
			[cell setPlaceholder:NSLocalizedString(@"Enter first name", nil)];
			[cell setReturnKeyType:UIReturnKeyNext];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		}
		else if (indexPath.row == TableRowContactLast) {
			[cell setText:self.lastName];
			[cell setLabel:NSLocalizedString(@"last name", nil)];
			[cell setPlaceholder:NSLocalizedString(@"Enter last name", nil)];
			[cell setReturnKeyType:UIReturnKeyNext];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		}
		else if (indexPath.row == TableRowContactEmail) {
			[cell setText:self.userEmail];
			[cell setLabel:NSLocalizedString(@"email", nil)];
			[cell setPlaceholder:NSLocalizedString(@"Enter email", nil)];
			[cell setReturnKeyType:UIReturnKeyDefault];
			[cell setKeyboardType:UIKeyboardTypeEmailAddress];
			[cell setAutocorrectionType:UITextAutocorrectionTypeNo];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		}
		return cell;	
	}
	else if (indexPath.section == TableSectionPhoto) {
		if (indexPath.row == TableRowPhotoResize) {
			BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView indexPath:indexPath];
			[cell setText:NSLocalizedString(@"Resize Images", nil)];
			[cell setValue:self.resizePhotos];
			return cell;
		}
		else if (indexPath.row == TableRowPhotoSize) {
			SliderTableCell *cell = [TableCellFactory getSliderTableCellForDelegate:self table:theTableView indexPath:indexPath];
			cell.textLabel.text = NSLocalizedString(@"Resized Image Width", nil);
			cell.valueLabel.text = [NSString stringWithFormat:@"%d %@", (int)self.imageWidth, NSLocalizedString(@"pixels", nil)];
			[cell setMaximum:1024];
			[cell setMinimum:200];
			[cell setValue:self.imageWidth];
			[cell setEnabled:self.resizePhotos];
			return cell;
		}
	}
	else if (indexPath.section == TableSectionMap) {
		if (indexPath.row == TableRowMapDownload) {
			BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView indexPath:indexPath];
			[cell setText:NSLocalizedString(@"Download Offline Maps", nil)];
			[cell setValue:self.downloadMaps];
			DLog(@"BooleanTableCell.backgroundColor:%@", cell.backgroundColor);
			DLog(@"BooleanTableCell.backgroundView.backgroundColor:%@", cell.backgroundView.backgroundColor);
			return cell;
		}
		else if (indexPath.row == TableRowMapSize) {
			SliderTableCell *cell = [TableCellFactory getSliderTableCellForDelegate:self table:theTableView indexPath:indexPath];
			cell.textLabel.text = NSLocalizedString(@"Map Zoom Level", nil);
			cell.valueLabel.text = [NSString stringWithFormat:@"%d %@", (int)self.mapZoomLevel, NSLocalizedString(@"zoom", nil)];
			[cell setMaximum:21];
			[cell setMinimum:5];
			[cell setValue:self.mapZoomLevel];
			[cell setEnabled:self.downloadMaps];
			DLog(@"SliderTableCell.backgroundColor:%@", cell.backgroundColor);
			DLog(@"SliderTableCell.backgroundView.backgroundColor:%@", cell.backgroundView.backgroundColor);
			return cell;
		}
	}
	else if (indexPath.section == TableSectionPrivacy) {
		if (indexPath.row == TableRowPrivacyShake) {
			BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView indexPath:indexPath];
			[cell setText:NSLocalizedString(@"Discrete Mode On Shake", nil)];
			[cell setValue:self.becomeDiscrete];
			return cell;
		}
	}
	else if (indexPath.section == TableSectionApp) {
		if (indexPath.row == TableRowAppVersion) {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			[cell setText:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Version", nil), [Device appVersion]]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			DLog(@"TextTableCell.backgroundColor:%@", cell.backgroundColor);
			DLog(@"TextTableCell.backgroundView.backgroundColor:%@", cell.backgroundView.backgroundColor);
			return cell;
		}
		else if (indexPath.row == TableRowAppShare) {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			[cell setText:NSLocalizedString(@"Share Application", nil)];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			return cell;
		}
		else if (indexPath.row == TableRowAppEmail) {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			[cell setText:[[Settings sharedSettings] supportEmail]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			return cell;
		}
		else if (indexPath.row == TableRowAppWebsite) {
			TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
			[cell setText:[[Settings sharedSettings] supportURL]];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			return cell;
		}
		else if (indexPath.row == TableRowAppLogo) {
			ImageTableCell *cell = [TableCellFactory getImageTableCellWithImage:self.logo table:theTableView indexPath:indexPath];
			[cell setImage:self.logo];
			return cell;
		}
	}
	return nil;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionApp) {
		if (indexPath.row == TableRowAppShare) {
            NSString *appDownload = [[Settings sharedSettings] appStoreURL];
            NSString *appName = [[Settings sharedSettings] mapName];
			NSString *message = [NSString stringWithFormat:@"<a href='%@'>%@</a>", appDownload, appDownload];
			[self.email sendToRecipients:nil withMessage:message withSubject:appName];
		}
		else if (indexPath.row == TableRowAppEmail) {
            NSString *supportEmail = [[Settings sharedSettings] supportEmail];
			NSMutableString *message =[NSMutableString string];
            [message appendFormat:@"%@: %@<br/>", NSLocalizedString(@"App Version", nil), [Device appVersion]]; 
			[message appendFormat:@"%@: %@<br/>", NSLocalizedString(@"Device Model", nil), [Device deviceModel]]; 
			[message appendFormat:@"%@: %@<br/>", NSLocalizedString(@"Device Version", nil), [Device deviceVersion]]; 
			[self.email sendToRecipients:[NSArray arrayWithObject:supportEmail] withMessage:message withSubject:nil];
		}
		else if (indexPath.row == TableRowAppWebsite ||
				 indexPath.row == TableRowAppLogo) {
            NSString *supportURL = [[Settings sharedSettings] supportURL];
			[self.alertView showYesNoWithTitle:NSLocalizedString(@"Open In Safari?", nil) andMessage:supportURL];
		}
	}
	[theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate
					 
- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    DLog(@"%@", text);
	if (indexPath.section == TableSectionContact) {
		if (indexPath.row == TableRowContactFirst) {
			self.firstName = text;
		}
		else if (indexPath.row == TableRowContactLast) {
			self.lastName = text;
		}
		else if (indexPath.row == TableRowContactEmail) {
			self.userEmail = text;
		}
	}
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"%@", text);
	if (indexPath.section == TableSectionContact) {
		if (indexPath.row == TableRowContactFirst) {
			self.firstName = text;
			NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:TableRowContactLast inSection:TableSectionContact];
			TextFieldTableCell *nextCell = (TextFieldTableCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
			[nextCell showKeyboard];
		}
		else if (indexPath.row == TableRowContactLast) {
			self.lastName = text;
			NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:TableRowContactEmail inSection:TableSectionContact];
			TextFieldTableCell *nextCell = (TextFieldTableCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
			[nextCell showKeyboard];
		}
		else if (indexPath.row == TableRowContactEmail) {
			self.userEmail = text;
			if ([NSString isNilOrEmpty:text] || [text isValidEmail]) {
				[self setFooter:nil atSection:TableSectionContact];
                [self.tableView reloadData];
			}
			else {
				[self setFooter:NSLocalizedString(@"Invalid Email Address", nil) atSection:TableSectionContact];
				[self.tableView reloadData];
            }
            [self.view endEditing:YES];
		}
	}
}

#pragma mark -
#pragma mark BooleanTableCellDelegate
		 
- (void) booleanCellChanged:(BooleanTableCell *)cell value:(BOOL)value {
	DLog(@"checked: %d", value);
	if (cell.indexPath.section == TableSectionPrivacy && 
		cell.indexPath.row == TableRowPrivacyShake) {
		self.becomeDiscrete = value;
	}
	else if (cell.indexPath.section == TableSectionMap &&
			 cell.indexPath.row == TableRowMapDownload) {
		self.downloadMaps = value;
		[self.tableView reloadData];
	}
	else if (cell.indexPath.section == TableSectionPhoto &&
			 cell.indexPath.row == TableRowPhotoResize) {
		self.resizePhotos = value;
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark SliderTableCellDelegate

- (void) sliderCellChanged:(SliderTableCell *)cell value:(CGFloat)value {
	if (cell.indexPath.section == TableSectionPhoto &&
		cell.indexPath.row == TableRowPhotoSize) {
		self.imageWidth = value;
		cell.valueLabel.text = [NSString stringWithFormat:@"%d %@", (int)value, NSLocalizedString(@"pixels", nil)];
	}
	else if (cell.indexPath.section == TableSectionMap &&
			 cell.indexPath.row == TableRowMapSize) {
		self.mapZoomLevel = value;
		cell.valueLabel.text = [NSString stringWithFormat:@"%d %@", (int)value, NSLocalizedString(@"zoom", nil)];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [theAlertView cancelButtonIndex]) {
        NSString *supportUrl = [[Settings sharedSettings] supportURL];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:supportUrl]];
	}
}

@end
