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

#import "InfoViewController.h"
#import "TableCellFactory.h"
#import "UIColor+Extension.h"
#import "Settings.h"
#import "TableHeaderView.h"
#import "TextTableCell.h"
#import "Email.h"
#import "Device.h"
#import "NSString+Extension.h"
#import "LoadingViewController.h"

@interface InfoViewController()

@property(nonatomic, retain) NSString *userEmail;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *lastName;
@property(nonatomic, assign) BOOL downloadMaps;
@property(nonatomic, assign) BOOL becomeDiscrete;
@property(nonatomic, assign) CGFloat imageWidth;
@property(nonatomic, assign) NSInteger mapZoomLevel;
@property(nonatomic, retain) Email *email;

- (void) dismissModalView;

@end

@implementation InfoViewController

NSString * const kUshahidiWebsite = @"http://www.ushahidi.com";

typedef enum {
	TableSectionEmail,
	TableSectionFirstName,
	TableSectionLastName,
	TableSectionImageWidth,
	TableSectionDownloadMaps,
	TableSectionMapZoomLevel,
	TableSectionBecomeDiscrete,
	TableSectionShare,
	TableSectionSupport,
	TableSectionWebsite,
	TableSectionVersion
} TableSection;

@synthesize userEmail, firstName, lastName, downloadMaps, becomeDiscrete, imageWidth, mapZoomLevel, email;

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

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	self.email = [[Email alloc] initWithController:self];
	[self setHeader:NSLocalizedString(@"Email", nil) atSection:TableSectionEmail];
	[self setHeader:NSLocalizedString(@"First Name", nil) atSection:TableSectionFirstName];
	[self setHeader:NSLocalizedString(@"Last Name", nil) atSection:TableSectionLastName];
	[self setHeader:NSLocalizedString(@"Resized Image Width", nil) atSection:TableSectionImageWidth];
	[self setHeader:NSLocalizedString(@"Download Maps For Offline Viewing", nil) atSection:TableSectionDownloadMaps];
	[self setHeader:NSLocalizedString(@"Downloaded Map Zoom Level", nil) atSection:TableSectionMapZoomLevel];
	[self setHeader:NSLocalizedString(@"Discrete Mode On Shake", nil) atSection:TableSectionBecomeDiscrete];
	[self setHeader:NSLocalizedString(@"Share", nil) atSection:TableSectionShare];
	[self setHeader:NSLocalizedString(@"Contact", nil) atSection:TableSectionSupport];
	[self setHeader:NSLocalizedString(@"Website", nil) atSection:TableSectionWebsite];
	[self setHeader:NSLocalizedString(@"Version", nil) atSection:TableSectionVersion];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.email = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.userEmail = [[Settings sharedSettings] email];
	self.firstName = [[Settings sharedSettings] firstName];
	self.lastName = [[Settings sharedSettings] lastName];
	self.downloadMaps = [[Settings sharedSettings] downloadMaps];
	self.becomeDiscrete = [[Settings sharedSettings] becomeDiscrete];
	self.imageWidth = [[Settings sharedSettings] imageWidth];
	self.mapZoomLevel = [[Settings sharedSettings] mapZoomLevel];
	[self setFooter:[NSString stringWithFormat:@"%d %@", (int)self.imageWidth, NSLocalizedString(@"pixels", nil)]
		  atSection:TableSectionImageWidth];
	[self setFooter:[NSString stringWithFormat:@"%d %@", (int)self.mapZoomLevel, NSLocalizedString(@"zoom level", nil)]
		  atSection:TableSectionMapZoomLevel];
	[self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.alertView showInfoOnceOnly:NSLocalizedString(@"Enable Discrete Mode to hide your current activity, or Download Maps so you can view map images offline.", nil)];
}

- (void)dealloc {
	[userEmail release];
	[firstName release];
	[lastName release];
	[email release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 11;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDownloadMaps || 
		indexPath.section == TableSectionBecomeDiscrete) {
		return 35;
	}
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionDownloadMaps) {
		BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setChecked:self.downloadMaps];
		return cell;
	}
	else if (indexPath.section == TableSectionBecomeDiscrete) {
		BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setChecked:self.becomeDiscrete];
		return cell;
	}
	else if (indexPath.section == TableSectionImageWidth) {
		SliderTableCell *cell = [TableCellFactory getSliderTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setMaximum:1024];
		[cell setMinimum:200];
		[cell setValue:self.imageWidth];
		return cell;
	}
	else if (indexPath.section == TableSectionMapZoomLevel) {
		SliderTableCell *cell = [TableCellFactory getSliderTableCellForDelegate:self table:theTableView indexPath:indexPath];
		[cell setMaximum:21];
		[cell setMinimum:5];
		[cell setValue:self.mapZoomLevel];
		return cell;
	}
	else if (indexPath.section == TableSectionSupport) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		[cell setText:NSLocalizedString(@"Email Ushahidi Support", nil)];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		return cell;
	}
	else if (indexPath.section == TableSectionShare) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		[cell setText:NSLocalizedString(@"Share Ushahidi iOS", nil)];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		return cell;
	}
	else if (indexPath.section == TableSectionWebsite) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		[cell setText:kUshahidiWebsite];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		return cell;
	}
	else if (indexPath.section == TableSectionVersion) {
		TextTableCell *cell = [TableCellFactory getTextTableCellForTable:theTableView indexPath:indexPath];
		[cell setText:[Device appVersion]];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
	else {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
		if (indexPath.section == TableSectionEmail) {
			[cell setPlaceholder:NSLocalizedString(@"Enter email", nil)];
			[cell setText:self.userEmail];
			[cell setKeyboardType:UIKeyboardTypeEmailAddress];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		}
		else if (indexPath.section == TableSectionFirstName) {
			[cell setPlaceholder:NSLocalizedString(@"Enter first name", nil)];
			[cell setText:self.firstName];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		}
		else if (indexPath.section == TableSectionLastName) {
			[cell setPlaceholder:NSLocalizedString(@"Enter last name", nil)];
			[cell setText:self.lastName];
			[cell setKeyboardType:UIKeyboardTypeDefault];
			[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
			[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		}
		return cell;	
	}
	return nil;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == TableSectionSupport) {
		NSMutableString *message =[NSMutableString string];
		[message appendFormat:@"App Version: %@<br/>", [Device appVersion]]; 
		[message appendFormat:@"Device Model: %@<br/>", [Device deviceModel]]; 
		[message appendFormat:@"Device Version: %@<br/>", [Device deviceVersion]]; 
		[self.email sendToRecipients:[NSArray arrayWithObject:@"support@ushahidi.com"] withMessage:message withSubject:nil];
	}
	else if (indexPath.section == TableSectionWebsite) {
		[self.alertView showYesNoWithTitle:NSLocalizedString(@"Open In Safari?", nil) andMessage:kUshahidiWebsite];
	}
	else if (indexPath.section == TableSectionShare) {
		NSString *url = @"http://itunes.apple.com/app/ushahidi-ios/id410609585";
		NSString *message = [NSString stringWithFormat:@"<a href='%@'>%@</a>", url, url];
		[self.email sendToRecipients:nil withMessage:message withSubject:@"Ushahidi iOS"];
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
	if (indexPath.section == TableSectionEmail) {
		self.userEmail = text;
	}
	else if (indexPath.section == TableSectionFirstName) {
		self.firstName = text;
	}
	else if (indexPath.section == TableSectionLastName) {
		self.lastName = text;
	}
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"indexPath:[%d, %d] text: %@", indexPath.section, indexPath.row, text);
	if (indexPath.section == TableSectionEmail) {
		self.userEmail = text;
	}
	else if (indexPath.section == TableSectionFirstName) {
		self.firstName = text;
	}
	else if (indexPath.section == TableSectionLastName) {
		self.lastName = text;
	}
}

#pragma mark -
#pragma mark BooleanTableCellDelegate
		 
- (void) booleanCellChanged:(BooleanTableCell *)cell checked:(BOOL)checked {
	DLog(@"checked: %d", checked);
	if (cell.indexPath.section == TableSectionBecomeDiscrete) {
		self.becomeDiscrete = checked;
	}
	else if (cell.indexPath.section == TableSectionDownloadMaps) {
		self.downloadMaps = checked;
	}
}

#pragma mark -
#pragma mark SliderTableCellDelegate

- (void) sliderCellChanged:(SliderTableCell *)cell value:(CGFloat)value {
	DLog(@"sliderCellChanged: %f", value);
	if (cell.indexPath.section == TableSectionImageWidth) {
		self.imageWidth = value;
		[self setFooter:[NSString stringWithFormat:@"%d %@", (int)self.imageWidth, NSLocalizedString(@"pixels", nil)]
			  atSection:TableSectionImageWidth];
	}
	else if (cell.indexPath.section == TableSectionMapZoomLevel) {
		self.mapZoomLevel = value;
		[self setFooter:[NSString stringWithFormat:@"%d %@", (int)self.mapZoomLevel, NSLocalizedString(@"zoom level", nil)]
			  atSection:TableSectionMapZoomLevel];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)theAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [theAlertView cancelButtonIndex]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:kUshahidiWebsite]];
	}
}

@end
