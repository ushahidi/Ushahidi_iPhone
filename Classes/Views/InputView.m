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

#import "InputView.h"

#define kButtonCancel						@"Cancel"
#define kButtonReturn						@"OK"

@interface InputView () 

@property (nonatomic, assign) id<InputViewDelegate>	delegate;
@property (nonatomic, retain) NSString *input;

- (void) sendInputCancelled;
- (void) sendInputReturned:(NSString *)input;

@end

@implementation InputView

@synthesize delegate, input;

- (id) initForDelegate:(id<InputViewDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
	}
    return self;
}

- (void) showWithTitle:(NSString *)theTitle placeholder:(NSString *)placeholder {
	DLog(@"title:%@", theTitle);
	UIAlertView *alertView = [[[UIAlertView alloc] init] retain];
	[alertView setDelegate:self];
	[alertView setTitle:theTitle];
	[alertView setMessage:@" "];
	[alertView addButtonWithTitle:kButtonCancel];
	[alertView addButtonWithTitle:kButtonReturn];
	
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 45.0, 245.0, 25.0)];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.placeholder = placeholder;
	textField.adjustsFontSizeToFitWidth = YES;
	textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDone;
	
	[textField setBackgroundColor:[UIColor whiteColor]];
	[alertView addSubview:textField];
	[textField release];
	
	[alertView show];
	[alertView release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	DLog(@"clickedButtonAtIndex:%d", buttonIndex);
	for (UITextField *textField in [alert subviews]) {
		if ([textField isKindOfClass:[UITextField class]]) {
			self.input = textField.text;
			[textField resignFirstResponder];
		}
	}
	if ([[alert buttonTitleAtIndex:buttonIndex] isEqualToString:kButtonCancel]) {
		DLog(@"");
		[self sendInputCancelled];
	}
	else if ([[alert buttonTitleAtIndex:buttonIndex] isEqualToString:kButtonReturn]) {
		DLog(@"");
		[self sendInputReturned:self.input];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	DLog(@"string: %@", string);
	if ([string isEqualToString:@"\n"]) {
		UIAlertView *alertView = (UIAlertView *)[textField superview];
		if (alertView != nil) {
			[textField resignFirstResponder];
			[alertView dismissWithClickedButtonIndex:0 animated:YES];
			[self sendInputReturned:self.input];
		}
		return NO;
	}
	self.input = [textField.text stringByReplacingCharactersInRange:range withString:string];
	return YES;
}

- (void) sendInputReturned:(NSString *)theInput {
	DLog(@"input:%@", theInput);
	SEL selector = @selector(inputReturned:input:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate inputReturned:self input:theInput];
	}
}

- (void) sendInputCancelled {
	DLog(@"");
	SEL selector = @selector(inputCancelled:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate inputCancelled:self];
	}
}

- (void)dealloc {
	DLog(@"");
	[input release];
	[super dealloc];
}

@end
