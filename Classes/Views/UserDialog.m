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

#import "UserDialog.h"
#import "NSObject+Extension.h"
#import "NSString+Extension.h"

@interface UserDialog () 

@property (nonatomic, assign) id<UserDialogDelegate> delegate;
@property (nonatomic, retain) UITextField *firstField;
@property (nonatomic, retain) UITextField *lastField;
@property (nonatomic, retain) UITextField *emailField;

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text 
				   placeholder:(NSString *)placeholder 
				  keyboardType:(UIKeyboardType)keyboardType 
		autocapitalizationType:(UITextAutocapitalizationType) autocapitalizationType
			autocorrectionType:(UITextAutocorrectionType)autocorrectionType;
@end

@implementation UserDialog

@synthesize delegate, firstField, lastField, emailField;

- (id) initForDelegate:(id<UserDialogDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
	}
    return self;
}

- (void)dealloc {
	DLog(@"");
	delegate = nil;
	[firstField release];
	[lastField release];
	[emailField release];
	[super dealloc];
}

- (void) showWithTitle:(NSString *)theTitle first:(NSString *)theFirst last:(NSString *)theLast email:(NSString *)theEmail {
	DLog(@"title:%@ first:%@ last:%@ emai:%@", theTitle, theFirst, theLast, theEmail);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:theTitle 
														message:@"\n\n\n\n\n" 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	
	self.firstField = [self getTextField:CGRectMake(12.0, 50.0, 260.0, 25.0)
								   text:theFirst 
							placeholder:NSLocalizedString(@"Enter first name", nil) 
						   keyboardType:UIKeyboardTypeDefault
				 autocapitalizationType:UITextAutocapitalizationTypeWords
					 autocorrectionType:UITextAutocorrectionTypeNo];
	[alertView addSubview:self.firstField];
	
	self.lastField = [self getTextField:CGRectMake(12.0, 85.0, 260.0, 25.0)
								  text:theLast 
						   placeholder:NSLocalizedString(@"Enter last name", nil) 
						  keyboardType:UIKeyboardTypeDefault
				autocapitalizationType:UITextAutocapitalizationTypeWords
					autocorrectionType:UITextAutocorrectionTypeNo];
	[alertView addSubview:self.lastField];
	
	self.emailField = [self getTextField:CGRectMake(12.0, 120.0, 260.0, 25.0)
								   text:theEmail 
							placeholder:NSLocalizedString(@"Enter email", nil) 
						   keyboardType:UIKeyboardTypeEmailAddress
				 autocapitalizationType:UITextAutocapitalizationTypeNone
					 autocorrectionType:UITextAutocorrectionTypeNo];
	[alertView addSubview:self.emailField];
	
	[alertView show];
	[alertView release];
}

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text 
				   placeholder:(NSString *)placeholder 
				  keyboardType:(UIKeyboardType)keyboardType 
		autocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
			autocorrectionType:(UITextAutocorrectionType)autocorrectionType {
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.backgroundColor = [UIColor whiteColor];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.adjustsFontSizeToFitWidth = YES;
	textField.autocapitalizationType = autocapitalizationType;
	textField.autocorrectionType = autocorrectionType;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDone;
	textField.text = text;
	textField.placeholder = placeholder;
	return [textField autorelease];
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alert.cancelButtonIndex) {
		[self dispatchSelector:@selector(userDialogCancelled:) 
						target:self.delegate 
					   objects:self, nil];
	}
	else {
		[self dispatchSelector:@selector(userDialogReturned:first:last:email:) 
						target:self.delegate 
					   objects:self, self.firstField.text, self.lastField.text, self.emailField.text, nil];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:@"\n"]) {
		if ([NSString isNilOrEmpty:self.firstField.text] == NO && 
			[NSString isNilOrEmpty:self.lastField.text] == NO &&
			[NSString isNilOrEmpty:self.emailField.text] == NO) {
			[textField resignFirstResponder];
			UIAlertView *alertView = (UIAlertView *)[textField superview];
			if (alertView != nil && [alertView isKindOfClass:[UIAlertView class]]) {
				[alertView dismissWithClickedButtonIndex:[alertView firstOtherButtonIndex] animated:YES];
				[self dispatchSelector:@selector(userDialogReturned:first:last:email:) 
								target:self.delegate 
							   objects:self, self.firstField.text, self.lastField.text, self.emailField.text, nil];
			}			
		}
		else if (textField == self.firstField) {
			[self.firstField becomeFirstResponder];
		}
		else if (textField == self.lastField) {
			[self.lastField becomeFirstResponder];
		}
		else if (textField == self.emailField) {
			[self.emailField becomeFirstResponder];
		}
		return NO;
	}
	return YES;
}

@end
