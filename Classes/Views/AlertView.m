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

#import "AlertView.h"

@interface AlertView ()

@property (nonatomic, retain) UIViewController *controller;

@end

@implementation AlertView

@synthesize controller;

- (id) initWithController:(UIViewController *)theController {
	if (self = [super init]) {
		self.controller = theController;
	}
    return self;
}

- (void) showOkWithTitle:(NSString *)title andMessage:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message
												   delegate:self.controller 
										  cancelButtonTitle:NSLocalizedString(@"OK", nil) 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) showYesNoWithTitle:(NSString *)title andMessage:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title 
													message:message
												   delegate:self.controller 
										  cancelButtonTitle:NSLocalizedString(@"No", nil) 
										  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
	[alert show];
	[alert release];
}

- (BOOL) showInfoOnceOnly:(NSString *)info {
	if ([[NSUserDefaults standardUserDefaults] integerForKey:info] == 0) {
		[self showOkWithTitle:nil andMessage:info];
		[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:info];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return YES;
	}
	return NO;
}

@end
