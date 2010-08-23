//
//  TextFieldTableCell.m
//  Ushahidi
//
//  Created by Dale Zak on 10-05-20.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import "TextFieldTableCell.h"

@interface TextFieldTableCell ()

@property (nonatomic, assign) id<TextFieldTableCellDelegate> delegate;

@end


@implementation TextFieldTableCell

@synthesize delegate, textField, indexPath;

- (id)initWithDelegate:(id<TextFieldTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textField = [[UITextField alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.textField.delegate = self;
		self.textField.adjustsFontSizeToFitWidth = YES;
		self.textField.textAlignment = UITextAlignmentCenter;
		self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.textField.borderStyle = UITextBorderStyleNone;
		self.textField.font = [UIFont boldSystemFontOfSize:18];
		self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		self.textField.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.textField.backgroundColor = self.contentView.backgroundColor;
		[self.contentView addSubview:self.textField];
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[textField release];
	[indexPath release];
    [super dealloc];
}

- (void) showKeyboard {
	[self.textField becomeFirstResponder];
}

- (void) hideKeyboard {
	[self.textField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)theTextField {
	[theTextField becomeFirstResponder];
	SEL selector = @selector(textFieldFocussed:indexPath:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate textFieldFocussed:self indexPath:self.indexPath];
	}
}
 
- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	SEL selector = @selector(textFieldReturned:indexPath:text:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate textFieldReturned:self indexPath:self.indexPath text:theTextField.text];
	}
}
 
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	SEL selector = @selector(textFieldReturned:indexPath:text:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate textFieldReturned:self indexPath:self.indexPath text:theTextField.text];
	}
	return YES;
}
 
- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:@"\n"]) {
		[theTextField resignFirstResponder];
		return YES;
	}
	NSString *message = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
	SEL selector = @selector(textFieldChanged:indexPath:text:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate textFieldChanged:self indexPath:self.indexPath text:message];
	}
	return YES;	
}

- (void) setPlaceholder:(NSString *)placeholder {
	self.textField.placeholder = placeholder;
}

- (void) setIsPassword:(BOOL)isPassword {
	self.textField.secureTextEntry = isPassword;
}

- (void) setMessage:(NSString *)message {
	self.textField.text = message;
}

- (NSString *) getMessage {
	return self.textField.text;
}

@end
