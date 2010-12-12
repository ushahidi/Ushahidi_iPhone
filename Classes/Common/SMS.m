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
#import "NSObject+Extension.h"

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

- (void) dealloc {
	[controller release];
	[alert release];
	[super dealloc];
}

- (void) sendToRecipients:(NSArray *)recipients withMessage:(NSString *)message {
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
	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	return messageClass != nil && [messageClass canSendText];
}

- (void) messageComposeViewController:(MFMessageComposeViewController *)composeViewcontroller didFinishWithResult:(MessageComposeResult)result {
	if (result == MessageComposeResultCancelled) {
		DLog(@"MessageComposeResultCancelled");
		[self dispatchSelector:@selector(smsCancelled:) 
						target:self.controller 
					   objects:self, nil];
	}
	else if (result == MessageComposeResultSent) {
		DLog(@"MessageComposeResultSent");
		[self dispatchSelector:@selector(smsSent:) 
						target:self.controller 
					   objects:self, nil];
	}
	else if (result == MessageComposeResultFailed) {
		DLog(@"MessageComposeResultFailed");
		[self dispatchSelector:@selector(smsFailed:) 
						target:self.controller 
					   objects:self, nil];
	}
	[composeViewcontroller dismissModalViewControllerAnimated:YES];
}

@end
