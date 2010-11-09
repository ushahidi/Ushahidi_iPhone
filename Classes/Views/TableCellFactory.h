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
@class DateTableCell;
@class DeploymentTableCell;
@class IncidentTableCell;
@class SliderTableCell;

@protocol TextTableCellDelegate;
@protocol SearchTableCellDelegate;
@protocol TextFieldTableCellDelegate;
@protocol TextViewTableCellDelegate;
@protocol BooleanTableCellDelegate;
@protocol CheckBoxTableCellDelegate;
@protocol MapTableCellDelegate;
@protocol DateTableCellDelegate;
@protocol SliderTableCellDelegate;

@interface TableCellFactory : NSObject {

}

+ (DeploymentTableCell *) getDeploymentTableCellForTable:(UITableView *)tableView;

+ (DeploymentTableCell *) getDeploymentTableCellForTable:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier;

+ (IncidentTableCell *) getIncidentTableCellForTable:(UITableView *)tableView;

+ (IncidentTableCell *) getIncidentTableCellForTable:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier;

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView;

+ (UITableViewCell *) getDefaultTableCellForTable:(UITableView *)tableView
									   identifier:(NSString *)cellIdentifier;


+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView;

+ (SubtitleTableCell *) getSubtitleTableCellWithDefaultImage:(UIImage *)defaultImage 
													   table:(UITableView *)tableView
												  identifier:(NSString *)cellIdentifier;


+ (TextTableCell *) getTextTableCellForTable:(UITableView *)tableView;

+ (TextTableCell *) getTextTableCellForTable:(UITableView *)tableView
								  identifier:(NSString *)cellIdentifier;

+ (SliderTableCell *) getSliderTableCellForDelegate:(id<SliderTableCellDelegate>)delegate 
											   table:(UITableView *)tableView;

+ (SliderTableCell *) getSliderTableCellForDelegate:(id<SliderTableCellDelegate>)delegate
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier;

+ (TextFieldTableCell *) getTextFieldTableCellForDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView;

+ (TextFieldTableCell *) getTextFieldTableCellForDelegate:(id<TextFieldTableCellDelegate>)delegate
													 table:(UITableView *)tableView
												identifier:(NSString *)cellIdentifier;

+ (TextViewTableCell *) getTextViewTableCellForDelegate:(id<TextViewTableCellDelegate>)delegate
												   table:(UITableView *)tableView;

+ (TextViewTableCell *) getTextViewTableCellForDelegate:(id<TextViewTableCellDelegate>)delegate
												   table:(UITableView *)tableView
											  identifier:(NSString *)cellIdentifier;


+ (SearchTableCell *) getSearchTableCellForDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView;

+ (SearchTableCell *) getSearchTableCellForDelegate:(id<SearchTableCellDelegate>)delegate 
											   table:(UITableView *)tableView
										  identifier:(NSString *)cellIdentifier;


+ (BooleanTableCell *) getBooleanTableCellForDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView;

+ (BooleanTableCell *) getBooleanTableCellForDelegate:(id<BooleanTableCellDelegate>)delegate
												 table:(UITableView *)tableView
											identifier:(NSString *)cellIdentifier;


+ (CheckBoxTableCell *) getCheckBoxTableCellForDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView;

+ (CheckBoxTableCell *) getCheckBoxTableCellForDelegate:(id<CheckBoxTableCellDelegate>)delegate
												   table:(UITableView *)tableView
											  identifier:(NSString *)cellIdentifier;

+ (ImageTableCell *) getImageTableCellWithImage:(UIImage *)image 
										  table:(UITableView *)tableView;

+ (ImageTableCell *) getImageTableCellWithImage:(UIImage *)image 
										  table:(UITableView *)tableView
									 identifier:(NSString *)cellIdentifier;


+ (MapTableCell *) getMapTableCellForDelegate:(id<MapTableCellDelegate>)delegate
										 table:(UITableView *)tableView;

+ (MapTableCell *) getMapTableCellForDelegate:(id<MapTableCellDelegate>)delegate
										 table:(UITableView *)tableView
									identifier:(NSString *)cellIdentifier;

+ (DateTableCell *) getDateTableCellForDelegate:(id<DateTableCellDelegate>)delegate
										   table:(UITableView *)tableView;

+ (DateTableCell *) getDateTableCellForDelegate:(id<DateTableCellDelegate>)delegate
										   table:(UITableView *)tableView
									  identifier:(NSString *)cellIdentifier;

@end
