//
//  TableCellFactory.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextTableCell;
@class SubtitleTableCell;
@class SearchTableCell;
@class TextFieldTableCell;
@class TextViewTableCell;
@class TextViewTableCell;
@class BooleanTableCell;
@class CheckBoxTableCell;

@protocol TextTableCellDelegate;
@protocol SearchTableCellDelegate;
@protocol TextFieldTableCellDelegate;
@protocol TextViewTableCellDelegate;
@protocol BooleanTableCellDelegate;
@protocol CheckBoxTableCellDelegate;

@interface TableCellFactory : NSObject {

}

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier;

+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView
												  identifier:(NSString *)cellIdentifier;

+ (TextTableCell *) getTextTableCellFWithDelegate:(id<TextTableCellDelegate>)delegate
											table:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier;

+ (TextFieldTableCell *) getTextFieldTableCellWithDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView
												identifier:(NSString *)cellIdentifier;

+ (TextViewTableCell *) getTextViewTableCellWithDelegate:(id<TextViewTableCellDelegate>)delegate
													table:(UITableView *)tableView
											   identifier:(NSString *)cellIdentifier;

+ (SearchTableCell *) getSearchTableCellWithDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier;

+ (BooleanTableCell *) getBooleanTableCellWithDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView
											identifier:(NSString *)cellIdentifier;

+ (CheckBoxTableCell *) getCheckBoxTableCellWithDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView
											  identifier:(NSString *)cellIdentifier;

@end
