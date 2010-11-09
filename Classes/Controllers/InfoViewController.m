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
@property(nonatomic, assign) NSInteger mapZoomLevel;
@property(nonatomic, retain) UILabel *mapZoomLevelLabel;

- (UILabel *) getFooterLabel;

@end

@implementation InfoViewController

typedef enum {
	TableSectionEmail,
	TableSectionFirstName,
	TableSectionLastName,
	TableSectionBecomeDiscrete,
	TableSectionImageWidth,
	TableSectionDownloadMaps,
	TableSectionMapZoomLevel
} TableSection;

@synthesize email, firstName, lastName, downloadMaps, becomeDiscrete, imageWidth, imageWidthLabel, mapZoomLevel, mapZoomLevelLabel;

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
	[[Settings sharedSettings] setMapZoomLevel:self.mapZoomLevel];
	[[Settings sharedSettings] save];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIView

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.backgroundColor = [UIColor ushahidiDarkTan];
	self.imageWidthLabel = [self getFooterLabel];
	self.mapZoomLevelLabel = [self getFooterLabel];
	[self addHeaders:@"Email", @"First Name", @"Last Name", @"Discrete Mode On Shake", @"Resized Image Width", @"Download Incident Maps", @"Map Zoom Level", nil];		
}

- (UILabel *) getFooterLabel {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,  self.tableView.contentSize.width, 28)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor grayColor];
	label.textAlignment = UITextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:15];
	return label;
}
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.email = [[Settings sharedSettings] email];
	self.firstName = [[Settings sharedSettings] firstName];
	self.lastName = [[Settings sharedSettings] lastName];
	self.downloadMaps = [[Settings sharedSettings] downloadMaps];
	self.becomeDiscrete = [[Settings sharedSettings] becomeDiscrete];
	self.imageWidth = [[Settings sharedSettings] imageWidth];
	self.mapZoomLevel = [[Settings sharedSettings] mapZoomLevel];
	self.imageWidthLabel.text = [NSString stringWithFormat:@"%d pixels", (int)self.imageWidth];
	self.mapZoomLevelLabel.text = [NSString stringWithFormat:@"%d zoom level", (int)self.mapZoomLevel];
	[self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)dealloc {
	[email release];
	[firstName release];
	[lastName release];
	[mapZoomLevelLabel release];
	[imageWidthLabel release];
    [super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 7;
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
		BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setChecked:self.downloadMaps];
		return cell;
	}
	else if (indexPath.section == TableSectionBecomeDiscrete) {
		BooleanTableCell *cell = [TableCellFactory getBooleanTableCellForDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setChecked:self.becomeDiscrete];
		return cell;
	}
	else if (indexPath.section == TableSectionImageWidth) {
		SliderTableCell *cell = [TableCellFactory getSliderTableCellForDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setMaximum:1024];
		[cell setMinimum:200];
		[cell setValue:self.imageWidth];
		return cell;
	}
	else if (indexPath.section == TableSectionMapZoomLevel) {
		SliderTableCell *cell = [TableCellFactory getSliderTableCellForDelegate:self table:theTableView];
		cell.indexPath = indexPath;
		[cell setMaximum:21];
		[cell setMinimum:5];
		[cell setValue:self.mapZoomLevel];
		return cell;
	}
	else {
		TextFieldTableCell *cell = [TableCellFactory getTextFieldTableCellForDelegate:self table:theTableView];
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
	if (section == TableSectionImageWidth) {
		return self.imageWidthLabel;
	}
	if (section == TableSectionMapZoomLevel) {
		return self.mapZoomLevelLabel;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForFooterInSection:(NSInteger)section {
	if (section == TableSectionImageWidth) {
		return self.imageWidthLabel.frame.size.height;
	}
	if (section == TableSectionMapZoomLevel) {
		return self.mapZoomLevelLabel.frame.size.height;
	}
	return 0.0;
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
	if (cell.indexPath.section == TableSectionImageWidth) {
		self.imageWidth = value;
		self.imageWidthLabel.text = [NSString stringWithFormat:@"%d pixels", (int)value];	
	}
	else if (cell.indexPath.section == TableSectionMapZoomLevel) {
		self.mapZoomLevel = value;
		self.mapZoomLevelLabel.text = [NSString stringWithFormat:@"%d zoom level", (int)value];
	}
}

@end
