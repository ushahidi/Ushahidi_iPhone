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

@implementation TableCellFactory

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

+ (TextTableCell *) getTextTableCellFWithDelegate:(id<TextTableCellDelegate>)delegate
											table:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier {
	TextTableCell *cell = (TextTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[TextTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier];
	}
	return cell;
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

+ (TextFieldTableCell *) getTextFieldTableCellWithDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView
												identifier:(NSString *)cellIdentifier {
	TextFieldTableCell *cell = (TextFieldTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[TextFieldTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
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

+ (SearchTableCell *) getSearchTableCellWithDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier {
	SearchTableCell *cell = (SearchTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[SearchTableCell alloc] initWithDelegate:delegate reuseIdentifier:cellIdentifier] autorelease];
	}
	return cell;
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


@end
