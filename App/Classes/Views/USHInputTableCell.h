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

#import <Ushahidi/USHTableCell.h>

@protocol USHInputTableCellDelegate;

@interface USHInputTableCell : USHTableCell<UITextViewDelegate> {
@public
    UIImageView *imageView;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSObject<USHInputTableCellDelegate> *delegate;

- (void) showKeyboard;
- (void) hideKeyboard;
+ (CGFloat) heightForTable:(UITableView *)tableView text:(NSString *)text;

@end

@protocol USHInputTableCellDelegate <NSObject>

@optional

- (void) inputFocussed:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void) inputChanged:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;
- (void) inputReturned:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;

@end