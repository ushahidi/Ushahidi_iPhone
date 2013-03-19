/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

@class USHMapTableCell;
@class USHReportTableCell;
@class USHCheckinTableCell;

@class USHTextTableCell;
@class USHIconTableCell;
@class USHImageTableCell;
@class USHCommentTableCell;
@class USHWebTableCell;
@class USHLocationTableCell;
@class USHInputTableCell;
@class USHCheckBoxTableCell;
@class USHSwitchTableCell;
@class USHSliderTableCell;

@protocol USHInputTableCellDelegate;
@protocol USHCheckBoxTableCellDelegate;
@protocol USHSwitchTableCellDelegate;
@protocol USHSliderTableCellDelegate;

@interface USHTableCellFactory : NSObject {

}

+ (USHMapTableCell *) mapTableCellForTable:(UITableView *)tableView 
                                 indexPath:(NSIndexPath *)indexPath;

+ (USHReportTableCell *) reportTableCellForTable:(UITableView *)tableView 
                                       indexPath:(NSIndexPath *)indexPath
                                       hasPhotos:(BOOL)photos;

+ (USHCheckinTableCell *) checkinTableCellForTable:(UITableView *)tableView 
                                         indexPath:(NSIndexPath *)indexPath
                                         hasPhotos:(BOOL)photos;

+ (USHTextTableCell *) textTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text;

+ (USHTextTableCell *) textTableCellForTable:(UITableView *)tableView
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text
                                   accessory:(BOOL)accessory
                                   selection:(BOOL)selection;

+ (USHIconTableCell *) iconTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text
                                        icon:(NSString *)icon;

+ (USHIconTableCell *) iconTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text
                                        icon:(NSString *)icon
                                   accessory:(BOOL)accessory;

+ (USHIconTableCell *) iconTableCellForTable:(UITableView *)tableView 
                                   indexPath:(NSIndexPath *)indexPath
                                        text:(NSString *)text
                                        icon:(NSString *)icon
                                   accessory:(BOOL)accessory
                                      greyed:(BOOL)greyed;

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView 
                                     indexPath:(NSIndexPath *)indexPath
                                         image:(NSData *)image
                                     removable:(BOOL)removable;

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
                                         image:(NSData *)image;

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
                                     imageName:(NSString *)imageName;

+ (USHImageTableCell *) imageTableCellForTable:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
                                     imageName:(NSString *)imageName
                                     removable:(BOOL)removable;

+ (USHCommentTableCell *) commentTableCellForTable:(UITableView *)tableView 
                                         indexPath:(NSIndexPath *)indexPath
                                           comment:(NSString *)comment
                                            author:(NSString *)author
                                              date:(NSString *)date
                                           pending:(BOOL)pending;

+ (USHWebTableCell *) webTableCellForTable:(UITableView *)tableView 
                                 indexPath:(NSIndexPath *)indexPath
                                       url:(NSString *)url;

+ (USHLocationTableCell *) locationTableCellForTable:(UITableView *)tableView 
                                           indexPath:(NSIndexPath *)indexPath
                                               title:(NSString *)title
                                            subtitle:(NSString*)subtitle
                                            latitude:(NSNumber *)latitude
                                           longitude:(NSNumber *)longitude;

+ (USHInputTableCell *) inputTableCellForTable:(UITableView *)tableView 
                                     indexPath:(NSIndexPath *)indexPath
                                      delegate:(NSObject<USHInputTableCellDelegate>*)delegate
                                   placeholder:(NSString *)placeholder
                                          text:(NSString *)text
                                          icon:(NSString *)icon;

+ (USHInputTableCell *) inputTableCellForTable:(UITableView *)tableView 
                                     indexPath:(NSIndexPath *)indexPath
                                      delegate:(NSObject<USHInputTableCellDelegate>*)delegate
                                   placeholder:(NSString *)placeholder
                                          text:(NSString *)text
                                          icon:(NSString *)icon
                                capitalization:(UITextAutocapitalizationType)autocapitalizationType
                                    correction:(UITextAutocorrectionType)autocorrectionType
                                      spelling:(UITextSpellCheckingType)spellCheckingType
                                      keyboard:(UIKeyboardType)keyboardType 
                                          done:(UIReturnKeyType) returnKeyType;

+ (USHCheckBoxTableCell *) checkBoxTableCellForTable:(UITableView *)tableView 
                                           indexPath:(NSIndexPath *)indexPath
                                            delegate:(NSObject<USHCheckBoxTableCellDelegate>*)delegate
                                               text:(NSString *)text
                                             details:(NSString *)details
                                             checked:(BOOL)checked;

+ (USHCheckBoxTableCell *) checkBoxTableCellForTable:(UITableView *)tableView 
                                           indexPath:(NSIndexPath *)indexPath
                                            delegate:(NSObject<USHCheckBoxTableCellDelegate>*)delegate
                                                text:(NSString *)text
                                             details:(NSString *)details
                                             checked:(BOOL)checked
                                               color:(UIColor*)color;

+ (USHSwitchTableCell *) switchTableCellForTable:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                        delegate:(NSObject<USHSwitchTableCellDelegate>*)delegate
                                            text:(NSString *)text
                                            icon:(NSString *)icon
                                              on:(BOOL)on;

+ (USHSliderTableCell *) sliderTableCellForTable:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                        delegate:(NSObject<USHSliderTableCellDelegate>*)delegate
                                            text:(NSString *)text
                                            icon:(NSString *)icon
                                           value:(NSInteger)value
                                             min:(NSInteger)min
                                             max:(NSInteger)max;

+ (USHSliderTableCell *) sliderTableCellForTable:(UITableView *)tableView
                                       indexPath:(NSIndexPath *)indexPath
                                        delegate:(NSObject<USHSliderTableCellDelegate>*)delegate
                                            text:(NSString *)text
                                            icon:(NSString *)icon
                                           value:(NSInteger)value
                                             min:(NSInteger)min
                                             max:(NSInteger)max
                                         enabled:(BOOL)enabled
                                          suffix:(NSString*)suffix;
@end
