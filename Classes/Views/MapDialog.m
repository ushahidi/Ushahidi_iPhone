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

#import "MapDialog.h"
#import "NSObject+Extension.h"

@interface MapDialog () 

@property (nonatomic, assign) id<MapDialogDelegate>	delegate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *urlField;

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType;

@end

@implementation MapDialog

@synthesize delegate, name, url, nameField, urlField;

- (id) initForDelegate:(id<MapDialogDelegate>)theDelegate {
	if (self = [super init]) {
		self.delegate = theDelegate;
	}
    return self;
}

- (void) showWithTitle:(NSString *)theTitle name:(NSString *)theName url:(NSString *)theUrl {
	DLog(@"title:%@ name:%@ url:%@", theTitle, theName, theUrl);
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:theTitle 
														message:@"\n\n\n" 
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", nil) 
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	
	self.nameField = [self getTextField:CGRectMake(12.0, 50.0, 260.0, 25.0)
								   text:theName 
							placeholder:NSLocalizedString(@"Enter name", nil) 
						   keyboardType:UIKeyboardTypeDefault];
	[alertView addSubview:self.nameField];
	
	self.urlField = [self getTextField:CGRectMake(12.0, 85.0, 260.0, 25.0)
								  text:theUrl 
						   placeholder:NSLocalizedString(@"Enter url", nil) 
						  keyboardType:UIKeyboardTypeURL];
	[alertView addSubview:self.urlField];
	
	[alertView show];
	[alertView release];
}

- (UITextField *) getTextField:(CGRect)frame text:(NSString *)text placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType {
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
	textField.backgroundColor = [UIColor whiteColor];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.adjustsFontSizeToFitWidth = YES;
	textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	textField.autocorrectionType = UITextAutocorrectionTypeYes;
	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDone;
	textField.text = text;
	textField.placeholder = placeholder;
	return [textField autorelease];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alert.cancelButtonIndex) {
		[self dispatchSelector:@selector(mapDialogCancelled:) 
						target:self.delegate 
					   objects:self, nil];
	}
	else {
		[self dispatchSelector:@selector(mapDialogReturned:name:url:) 
						target:self.delegate 
					   objects:self, self.name, self.url, nil];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:@"\n"]) {
		[textField resignFirstResponder];
		return NO;
	}
	else if (textField == self.nameField) {
		self.name = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}
	else if (textField == self.urlField) {
		self.url = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}
	return YES;
}

- (void)dealloc {
	DLog(@"");
	delegate = nil;
	[name release];
	[url release];
	[nameField release];
	[urlField release];
	[super dealloc];
}

@end

