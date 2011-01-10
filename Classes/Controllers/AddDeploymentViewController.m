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

#import "AddDeploymentViewController.h"
#import "TableCellFactory.h"
#import "LoadingViewController.h"
#import "AlertView.h"
#import "InputView.h"
#import "Ushahidi.h"
#import "UIColor+Extension.h"
#import "NSString+Extension.h"

typedef enum {
	TableSectionName,
	TableSectionURL
} TableSection;

@interface AddDeploymentViewController ()

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *url;

- (BOOL) hasValidInputs;
- (void) dismissModalView;

@end

@implementation AddDeploymentViewController

@synthesize cancelButton, doneButton, name, url;

#pragma mark -
#pragma mark Private

- (BOOL) hasValidInputs {
	return	self.name != nil && [self.name length] > 0 &&
			self.url != nil && [self.url isValidURL];
}

- (void) dismissModalView {
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"cancel");
	if (self.editing) {
		[self.view endEditing:YES];
		[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:0.3];	
	}
	else {
		[self dismissModalView];
	}
}

- (IBAction) done:(id)sender {
	DLog(@"done");
	BOOL hasName = self.name != nil && [self.name length] > 0;
	BOOL validURL = self.url != nil && [self.url isValidURL];
	if (hasName == NO && validURL == NO) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Required Fields", nil) 
							 andMessage:NSLocalizedString(@"Name and URL are required fields", nil)];
	}
	else if (hasName == NO) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Required Field", nil) 
							 andMessage:NSLocalizedString(@"Name is a required field", nil)];
	}
	else if (validURL == NO) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Required Field", nil) 
							 andMessage:NSLocalizedString(@"URL is a required field", nil)];
	}
	else {
		[self.view endEditing:YES];
		[self.loadingView showWithMessage:NSLocalizedString(@"Adding...", nil)];
		if ([[Ushahidi sharedUshahidi] addDeploymentByName:self.name andUrl:self.url]) {
			[self.loadingView showWithMessage:NSLocalizedString(@"Added", nil)];
			[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:2.0];
		}
		else {
			[self.loadingView hide];
			[self.alertView showOkWithTitle:NSLocalizedString(@"Error", nil) 
								 andMessage:NSLocalizedString(@"There was a problem adding deployment", nil)];
		}	
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor ushahidiDarkTan];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	[self setHeader:NSLocalizedString(@"Name", nil) 
		  atSection:TableSectionName];
	[self setHeader:NSLocalizedString(@"URL", nil) 
		  atSection:TableSectionURL];
	[self setFooter:NSLocalizedString(@"Example: Ushahidi Demo", nil)
		  atSection:TableSectionName];
	[self setFooter:NSLocalizedString(@"Example: http://demo.ushahidi.com", nil)
		  atSection:TableSectionURL];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.name = nil;
	self.url = nil;
	[self.tableView reloadData];
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
	if (indexPath.section == TableSectionName) {
		[cell setText:self.name];
		[cell setPlaceholder:NSLocalizedString(@"Enter Deployment Name", nil)];
		[cell setKeyboardType:UIKeyboardTypeDefault];
		[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		if ([NSString isNilOrEmpty:self.name]) {
			[cell showKeyboard];
		}
	}
	else if (indexPath.section == TableSectionURL) {
		[cell setText:self.url];
		[cell setPlaceholder:NSLocalizedString(@"Enter Deployment URL", nil)];
		[cell setKeyboardType:UIKeyboardTypeURL];
		[cell setAutocorrectionType:UITextAutocorrectionTypeNo];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		if ([NSString isNilOrEmpty:self.name] == NO && [NSString isNilOrEmpty:self.url]) {
			[cell showKeyboard];
		}
	}
	return cell;
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
	if (indexPath.section == TableSectionURL) {
		if ([NSString isNilOrEmpty:self.url]) {
			[cell setText:@"http://"];
		}
	}
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionName) {
		self.name = text;
	}
	else if (indexPath.section == TableSectionURL) {
		self.url = text;
		DLog(@"REGEX: %d", [text isValidURL]);
	}
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionName) {
		self.name = text;
	}
	else if (indexPath.section == TableSectionURL) {
		self.url = text;
	}
}

@end
