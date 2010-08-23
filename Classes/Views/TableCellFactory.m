//
//  TableCellFactory.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

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

@implementation TableCellFactory

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

+ (TextTableCell *) getTextTableCellWithDelegate:(id<TextTableCellDelegate>)delegate
										   table:(UITableView *)tableView {
	return [TableCellFactory getTextTableCellWithDelegate:delegate table:tableView identifier:@"TextTableCell"];
}

+ (TextTableCell *) getTextTableCellWithDelegate:(id<TextTableCellDelegate>)delegate
										   table:(UITableView *)tableView
									  identifier:(NSString *)cellIdentifier {
	TextTableCell *cell = (TextTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[TextTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier];
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
		cell = [[[BooleanTableCell alloc] initWithDelegate:self reuseIdentifier:cellIdentifier] autorelease];
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
		cell = [[[CheckBoxTableCell alloc] initWithDelegate:self reuseIdentifier:cellIdentifier] autorelease];
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
		cell = [[[MapTableCell alloc] initWithDelegate:self reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
}

@end
