//
//  TextFieldTableCell.h
//  Ushahidi
//
//  Created by Dale Zak on 10-05-20.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextFieldTableCellDelegate;

@interface TextFieldTableCell : UITableViewCell<UITextFieldDelegate> {
	id<TextFieldTableCellDelegate> delegate;
	UITextField	*textField;
	NSIndexPath *indexPath;
}

@property (nonatomic, assign) id<TextFieldTableCellDelegate> delegate;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) NSIndexPath *indexPath; 

- (id)initWithDelegate:(id<TextFieldTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setPlaceholder:(NSString *)placeholder;
- (void) setIsPassword:(BOOL)isPassword;
- (void) setMessage:(NSString *)message;
- (NSString *) getMessage;
- (void) showKeyboard;
- (void) hideKeyboard;

@end

@protocol TextFieldTableCellDelegate <NSObject>

@optional

- (void) textFieldFocussed:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void) textFieldChanged:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;
- (void) textFieldReturned:(TextFieldTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;

@end
