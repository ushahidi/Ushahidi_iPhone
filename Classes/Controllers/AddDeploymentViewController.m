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
			self.url != nil && [self.url length] > 0 && 
			([[self.url lowercaseString] hasPrefix:@"http://"] || 
			 [[self.url lowercaseString] hasPrefix:@"https://"]);
}

- (void) dismissModalView {
	[self.loadingView hide];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	DLog(@"cancel");
	[self.view endEditing:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	DLog(@"done");
	BOOL hasName = self.name != nil && [self.name length] > 0;
	BOOL hasURL = self.url != nil && [self.url length] > 0 && 
					([[self.url lowercaseString] hasPrefix:@"http://"] || 
					 [[self.url lowercaseString] hasPrefix:@"https://"]);
	if (hasName == NO && hasURL == NO) {
		[self.alertView showWithTitle:NSLocalizedString(@"Missing Fields", @"Missing Fields") 
						   andMessage:NSLocalizedString(@"Name and URL are required fields", @"Name and URL are required fields")];
	}
	else if (hasName == NO) {
		[self.alertView showWithTitle:NSLocalizedString(@"Missing Fields", @"Missing Fields") 
						   andMessage:NSLocalizedString(@"Name is a required field", @"Name is required field")];
	}
	else if (hasURL == NO) {
		[self.alertView showWithTitle:NSLocalizedString(@"Missing Fields", @"Missing Fields") 
						   andMessage:NSLocalizedString(@"URL is a required field", @"URL is a required field")];
	}
	else {
		[self.view endEditing:YES];
		[self.loadingView showWithMessage:NSLocalizedString(@"Adding...", @"Adding...")];
		if ([[Ushahidi sharedUshahidi] addDeploymentByName:self.name andUrl:self.url]) {
			[self.loadingView showWithMessage:NSLocalizedString(@"Added", @"Added")];
			[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:2.0];
		}
		else {
			[self.loadingView hide];
			[self.alertView showWithTitle:NSLocalizedString(@"Error", @"Error") andMessage:NSLocalizedString(@"There was a problem adding deployment", @"There was a problem adding deployment")];
		}	
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	[self setHeader:NSLocalizedString(@"Name", @"Name") 
		  atSection:TableSectionName];
	[self setHeader:NSLocalizedString(@"URL", @"URL") 
		  atSection:TableSectionURL];
	[self setFooter:NSLocalizedString(@"Example: Ushahidi Demo", @"Example: Ushahidi Demo")
		  atSection:TableSectionName];
	[self setFooter:NSLocalizedString(@"Example: http://demo.ushahidi.com", @"Example: http://demo.ushahidi.com")
		  atSection:TableSectionURL];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//self.doneButton.enabled = NO;
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
	if (section == TableSectionName) {
		return 1;
	}
	if (section == TableSectionURL) {
		return 1;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView indexPath:indexPath];
	if (indexPath.section == TableSectionName) {
		[cell setText:self.name];
		[cell setPlaceholder:NSLocalizedString(@"Enter Deployment Name", @"Enter Deployment Name")];
		[cell setKeyboardType:UIKeyboardTypeDefault];
		[cell setAutocorrectionType:UITextAutocorrectionTypeYes];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeWords];
	}
	else if (indexPath.section == TableSectionURL) {
		[cell setText:self.url];
		[cell setPlaceholder:NSLocalizedString(@"Enter Deployment URL", @"Enter Deployment URL")];
		[cell setKeyboardType:UIKeyboardTypeURL];
		[cell setAutocorrectionType:UITextAutocorrectionTypeNo];
		[cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	}
	return cell;
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionName) {
		self.name = text;
	}
	else if (indexPath.section == TableSectionURL) {
		self.url = text;
	}
	//self.doneButton.enabled = [self hasValidInputs];
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	if (indexPath.section == TableSectionName) {
		self.name = text;
	}
	else if (indexPath.section == TableSectionURL) {
		self.url = text;
	}
	//self.doneButton.enabled = [self hasValidInputs];
}

@end
