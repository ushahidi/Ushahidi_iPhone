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

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@class AlertView;

@interface SMS : NSObject<MFMessageComposeViewControllerDelegate> {

@private
	UIViewController *controller;
	AlertView *alert;
}

- (id) initWithController:(UIViewController *)controller;
- (void) sendToRecipients:(NSArray *)recipients withMessage:(NSString *)message;
- (BOOL) canSend;

@end

@protocol SMSDelegate <NSObject>

@optional

- (void) smsSent:(SMS *)sms;
- (void) smsCancelled:(SMS *)sms;
- (void) smsFailed:(SMS *)sms;

@end