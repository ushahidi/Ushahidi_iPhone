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

#import "TextViewTableCell.h"

@interface TextViewTableCell ()

@property (nonatomic, assign) id<TextViewTableCellDelegate>	delegate;
@property (nonatomic, retain) NSString *placeholder_;
@property (nonatomic, retain) UITextView *textView;

@end


@implementation TextViewTableCell

@synthesize delegate, textView, limit, placeholder_;

- (id)initForDelegate:(id<TextViewTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textView = [[UITextView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.textView.delegate = self;
		self.textView.textAlignment = UITextAlignmentLeft;
		self.textView.contentInset = UIEdgeInsetsMake(-4, -8, 0, 0);
		self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
		self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
		self.textView.keyboardType = UIKeyboardTypeDefault;
		self.textView.returnKeyType = UIReturnKeyDefault;
		self.textView.userInteractionEnabled = YES;
		self.textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
		self.textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
		self.textView.font = [UIFont systemFontOfSize:16];
		self.textView.backgroundColor = self.contentView.backgroundColor;
		[self.contentView addSubview:self.textView];
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[textView release];
	[placeholder_ release];
    [super dealloc];
}

- (UIReturnKeyType) returnKeyType {
	return self.textView.returnKeyType;
}

- (void) setReturnKeyType:(UIReturnKeyType)returnKeyType {
	self.textView.returnKeyType = returnKeyType;
}

- (UIKeyboardType) keyboardType {
	return self.textView.keyboardType;
}

- (void) setKeyboardType:(UIKeyboardType)keyboardType {
	self.textView.keyboardType = keyboardType;
}

- (UITextAutocorrectionType) autocorrectionType {
	return self.textView.autocorrectionType;
}

- (void) setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType {
	self.textView.autocorrectionType = autocorrectionType;
}

- (UITextAutocapitalizationType) autocapitalizationType {
	return self.textView.autocapitalizationType;
}

- (void) setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType {
	self.textView.autocapitalizationType = autocapitalizationType;
}

- (void) showKeyboard {
	[self.textView becomeFirstResponder];
}

- (void) hideKeyboard {
	if ([self.textView.text isEqualToString:@""]) {
		self.textView.text = self.placeholder_;
		self.textView.textColor = [UIColor lightGrayColor];
	}
	[self.textView resignFirstResponder];
}

- (void) setPlaceholder:(NSString *)placeholder {
	self.placeholder_ = placeholder;
	self.textView.text = placeholder;
	self.textView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)theTextView {
	if ([self.textView.text isEqualToString:self.placeholder_]) {
		self.textView.text = @"";
		self.textView.textColor = [UIColor blackColor];
	}
	[theTextView becomeFirstResponder];
	SEL selector = @selector(textViewFocussed:indexPath:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate textViewFocussed:self indexPath:self.indexPath];
	}
}

- (void)textViewDidEndEditing:(UITextView *)theTextView {
	DLog(@"");
	if ([self.textView.text isEqualToString:@""]) {
		self.textView.text = self.placeholder_;
		self.textView.textColor = [UIColor lightGrayColor];
	}
}

- (BOOL)textView:(UITextView *)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
	if ([string isEqualToString:@"\n"]) {
		SEL selector = @selector(textViewReturned:indexPath:text:);
		if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
			[self.delegate textViewReturned:self indexPath:self.indexPath text:theTextView.text];
		}
		return NO;
	}
	NSString *message = [theTextView.text stringByReplacingCharactersInRange:range withString:string];
	if (self.limit == 0 || self.limit >= [message length]) {
		SEL selector = @selector(textViewChanged:indexPath:text:);
		if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
			[self.delegate textViewChanged:self indexPath:self.indexPath text:message];
		}
		return YES;		
	}
	else {
		return NO;
	}
}

- (void)textViewDidChange:(UITextView *)theTextView {
	SEL selector = @selector(textViewChanged:indexPath:text:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate textViewChanged:self indexPath:self.indexPath text:theTextView.text];
	}
}

- (void) setText:(NSString *)theText {
	if (theText != nil && [theText length] > 0) {
		self.textView.text = theText;
		self.textView.textColor = [UIColor blackColor];
	}
	else {
		self.textView.text = self.placeholder_;
		self.textView.textColor = [UIColor lightGrayColor];
	}
}

- (NSString *) getText {
	if ([self.textView.text isEqualToString:self.placeholder_] == NO) {
		return self.textView.text;
	} 
	return nil;
}

@end
