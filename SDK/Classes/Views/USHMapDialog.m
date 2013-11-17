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

#import "USHMapDialog.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "USHDevice.h"

@interface USHMapDialog () 

@property (nonatomic, retain) NSObject<USHMapDialogDelegate>* delegate;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *urlField;

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text 
				   placeholder:(NSString *)placeholder 
				  keyboardType:(UIKeyboardType)keyboardType 
		autocapitalizationType:(UITextAutocapitalizationType) autocapitalizationType
			autocorrectionType:(UITextAutocorrectionType)autocorrectionType;
@end

@implementation USHMapDialog

@synthesize delegate = _delegate;
@synthesize nameField = _nameField;
@synthesize urlField = _urlField;

NSString *const HTTP = @"http://";
NSString *const HTTPS = @"https://";
NSString *const NEWLINE = @"\n";

- (id) initForDelegate:(NSObject<USHMapDialogDelegate>*)delegate {
	if (self = [super init]) {
		self.delegate = delegate;
	}
    return self;
}

- (void)dealloc {
	DLog(@"");
	[_delegate release];
	[_nameField release];
	[_urlField release];
	[super dealloc];
}

- (void) showWithTitle:(NSString *)title name:(NSString *)name url:(NSString *)url {
	DLog(@"title:%@ name:%@ url:%@", title, name, url);
	if ([USHDevice isIOS7]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.nameField = [alertView textFieldAtIndex:0];
        self.nameField.keyboardType = UIKeyboardTypeDefault;
        self.nameField.placeholder = NSLocalizedString(@"Enter name", nil);
        self.nameField.secureTextEntry = NO;
        self.nameField.delegate = self;
        self.nameField.text = name;
        
        self.urlField = [alertView textFieldAtIndex:1];
        self.urlField.keyboardType = UIKeyboardTypeURL;
        self.urlField.placeholder = NSLocalizedString(@"Enter URL", nil);
        self.urlField.secureTextEntry = NO;
        self.urlField.delegate = self;
        self.urlField.text = url;
        
        [alertView setTransform: CGAffineTransformMakeTranslation(0.0, 0.0)];
        [alertView show];
        [alertView release];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:@"\n\n\n"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        self.nameField = [self getTextField:CGRectMake(12.0, 50.0, 260.0, 25.0)
                                       text:name
                                placeholder:NSLocalizedString(@"Enter name", nil)
                               keyboardType:UIKeyboardTypeDefault
                     autocapitalizationType:UITextAutocapitalizationTypeWords
                         autocorrectionType:UITextAutocorrectionTypeYes];
        [alertView addSubview:self.nameField];
        
        self.urlField = [self getTextField:CGRectMake(12.0, 85.0, 260.0, 25.0)
                                      text:url
                               placeholder:NSLocalizedString(@"Enter URL", nil)
                              keyboardType:UIKeyboardTypeURL
                    autocapitalizationType:UITextAutocapitalizationTypeNone
                        autocorrectionType:UITextAutocorrectionTypeNo];
        [alertView addSubview:self.urlField];
        [alertView show];
        [alertView release];
    }
}

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text 
				   placeholder:(NSString *)placeholder 
				  keyboardType:(UIKeyboardType)keyboardType 
		autocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
			autocorrectionType:(UITextAutocorrectionType)autocorrectionType {
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.backgroundColor = [UIColor whiteColor];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeAlways;
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
    DLog(@"%d", buttonIndex);
	if (buttonIndex == alert.cancelButtonIndex) {
        [self.delegate performSelectorOnMainThread:@selector(mapDialogCancelled:)
                                     waitUntilDone:YES
                                       withObjects:self, nil]; 
	}
	else {
        [self.delegate performSelectorOnMainThread:@selector(mapDialogReturned:name:url:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.nameField.text, self.urlField.text, nil];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:NEWLINE]) {
		if ([NSString isNilOrEmpty:self.nameField.text] == NO && [NSString isNilOrEmpty:self.urlField.text] == NO) {
			[textField resignFirstResponder];
			UIAlertView *alertView = (UIAlertView *)[textField superview];
			if (alertView != nil && [alertView isKindOfClass:[UIAlertView class]]) {
				[alertView dismissWithClickedButtonIndex:[alertView firstOtherButtonIndex] animated:YES];
                [self.delegate performSelectorOnMainThread:@selector(mapDialogReturned:name:url:) 
                                             waitUntilDone:YES 
                                               withObjects:self, self.nameField.text, self.urlField.text, nil];
			}			
		}
		else if (textField == self.nameField) {
			[self.urlField becomeFirstResponder];
		}
		else if (textField == self.urlField) {
			[self.nameField becomeFirstResponder];
		}
		return NO;
	}
    if ([string hasPrefix:HTTP] || [string hasPrefix:HTTPS]) {
		if (textField == self.urlField && [textField.text isEqualToString:HTTP]) {
			textField.text = string;
			return NO;
		}
        if (textField == self.urlField && [textField.text isEqualToString:HTTPS]) {
			textField.text = string;
			return NO;
		}
	}
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.urlField && [NSString isNilOrEmpty:textField.text]) {
		textField.text = HTTP;
	}
	return YES;
}   

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if (textField == self.urlField && [textField.text isEqualToString:HTTP]) {
		textField.text = nil;
	}
	return YES;
} 

@end
