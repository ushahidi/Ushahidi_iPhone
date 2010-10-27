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

#import "TableCellFactory.h"
#import "TextTableCell.h"
#import "SubtitleTableCell.h"
#import "SearchTableCell.h"
#import "TextFieldTableCell.h"
#import "TextViewTableCell.h"
#import "BooleanTableCell.h"
#import "CheckBoxTableCell.h"
#import "ImageTableCell.h"
#import "MapTableCell.h"
#import "DateTableCell.h"
#import "DeploymentTableCell.h"
#import "IncidentTableCell.h"
#import "UIColor+Extension.h"
#import "SliderTableCell.h"

@interface TableCellFactory ()

+ (UITableViewCell *) getTableViewCellFromNib:(NSString *)nibName;

@end

@implementation TableCellFactory

+ (UITableViewCell *) getTableViewCellFromNib:(NSString *)nibName {
	NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
	for (id currentObject in topLevelObjects) {
		if ([currentObject isKindOfClass:[UITableViewCell class]]) {
			return (UITableViewCell *)currentObject;
		}
	}
	return nil;
}

#pragma mark -
#pragma mark DeploymentTableCell

+ (DeploymentTableCell *) getDeploymentTableCellForTable:(UITableView *)tableView {
	return [TableCellFactory getDeploymentTableCellForTable:tableView identifier:@"DeploymentTableCell"];
}

+ (DeploymentTableCell *) getDeploymentTableCellForTable:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier {
	DeploymentTableCell *cell = (DeploymentTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = (DeploymentTableCell *)[TableCellFactory getTableViewCellFromNib:@"DeploymentTableCell"];
		[cell setSelectedColor:[UIColor ushahidiDarkBrown]];
	}
	return cell;
}

#pragma mark -
#pragma mark IncidentTableCell

+ (IncidentTableCell *) getIncidentTableCellForTable:(UITableView *)tableView {
	return [TableCellFactory getIncidentTableCellForTable:tableView identifier:@"IncidentTableCell"];
}

+ (IncidentTableCell *) getIncidentTableCellForTable:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier {
	IncidentTableCell *cell = (IncidentTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = (IncidentTableCell *)[TableCellFactory getTableViewCellFromNib:@"IncidentTableCell"];
		[cell setSelectedColor:[UIColor ushahidiDarkBrown]];
	}
	return cell;
}

#pragma mark -
#pragma mark UITableViewCell

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView {
	return [TableCellFactory getDefaultTableCellForTable:tableView identifier:@"UITableViewCell"];
}

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark -
#pragma mark TextTableCell

+ (TextTableCell *) getTextTableCellForTable:(UITableView *)tableView {
	return [TableCellFactory getTextTableCellForTable:tableView identifier:@"TextTableCell"];
}

+ (TextTableCell *) getTextTableCellForTable:(UITableView *)tableView
								  identifier:(NSString *)cellIdentifier {
	TextTableCell *cell = (TextTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[TextTableCell alloc] initWithReuseIdentifier:cellIdentifier];
	}
	return cell;
}

#pragma mark -
#pragma mark SubtitleTableCell

+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView {
	return [TableCellFactory getSubtitleTableCellWithDefaultImage:defaultImage table:tableView identifier:@"SubtitleTableCell"];
}

+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView
												  identifier:(NSString *)cellIdentifier {
	SubtitleTableCell *cell = (SubtitleTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[SubtitleTableCell alloc] initWithDefaultImage:defaultImage reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark SliderTableCell

+ (SliderTableCell *) getSliderTableCellWithDelegate:(id<SliderTableCellDelegate>)delegate 
											   table:(UITableView *)tableView {
	return [TableCellFactory getSliderTableCellWithDelegate:delegate table:tableView identifier:@"SliderTableCell"];
}

+ (SliderTableCell *) getSliderTableCellWithDelegate:(id<SliderTableCellDelegate>)delegate
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier {
	SliderTableCell *cell = (SliderTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[SliderTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark TextFieldTableCell

+ (TextFieldTableCell *) getTextFieldTableCellWithDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView {
	return [TableCellFactory getTextFieldTableCellWithDelegate:delegate table:tableView identifier:@"TextFieldTableCell"];
}

+ (TextFieldTableCell *) getTextFieldTableCellWithDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView
												identifier:(NSString *)cellIdentifier {
	TextFieldTableCell *cell = (TextFieldTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[TextFieldTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark TextViewTableCell

+ (TextViewTableCell *) getTextViewTableCellWithDelegate:(id<TextViewTableCellDelegate>)delegate
												   table:(UITableView *)tableView {
	return [TableCellFactory getTextViewTableCellWithDelegate:delegate table:tableView identifier:@"TextViewTableCell"];
}

+ (TextViewTableCell *) getTextViewTableCellWithDelegate:(id<TextViewTableCellDelegate>)delegate
													 table:(UITableView *)tableView
												identifier:(NSString *)cellIdentifier {
	TextViewTableCell *cell = (TextViewTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[TextViewTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark SearchTableCell

+ (SearchTableCell *) getSearchTableCellWithDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView {
	return [TableCellFactory getSearchTableCellWithDelegate:delegate table:tableView identifier:@"SearchTableCell"];
}

+ (SearchTableCell *) getSearchTableCellWithDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier {
	SearchTableCell *cell = (SearchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[SearchTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark BooleanTableCell

+ (BooleanTableCell *) getBooleanTableCellWithDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView {
	return [TableCellFactory getBooleanTableCellWithDelegate:delegate table:tableView identifier:@"BooleanTableCell"];
}

+ (BooleanTableCell *) getBooleanTableCellWithDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView
											identifier:(NSString *)cellIdentifier {
	BooleanTableCell *cell = (BooleanTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[BooleanTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark CheckBoxTableCell

+ (CheckBoxTableCell *) getCheckBoxTableCellWithDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView {
	return [TableCellFactory getCheckBoxTableCellWithDelegate:delegate table:tableView identifier:@"CheckBoxTableCell"];
}

+ (CheckBoxTableCell *) getCheckBoxTableCellWithDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView
											  identifier:(NSString *)cellIdentifier {
	CheckBoxTableCell *cell = (CheckBoxTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[CheckBoxTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
		cell.checkedImage = [UIImage imageNamed:@"selected.png"];
		cell.uncheckedImage = [UIImage imageNamed:@"unselected.png"];
	}
	return cell;
}

#pragma mark -
#pragma mark ImageTableCell

+ (ImageTableCell *) getImageTableCellWithImage:(UIImage *)image 
										  table:(UITableView *)tableView {
	return [TableCellFactory getImageTableCellWithImage:image table:tableView identifier:@"ImageTableCell"];
}

+ (ImageTableCell *) getImageTableCellWithImage:(UIImage *)image 
										  table:(UITableView *)tableView
									 identifier:(NSString *)cellIdentifier {
	ImageTableCell *cell = (ImageTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[ImageTableCell alloc] initWithImage:image reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark MapTableCell

+ (MapTableCell *) getMapTableCellWithDelegate:(id<MapTableCellDelegate>)delegate
										 table:(UITableView *)tableView {
	return [TableCellFactory getMapTableCellWithDelegate:delegate table:tableView identifier:@"MapTableCell"];
}

+ (MapTableCell *) getMapTableCellWithDelegate:(id<MapTableCellDelegate>)delegate
										 table:(UITableView *)tableView
									identifier:(NSString *)cellIdentifier {
	MapTableCell *cell = (MapTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[MapTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

#pragma mark -
#pragma mark MapTableCell

+ (DateTableCell *) getDateTableCellWithDelegate:(id<DateTableCellDelegate>)delegate
										  table:(UITableView *)tableView {
	return [TableCellFactory getDateTableCellWithDelegate:delegate table:tableView identifier:@"DateTableCell"];
}

+ (DateTableCell *) getDateTableCellWithDelegate:(id<DateTableCellDelegate>)delegate
										  table:(UITableView *)tableView
									 identifier:(NSString *)cellIdentifier {
	DateTableCell *cell = (DateTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[DateTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

@end
