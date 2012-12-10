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

#import "Email.h"
#import "AlertView.h"
#import "NSObject+Extension.h"
#import "Settings.h"

@interface Email ()

@property (nonatomic, retain) UIViewController *controller;
@property (nonatomic, retain) AlertView *alert;

@end 

@implementation Email

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

- (BOOL) canSend {
	Class messageClass = (NSClassFromString(@"MFMailComposeViewController"));
	return messageClass != nil && [messageClass canSendMail];
}

- (void)sendToRecipients:(NSArray *)recipients withMessage:(NSString *)message withSubject:(NSString *)subject {
	[self sendToRecipients:recipients withMessage:message withSubject:subject withPhotos:nil];
}

- (void)sendToRecipients:(NSArray *)recipients withMessage:(NSString *)message withSubject:(NSString *)subject withPhotos:(NSArray *)photos {
	DLog(@"message:%@ withSubject:%@ photos:%d", message, subject, [photos count]);
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.navigationBar.tintColor = [[Settings sharedSettings] navBarTintColor];
    picker.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    if ([picker.navigationItem.rightBarButtonItem respondsToSelector:@selector(setTintColor:)]) {
        picker.navigationItem.rightBarButtonItem.tintColor = [[Settings sharedSettings] doneButtonColor];
    }
	picker.mailComposeDelegate = self;
	[picker setMessageBody:message isHTML:YES];
	[picker setSubject:subject];
	if (recipients != nil) {
		[picker setToRecipients:recipients];
	}
	if (photos != nil) {
		NSInteger index = 1;
		for(UIImage *image in photos) {
			NSData *imageData = UIImageJPEGRepresentation(image, 1);
			[picker addAttachmentData:imageData 
							 mimeType:@"image/jpg" 
							 fileName:[NSString stringWithFormat:@"photo%d.jpg", index]];
		}
		index++;
	}
    picker.modalPresentationStyle = UIModalPresentationPageSheet;
    picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self.controller presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)theController didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	DLog(@"result:%d", result);
	if (error) {
		[self.alert showOkWithTitle:NSLocalizedString(@"Error", nil) 
						 andMessage:[[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
	}
	else if (result == MFMailComposeResultSent) {
		[self dispatchSelector:@selector(emailSent:) 
						target:self.controller 
					   objects:self, nil];
	}
	else if (result == MFMailComposeResultCancelled) {
		[self dispatchSelector:@selector(emailCancelled:) 
						target:self.controller 
					   objects:self, nil];
	}
	else if (result == MFMailComposeResultFailed) {
		[self dispatchSelector:@selector(emailFailed:) 
						target:self.controller 
					   objects:self, nil];
	}
	[theController dismissModalViewControllerAnimated:YES];
}

@end
