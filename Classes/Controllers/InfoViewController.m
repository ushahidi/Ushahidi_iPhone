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

@interface InfoViewController()

@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *firstName;
@property(nonatomic, retain) NSString *lastName;

- (UIView *) headerForTable:(UITableView *)theTableView text:(NSString *)theText;

@end

@implementation InfoViewController

typedef enum {
	TableSectionEmail,
	TableSectionFirstName,
	TableSectionLastName
} TableSection;

@synthesize email, firstName, lastName;

#pragma mark -
#pragma mark Handlers

- (IBAction) cancel:(id)sender {
	[self.view endEditing:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) done:(id)sender {
	[self.view endEditing:YES];
	[[Settings sharedSettings] setEmail:self.email];
	[[Settings sharedSettings] setFirstName:self.firstName];
	[[Settings sharedSettings] setLastName:self.lastName];
	[[Settings sharedSettings] save];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.email = [[Settings sharedSettings] email];
	self.firstName = [[Settings sharedSettings] firstName];
	self.lastName = [[Settings sharedSettings] lastName];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[email release];
	[firstName release];
	[lastName release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellWithDelegate:self table:theTableView];
	cell.indexPath = indexPath;
	if (indexPath.section == TableSectionEmail) {
		[cell setPlaceholder:@"Enter email"];
		[cell setText:self.email];
	}
	else if (indexPath.section == TableSectionFirstName) {
		[cell setPlaceholder:@"Enter first name"];
		[cell setText:self.firstName];
	}
	else if (indexPath.section == TableSectionLastName) {
		[cell setPlaceholder:@"Enter last name"];
		[cell setText:self.lastName];
	}
	return cell;	
}

- (UIView *)tableView:(UITableView *)theTableView viewForHeaderInSection:(NSInteger)section {
	if (section == TableSectionEmail) {
		return [self headerForTable:theTableView text:@"Email"];
	}
	if (section == TableSectionFirstName) {
		return [self headerForTable:theTableView text:@"First Name"];
	}
	if (section == TableSectionLastName) {
		return [self headerForTable:theTableView text:@"Last Name"];
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [TableHeaderView getViewHeight];
}

- (UIView *) headerForTable:(UITableView *)theTableView text:(NSString *)theText {
	return [TableHeaderView headerForTable:theTableView text:theText textColor:[UIColor ushahidiRed] backgroundColor:[UIColor clearColor]];
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
		self.email = text;
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
		self.email = text;
	}
	else if (indexPath.section == TableSectionFirstName) {
		self.firstName = text;
	}
	else if (indexPath.section == TableSectionLastName) {
		self.lastName = text;
	}
}

@end
