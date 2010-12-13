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

#import <UIKit/UIKit.h>
#import "IndexedTableCell.h"

@protocol TextFieldTableCellDelegate;

@interface TextFieldTableCell : IndexedTableCell<UITextFieldDelegate> {

@public
	UITextField	*textField;
	
@private
	id<TextFieldTableCellDelegate> delegate;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, assign) UITextAutocorrectionType autocorrectionType;
@property (nonatomic, assign) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic, assign) UIKeyboardType keyboardType;

- (id)initForDelegate:(id<TextFieldTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setPlaceholder:(NSString *)placeholder;
- (void) setIsPassword:(BOOL)isPassword;
- (void) setText:(NSString *)text;
- (NSString *) text;
- (void) showKeyboard;
- (void) hideKeyboard;

@end

@protocol TextFieldTableCellDelegate <NSObject>

@optional

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;
- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;

@end
