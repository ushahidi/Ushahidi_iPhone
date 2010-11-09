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
	return	self.name != nil && 
			[self.name length] > 0 &&
			self.url != nil && 
			[self.url length] > 0 && 
			([self.url hasPrefix:@"http://"] || [self.url hasPrefix:@"https://"]);
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
	[self.view endEditing:YES];
	[self.loadingView showWithMessage:@"Adding Server..."];
	if ([[Ushahidi sharedUshahidi] addDeploymentByName:self.name andUrl:self.url]) {
		[self.loadingView showWithMessage:@"Deployment Added!"];
		[self performSelector:@selector(dismissModalView) withObject:nil afterDelay:2.0];
	}
	else {
		[self.loadingView hide];
		[self.alertView showWithTitle:@"Error" andMessage:@"There was a problem adding deployment."];
	}	
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	[self addHeaders:@"Name", @"URL", nil];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.doneButton.enabled = NO;
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
	TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView];
	cell.indexPath = indexPath;
	if (indexPath.section == TableSectionName) {
		[cell setText:self.name];
		[cell setPlaceholder:@"Enter Deployment Name"];
	}
	else if (indexPath.section == TableSectionURL) {
		[cell setText:self.url];
		[cell setPlaceholder:@"Enter Deployment URL"];
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)theTableView titleForFooterInSection:(NSInteger)section {
	if (section == TableSectionName) {
		return @"Example: Ushahidi Demo";
	}
	if (section == TableSectionURL) {
		return @"Example: http://demo.ushahidi.com";
	}
	return nil;
}

#pragma mark -
#pragma mark TextFieldTableCellDelegate

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath {
	DLog(@"indexPath:[%d, %d]", indexPath.section, indexPath.row);
	[self performSelector:@selector(scrollToIndexPath:) withObject:indexPath afterDelay:0.3];
}

- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"text: %@", text);
	if (indexPath.section == TableSectionName) {
		self.name = text;
	}
	else if (indexPath.section == TableSectionURL) {
		self.url = text;
	}
	self.doneButton.enabled = [self hasValidInputs];
}

- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
	DLog(@"text: %@", text);
	if (indexPath.section == TableSectionName) {
		self.name = text;
	}
	else if (indexPath.section == TableSectionURL) {
		self.url = text;
	}
	self.doneButton.enabled = [self hasValidInputs];
}

@end
