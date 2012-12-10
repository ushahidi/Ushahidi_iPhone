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

#import "USHLoginDialog.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"

@interface USHLoginDialog () 

@property (nonatomic, retain) NSObject<USHLoginDialogDelegate>* delegate;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text 
				   placeholder:(NSString *)placeholder 
				  keyboardType:(UIKeyboardType)keyboardType 
                 returnKeyType:(UIReturnKeyType)returnKeyType
		autocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
			autocorrectionType:(UITextAutocorrectionType)autocorrectionType;
@end

@implementation USHLoginDialog

@synthesize delegate = _delegate;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

- (id) initForDelegate:(NSObject<USHLoginDialogDelegate>*)delegate {
	if (self = [super init]) {
		self.delegate = delegate;
	}
    return self;
}

- (void)dealloc {
	DLog(@"");
	[_delegate release];
	[_usernameField release];
	[_passwordField release];
	[super dealloc];
}

- (void) showWithTitle:(NSString *)title username:(NSString *)username password:(NSString *)password {
	DLog(@"title:%@ username:%@ password:%@", title, username, password);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title 
														message:@"\n\n\n" 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											  otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
	
	self.usernameField = [self getTextField:CGRectMake(12.0, 50.0, 260.0, 25.0)
                                       text:username 
                                placeholder:NSLocalizedString(@"Enter username", nil) 
                               keyboardType:UIKeyboardTypeDefault
                              returnKeyType:UIReturnKeyNext
                     autocapitalizationType:UITextAutocapitalizationTypeNone
                         autocorrectionType:UITextAutocorrectionTypeNo];
	[alertView addSubview:self.usernameField];
	
	self.passwordField = [self getTextField:CGRectMake(12.0, 85.0, 260.0, 25.0)
                                       text:password 
                                placeholder:NSLocalizedString(@"Enter password", nil) 
                               keyboardType:UIKeyboardTypeDefault
                              returnKeyType:UIReturnKeyNext
                     autocapitalizationType:UITextAutocapitalizationTypeNone
                         autocorrectionType:UITextAutocorrectionTypeNo];
    self.passwordField.secureTextEntry = YES;
	[alertView addSubview:self.passwordField];
	
	[alertView show];
	[alertView release];
}

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text 
				   placeholder:(NSString *)placeholder 
				  keyboardType:(UIKeyboardType)keyboardType 
                 returnKeyType:(UIReturnKeyType)returnKeyType
		autocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
			autocorrectionType:(UITextAutocorrectionType)autocorrectionType {
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.backgroundColor = [UIColor whiteColor];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeAlways;
	textField.adjustsFontSizeToFitWidth = YES;
	textField.autocapitalizationType = autocapitalizationType;
	textField.autocorrectionType = autocorrectionType;
	textField.keyboardType = keyboardType;
	textField.returnKeyType = returnKeyType;
	textField.text = text;
	textField.placeholder = placeholder;
	return [textField autorelease];
}

#pragma mark - UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    DLog(@"%d", buttonIndex);
	if (buttonIndex == alert.cancelButtonIndex) {
        [self.delegate performSelectorOnMainThread:@selector(loginDialogCancelled:)
                                     waitUntilDone:YES
                                       withObjects:self, nil]; 
	}
	else {
        [self.delegate performSelectorOnMainThread:@selector(loginDialogReturned:username:password:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.usernameField.text, self.passwordField.text, nil];
	}
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        if (textField == self.usernameField) {
            if ([NSString isNilOrEmpty:self.passwordField.text]) {
                [self.passwordField becomeFirstResponder];    
            }
            else {
                [self.usernameField resignFirstResponder];
            }
        }
        else if (textField == self.passwordField) {
            if ([NSString isNilOrEmpty:self.usernameField.text]) {
                [self.usernameField becomeFirstResponder];    
            }
            else {
                [self.passwordField resignFirstResponder];
            }
        }
        return NO;
    }
	return YES;
}

@end
