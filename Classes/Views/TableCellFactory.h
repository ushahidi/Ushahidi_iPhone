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
@class ImageTableCell;
@class MapTableCell;

@protocol TextTableCellDelegate;
@protocol SearchTableCellDelegate;
@protocol TextFieldTableCellDelegate;
@protocol TextViewTableCellDelegate;
@protocol BooleanTableCellDelegate;
@protocol CheckBoxTableCellDelegate;
@protocol MapTableCellDelegate;

@interface TableCellFactory : NSObject {

}

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView;

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier;


+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView;

+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView
												  identifier:(NSString *)cellIdentifier;


+ (TextTableCell *) getTextTableCellWithDelegate:(id<TextTableCellDelegate>)delegate
											table:(UITableView *)tableView;

+ (TextTableCell *) getTextTableCellWithDelegate:(id<TextTableCellDelegate>)delegate
											table:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier;


+ (TextFieldTableCell *) getTextFieldTableCellWithDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView;

+ (TextFieldTableCell *) getTextFieldTableCellWithDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView
												identifier:(NSString *)cellIdentifier;

+ (TextViewTableCell *) getTextViewTableCellWithDelegate:(id<TextViewTableCellDelegate>)delegate
												   table:(UITableView *)tableView;

+ (TextViewTableCell *) getTextViewTableCellWithDelegate:(id<TextViewTableCellDelegate>)delegate
												   table:(UITableView *)tableView
											  identifier:(NSString *)cellIdentifier;


+ (SearchTableCell *) getSearchTableCellWithDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView;

+ (SearchTableCell *) getSearchTableCellWithDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier;


+ (BooleanTableCell *) getBooleanTableCellWithDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView;

+ (BooleanTableCell *) getBooleanTableCellWithDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView
											identifier:(NSString *)cellIdentifier;


+ (CheckBoxTableCell *) getCheckBoxTableCellWithDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView;

+ (CheckBoxTableCell *) getCheckBoxTableCellWithDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView
											  identifier:(NSString *)cellIdentifier;

+ (ImageTableCell *) getImageTableCellWithImage:(UIImage *)image 
										  table:(UITableView *)tableView;

+ (ImageTableCell *) getImageTableCellWithImage:(UIImage *)image 
										  table:(UITableView *)tableView
									 identifier:(NSString *)cellIdentifier;


+ (MapTableCell *) getMapTableCellWithDelegate:(id<MapTableCellDelegate>)delegate
										 table:(UITableView *)tableView;

+ (MapTableCell *) getMapTableCellWithDelegate:(id<MapTableCellDelegate>)delegate
										 table:(UITableView *)tableView
									identifier:(NSString *)cellIdentifier;

@end
