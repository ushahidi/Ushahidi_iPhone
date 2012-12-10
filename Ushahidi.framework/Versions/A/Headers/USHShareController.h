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

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol USHShareControllerDelegate;

@interface USHShareController : NSObject<UIAlertViewDelegate,
                                         UIActionSheetDelegate,
                                         UIPrintInteractionControllerDelegate,
                                         UIDocumentInteractionControllerDelegate,
                                         MFMailComposeViewControllerDelegate,
                                         MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) UIColor *navBarColor;

- (id) initWithController:(UIViewController<USHShareControllerDelegate>*)controller;

- (void) showShareForRect:(CGRect)rect;
- (void) showShareForEvent:(UIEvent*)event;
- (void) showShareForCell:(UITableViewCell*)cell;

- (BOOL) canCallNumber:(NSString*)number;
- (void) callNumber:(NSString *)number;

- (BOOL) canPrintText;
- (void) printData:(NSData*)data title:(NSString*)title;
- (void) printText:(NSString*)text title:(NSString*)title;

- (BOOL) canCopyText;
- (void) copyText:(NSString *)string;

- (BOOL) canSendSMS;
- (void) sendSMS:(NSString *)message;
- (void) sendSMS:(NSString *)message recipient:(NSString*)recipient;
- (void) sendSMS:(NSString *)message recipients:(NSArray*)recipients;

- (BOOL) canSendEmail;
- (void) sendEmail:(NSString*)message subject:(NSString *)subject attachment:(NSData*)attachment fileName:(NSString*)fileName recipient:(NSString*)recipient;
- (void) sendEmail:(NSString*)message subject:(NSString *)subject attachment:(NSData*)attachment fileName:(NSString*)fileName recipients:(NSArray*)recipients;

- (BOOL) canSendTweet;
- (void) sendTweet:(NSString*)tweet url:(NSString*)url;
- (void) sendTweet:(NSString*)tweet url:(NSString*)url image:(UIImage*)image;

- (BOOL) canOpenURL:(NSString*)url;
- (void) openURL:(NSString *)url;

- (BOOL) canOpenIn:(NSString *)url;
- (BOOL) canOpenInWithUrl:(NSURL *)url;
- (void) showOpenInWithUrl:(NSString*)url;

- (BOOL) canPostFacebook;
- (void) postFacebook:(NSString*)text url:(NSString*)url;
- (void) postFacebook:(NSString*)text url:(NSString*)url image:(UIImage*)image;

- (void) showQRCode:(NSString*)text title:(NSString*)title;

@end

@protocol USHShareControllerDelegate <NSObject>

@optional

- (void) shareOpenIn:(USHShareController*)share;
- (void) shareOpenURL:(USHShareController*)share;
- (void) sharePrintText:(USHShareController*)share;
- (void) shareCopyText:(USHShareController*)share;
- (void) shareSendSMS:(USHShareController*)share;
- (void) shareSendEmail:(USHShareController*)share;
- (void) shareSendTweet:(USHShareController*)share;
- (void) sharePostFacebook:(USHShareController*)share;
- (void) shareShowQRCode:(USHShareController*)share;

- (void) sendSMSWasSent:(USHShareController*)share;
- (void) sendSMSWasCancelled:(USHShareController*)share;
- (void) sendSMSWasFailed:(USHShareController*)share;

@end