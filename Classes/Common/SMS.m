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

#import "SMS.h"
#import "AlertView.h"

@interface SMS ()

@property (nonatomic, retain) UIViewController *controller;
@property (nonatomic, retain) AlertView *alert;

@end

@implementation SMS

@synthesize controller, alert;

- (id) initWithController:(UIViewController *)theController {
	if (self = [super init]) {
		self.controller = theController;
		self.alert = [[AlertView alloc] initWithController:theController];
	}
    return self;
}

- (void)dealloc {
	[controller release];
	[alert release];
	[super dealloc];
}

- (void)sendToRecipients:(NSArray *)recipients withMessage:(NSString *)message {
	if ([MFMessageComposeViewController canSendText]) {
		MFMessageComposeViewController *composeViewcontroller = [[[MFMessageComposeViewController alloc] init] autorelease];
		composeViewcontroller.body = message;
		if (recipients != nil) {
			composeViewcontroller.recipients = recipients;
		}
		composeViewcontroller.messageComposeDelegate = self;
		[self.controller presentModalViewController:composeViewcontroller animated:YES];
	}
}

- (BOOL) canSend {
	return [MFMessageComposeViewController canSendText];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)composeViewcontroller didFinishWithResult:(MessageComposeResult)result {
	if (result == MessageComposeResultCancelled) {
		DLog(@"MessageComposeResultCancelled");
	}
	else if (result == MessageComposeResultSent) {
		DLog(@"MessageComposeResultSent");
	}
	else if (result == MessageComposeResultFailed) {
		DLog(@"MessageComposeResultFailed");
		[self.alert showOkWithTitle:NSLocalizedString(@"Send Error", nil) andMessage:NSLocalizedString(@"Unable To Send Message", nil)];
	}
	[composeViewcontroller dismissModalViewControllerAnimated:YES];
}

@end
