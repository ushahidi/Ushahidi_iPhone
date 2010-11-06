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
@property(nonatomic, assign) BOOL downloadMaps;
@property(nonatomic, assign) BOOL becomeDiscrete;
@property(nonatomic, assign) CGFloat imageWidth;
@property(nonatomic, retain) UILabel *imageWidthLabel;

@end

@implementation InfoViewController

typedef enum {
	TableSectionEmail,
	TableSectionFirstName,
	TableSectionLastName,
	TableSectionDownloadMaps,
	TableSectionBecomeDiscrete,
	TableSectionImageWidth
} TableSection;

@synthesize email, firstName, lastName, downloadMaps, becomeDiscrete, imageWidth, imageWidthLabel;

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
	[[Settings sharedSettings] setDownloadMaps:self.downloadMaps];
	[[Settings sharedSettings] setBecomeDiscrete:self.becomeDiscrete];
	[[Settings sharedSettings] setImageWidth:self.imageWidth];
	[[Settings sharedSettings] save];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	self.imageWidthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self.tableView.contentSize.width, 28)];
	self.imageWidthLabel.backgroundColor = [UIColor clearColor];
	self.imageWidthLabel.textColor = [UIColor grayColor];
	self.imageWidthLabel.textAlignment = UITextAlignmentCenter;
	self.imageWidthLabel.font = [UIFont systemFontOfSize:15];
	[self addHeaders:@"Email", @"First Name", @"Last Name", @"Download Incident Maps", @"Discrete Mode On Shake", @"Resized Image Width", nil];		
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.email = [[Settings sharedSettings] email];
	self.firstName = [[Settings sharedSettings] firstName];
	self.lastName = [[Settings sharedSettings] lastName];
	self.downloadMaps = [[Settings sharedSettings] downloadMaps];
	self.becomeDiscrete = [[Settings sharedSettings] becomeDiscrete];
	self.imageWidth = [[Settings sharedSettings] imageWidth];
	self.imageWidthLabel.text = [NSString stringWithFormat:@"%d pixels", (int)self.imageWidth];
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
	return 6;
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
		BooleanTableCell *cell = [TableCellFactory getBooleanTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setChecked:self.downloadMaps];
		return cell;
	}
	else if (indexPath.section == TableSectionBecomeDiscrete) {
		BooleanTableCell *cell = [TableCellFactory getBooleanTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setChecked:self.becomeDiscrete];
		return cell;
	}
	else if (indexPath.section == TableSectionImageWidth) {
		SliderTableCell *cell = [TableCellFactory getSliderTableCellWithDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setMaximum:1024];
		[cell setMinimum:200];
		[cell setValue:self.imageWidth];
		return cell;
	}
	else {
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
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return section == TableSectionImageWidth ? self.imageWidthLabel : nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForFooterInSection:(NSInteger)section {
	return section == TableSectionImageWidth ? self.imageWidthLabel.frame.size.height : 0.0;
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
	self.imageWidth = value;
	self.imageWidthLabel.text = [NSString stringWithFormat:@"%d pixels", (int)value];
}

@end
