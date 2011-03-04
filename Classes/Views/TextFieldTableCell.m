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

#import "TextFieldTableCell.h"
#import "UIColor+Extension.h"

@interface TextFieldTableCell ()

@property (nonatomic, assign) id<TextFieldTableCellDelegate> delegate;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UILabel *labelField;

- (UILabel *) getLabelWithFrame:(CGRect)rect;
- (UITextField *) getTextFieldWithFrame:(CGRect)rect;

@end

@implementation TextFieldTableCell

@synthesize delegate, textField, labelField;

- (id)initForDelegate:(id<TextFieldTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		
		CGRect contentViewFrame = CGRectInset(self.contentView.frame, 10, 10);
		
		self.labelField = [self getLabelWithFrame:CGRectMake(contentViewFrame.origin.x, contentViewFrame.origin.y - 2, 60, contentViewFrame.size.height)];
		self.labelField.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.labelField];
		
		self.textField = [self getTextFieldWithFrame:contentViewFrame];
		self.textField.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.textField];
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[textField release];
	[labelField release];
    [super dealloc];
}

- (void) setLabel:(NSString *)label {
	CGRect textFieldFrame = self.textField.frame;
	if (label != nil && [label length] > 0) {
		textFieldFrame.origin.x = self.labelField.frame.origin.x + self.labelField.frame.size.width + 10;
		textFieldFrame.size.width = self.contentView.frame.size.width - (self.labelField.frame.origin.x + self.labelField.frame.size.width) - 10;
		self.labelField.hidden = NO;
	}
	else {
		textFieldFrame = CGRectInset(self.contentView.frame, 10, 10);
		self.labelField.hidden = YES;
	}
	self.textField.frame = textFieldFrame;
	self.labelField.text = label;
}

- (UIReturnKeyType) returnKeyType {
	return self.textField.returnKeyType;
}

- (void) setReturnKeyType:(UIReturnKeyType)returnKeyType {
	self.textField.returnKeyType = returnKeyType;
}

- (UIKeyboardType) keyboardType {
	return self.textField.keyboardType;
}

- (void) setKeyboardType:(UIKeyboardType)keyboardType {
	self.textField.keyboardType = keyboardType;
}

- (UITextAutocorrectionType) autocorrectionType {
	return self.textField.autocorrectionType;
}

- (void) setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType {
	self.textField.autocorrectionType = autocorrectionType;
}

- (UITextAutocapitalizationType) autocapitalizationType {
	return self.textField.autocapitalizationType;
}

- (void) setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType {
	self.textField.autocapitalizationType = autocapitalizationType;
}

- (void) showKeyboard {
	[self.textField becomeFirstResponder];
}

- (void) hideKeyboard {
	[self.textField resignFirstResponder];
}

- (void) setPlaceholder:(NSString *)placeholder {
	self.textField.placeholder = placeholder;
}

- (void) setIsPassword:(BOOL)isPassword {
	self.textField.secureTextEntry = isPassword;
}

- (void) setText:(NSString *)text {
	self.textField.text = text;
}

- (NSString *) text {
	return self.textField.text;
}

#pragma mark -
#pragma mark Helpers

- (UITextField *) getTextFieldWithFrame:(CGRect)rect {
	UITextField *field = [[UITextField alloc] initWithFrame:rect];
	field.delegate = self;
	field.adjustsFontSizeToFitWidth = YES;
	field.textAlignment = UITextAlignmentLeft;
	field.autocorrectionType = UITextAutocorrectionTypeNo;
	field.autocapitalizationType = UITextAutocapitalizationTypeNone;
	field.keyboardType = UIKeyboardTypeDefault;
	field.borderStyle = UITextBorderStyleNone;
	field.font = [UIFont systemFontOfSize:16];
	field.clearButtonMode = UITextFieldViewModeWhileEditing;
	field.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	field.backgroundColor = self.contentView.backgroundColor;
	return [field autorelease];
}

- (UILabel *) getLabelWithFrame:(CGRect)rect {
	UILabel *label = [[UILabel alloc] initWithFrame:rect];
	label.font = [UIFont systemFontOfSize:12];
	label.textColor = [UIColor darkGrayColor];
	label.textAlignment = UITextAlignmentRight;
	return [label autorelease];
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
	[theTextField becomeFirstResponder];
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(textFieldFocussed:indexPath:)]) {
		[self.delegate textFieldFocussed:self indexPath:self.indexPath];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	DLog(@"RETURN");
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(textFieldReturned:indexPath:text:)]) {
		[self.delegate textFieldReturned:self indexPath:self.indexPath text:theTextField.text];
	}
	return YES;
}
 
- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:@"\n"]) {
		DLog(@"RETURN");
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(textFieldReturned:indexPath:text:)]) {
			[self.delegate textFieldReturned:self indexPath:self.indexPath text:theTextField.text];
		}
		return NO;
	}
	if (theTextField.keyboardType == UIKeyboardTypeURL && 
			 [theTextField.text isEqualToString:@"http://"] && 
			 [string hasPrefix:@"http"]) {
		[theTextField setText:string];
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(textFieldChanged:indexPath:text:)]) {
			[self.delegate textFieldChanged:self indexPath:self.indexPath text:string];
		}
		return NO;
	}
	NSString *message = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
	if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(textFieldChanged:indexPath:text:)]) {
		[self.delegate textFieldChanged:self indexPath:self.indexPath text:message];
	}
	return YES;	
}

@end
