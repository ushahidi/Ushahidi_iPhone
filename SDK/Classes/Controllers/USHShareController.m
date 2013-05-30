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

#import "USHShareController.h"
#import "UIViewController+USH.h"
#import "USHLoadingView.h"
#import "USHDevice.h"
#import "UIAlertView+USH.h"
#import "NSString+USH.h"
#import "NSObject+USH.h"
#import "USHTwitterViewController.h"
#import "USHQrCodeViewController.h"
#import "NSBundle+USH.h"
#import "USHDefaults.h"

@interface USHShareController ()

@property (strong, nonatomic) UIViewController<USHShareControllerDelegate> *controller;
@property (strong, nonatomic) NSString *textShareSMS;
@property (strong, nonatomic) NSString *textShareEmail;
@property (strong, nonatomic) NSString *textCopyClipboard;
@property (strong, nonatomic) NSString *textShareTwitter;
@property (strong, nonatomic) NSString *textPrintDetails;
@property (strong, nonatomic) NSString *textCancelAction;
@property (strong, nonatomic) NSString *textShareFacebook;
@property (strong, nonatomic) NSString *textShareQrCode;
@property (strong, nonatomic) NSString *textOpenIn;
@property (strong, nonatomic) NSString *textOpenUrl;
@property (strong, nonatomic) USHLoadingView *loadingView;
@property (assign, nonatomic) CGRect rect;
@property (strong, nonatomic) USHDefaults *defaults;

@end

@implementation USHShareController

@synthesize controller = _controller;
@synthesize textShareSMS = _textShareSMS;
@synthesize textShareEmail = _textShareEmail;
@synthesize textCopyClipboard = _textCopyClipboard;
@synthesize textShareTwitter = _textShareTwitter;
@synthesize textPrintDetails = _textPrintDetails;
@synthesize textCancelAction = _textCancelAction;
@synthesize textShareFacebook = _textShareFacebook;
@synthesize textShareQrCode = _textShareQrCode;
@synthesize textOpenIn = _textOpenIn;
@synthesize textOpenUrl = _textOpenUrl;
@synthesize loadingView = _loadingView;
@synthesize rect = _rect;
@synthesize navBarColor = _navBarColor;
@synthesize defaults = _defaults;

typedef enum {
    AlertViewError,
    AlertViewWebsite
} AlertView;

#pragma mark - NSObject

- (id) initWithController:(UIViewController<USHShareControllerDelegate>*)controller {
    if (self = [super init]) {
        self.controller = controller;
        self.loadingView = [USHLoadingView viewWithController:controller];
        self.textShareEmail = NSLocalizedString(@"Share via Email", nil);
        self.textShareSMS = NSLocalizedString(@"Share via SMS", nil);
        self.textShareTwitter = NSLocalizedString(@"Share via Twitter", nil);
        self.textShareFacebook = NSLocalizedString(@"Share via Facebook", nil);
        self.textPrintDetails = NSLocalizedString(@"Send to Printer", nil);
        self.textCopyClipboard = NSLocalizedString(@"Copy to Clipboard", nil);
        self.textShareQrCode = NSLocalizedString(@"Share via QRCode", nil);
        self.textOpenUrl = NSLocalizedString(@"Open in Safari", nil);
        self.textOpenIn = NSLocalizedString(@"Open In...", nil);
        self.textCancelAction = NSLocalizedString(@"Cancel", nil);
        self.defaults = [[[USHDefaults alloc] init] autorelease];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"USHViewDidLoad" object:self];
    }
    return self;
}

- (void)dealloc {
    [_controller release];
    [_loadingView release];
    [_textShareTwitter release];
    [_textShareSMS release];
    [_textPrintDetails release];
    [_textCancelAction release];
    [_textCopyClipboard release];
    [_textShareFacebook release];
    [_textOpenIn release];
    [_textOpenUrl release];
    [_textShareQrCode release];
    [_navBarColor release];
    [_defaults release];
    [super dealloc];
}

#pragma mark - UIActionSheetDelegate

- (void) showShareForCell:(UITableViewCell*)cell {
    [self showShareForRect:cell.frame];
}

- (void) showShareForEvent:(UIEvent*)event {
    [self showShareForRect:[self.controller touchForEvent:event]];
}

- (void) showShareForRect:(CGRect)rect {
    self.rect = rect;
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
    if ([self.controller respondsToSelector:@selector(shareOpenIn:)]) {
        DLog(@"shareOpenIn");
        [actionSheet addButtonWithTitle:self.textOpenIn];
    }
    if ([self.controller respondsToSelector:@selector(shareOpenURL:)]) {
        DLog(@"shareOpenURL");
        [actionSheet addButtonWithTitle:self.textOpenUrl];
    }
    if ([self canPrintText] && [self.controller respondsToSelector:@selector(sharePrintText:)]) {
        DLog(@"sharePrintText");
        [actionSheet addButtonWithTitle:self.textPrintDetails];
    }
    if ([self canCopyText] && [self.controller respondsToSelector:@selector(shareCopyText:)]) {
        DLog(@"shareCopyText");
        [actionSheet addButtonWithTitle:self.textCopyClipboard];
    }
    if ([self canSendEmail] && [self.controller respondsToSelector:@selector(shareSendEmail:)]) {
        DLog(@"shareSendEmail");
        [actionSheet addButtonWithTitle:self.textShareEmail];
    }
    if ([self canSendSMS] && [self.controller respondsToSelector:@selector(shareSendSMS:)]) {
        DLog(@"shareSendSMS");
        [actionSheet addButtonWithTitle:self.textShareSMS];
    }
    if ([self.controller respondsToSelector:@selector(shareShowQRCode:)]) {
        DLog(@"shareShowQRCode");
        [actionSheet addButtonWithTitle:self.textShareQrCode];
    }
    if ([self canSendTweet] && [self.controller respondsToSelector:@selector(shareSendTweet:)]) {
        DLog(@"shareSendTweet");
        [actionSheet addButtonWithTitle:self.textShareTwitter];
    }
    if ([self canPostFacebook] && [self.controller respondsToSelector:@selector(sharePostFacebook:)]) {
        DLog(@"sharePostFacebook");
        [actionSheet addButtonWithTitle:self.textShareFacebook];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:self.textCancelAction];
    [actionSheet showFromRect:self.rect inView:self.controller.view animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareSMS]) {
        if ([self.controller respondsToSelector:@selector(shareSendSMS:)]) {
            [self.controller shareSendSMS:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareEmail]) {
        if ([self.controller respondsToSelector:@selector(shareSendEmail:)]) {
            [self.controller shareSendEmail:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareTwitter]) {
        if ([self.controller respondsToSelector:@selector(shareSendTweet:)]) {
            [self.controller shareSendTweet:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textPrintDetails]) {
        if ([self.controller respondsToSelector:@selector(sharePrintText:)]) {
            [self.controller sharePrintText:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textCopyClipboard]) {
        if ([self.controller respondsToSelector:@selector(shareCopyText:)]) {
            [self.controller shareCopyText:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareFacebook]) {
        if ([self.controller respondsToSelector:@selector(sharePostFacebook:)]) {
            [self.controller sharePostFacebook:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textOpenUrl]) {
        if ([self.controller respondsToSelector:@selector(shareOpenURL:)]) {
            [self.controller shareOpenURL:self];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:self.textShareQrCode]) {
        if ([self.controller respondsToSelector:@selector(shareShowQRCode:)]) {
            [self.controller shareShowQRCode:self];
        }
    }
}

#pragma mark - Call Number

- (BOOL) canCallNumber:(NSString*)number {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
    return [[UIApplication sharedApplication] canOpenURL:url];
}


- (void) callNumber:(NSString *)number {
    DLog(@"Number:%@", number);
    if ([self canCallNumber:number]) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Open URL

- (BOOL) canOpenURL:(NSString*)url {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]];
}

- (void) openURL:(NSString *)url {
    DLog(@"URL:%@", url);
    if ([self canOpenURL:url]) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Open in Safari?", nil)
                           message:url
                          delegate:self
                               tag:AlertViewWebsite
                            cancel:NSLocalizedString(@"Cancel", nil)
                           buttons:NSLocalizedString(@"OK", nil), nil];
    }
}

#pragma mark - UIPasteboard

- (BOOL) canCopyText {
    return NSClassFromString(@"UIPasteboard") != nil;
}

- (void) copyText:(NSString *)string {
    DLog(@"Text:%@", string);
    if ([self canCopyText]) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.persistent = YES;
        pasteBoard.string = string;
        [self.loadingView showWithMessage:NSLocalizedString(@"Copied", nil)];
        [self.loadingView hideAfterDelay:2.0];
    }
}

#pragma mark - TWTweetComposeViewController

- (BOOL) canSendTweet {
    return YES;
}

- (void) sendTweet:(NSString*)tweet url:(NSString*)url {
    DLog(@"Tweet:%@ URL:%@", tweet, url);
    [self sendTweet:tweet url:url image:nil];
}

- (void) sendTweet:(NSString*)tweet url:(NSString*)url image:(UIImage*)image {
    DLog(@"Tweet:%@ Image", tweet);
    if ([TWTweetComposeViewController class] != nil && [TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *twitterController = [[TWTweetComposeViewController alloc] init];
        if (tweet != nil) {
            [twitterController setInitialText:tweet];
        }
        if (url != nil) {
            [twitterController addURL:[NSURL URLWithString:url]];
        }
        if (image != nil) {
            [twitterController addImage:image];
        }
        [self.controller presentModalViewController:twitterController animated:YES];
        [twitterController release];
    }
    else {
        NSBundle *bundle = [NSBundle bundleWithName:@"Ushahidi.bundle"];
        NSString *nibName = [USHDevice isIPad] ? @"USHTwitterViewController_iPad" : @"USHTwitterViewController_iPhone";
        USHTwitterViewController *twitterController = [[[USHTwitterViewController alloc] initWithNibName:nibName bundle:bundle] autorelease];
        twitterController.name = tweet;
        twitterController.image = image;
        twitterController.url = url;
        twitterController.modalPresentationStyle = UIModalPresentationFormSheet;
        twitterController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:twitterController animated:YES];
    }
}

#pragma mark - MFMailComposeViewController

- (BOOL) canSendEmail {
    return [MFMailComposeViewController canSendMail];
}

- (void) sendEmail:(NSString*)message subject:(NSString *)subject attachment:(NSData*)attachment fileName:(NSString*)fileName recipient:(NSString*)recipient {
    NSArray *recipients = recipient != nil ? [NSArray arrayWithObject:recipient] : nil;
    [self sendEmail:message subject:subject attachment:attachment fileName:fileName recipients:recipients];
}

- (void) sendEmail:(NSString*)message subject:(NSString *)subject attachment:(NSData*)attachment fileName:(NSString*)fileName recipients:(NSArray*)recipients {
    DLog(@"Message:%@ Subject:%@", message, subject);
    if ([self canSendEmail]) {
        MFMailComposeViewController *mailController = [[[MFMailComposeViewController alloc] init] autorelease];
        mailController.navigationBar.tintColor = self.navBarColor;
        mailController.mailComposeDelegate = self;
        if (subject != nil) {
            [mailController setSubject:subject];
        }
        if (message != nil) {
            [mailController setMessageBody:message isHTML:YES];
        }
        if (recipients != nil) {
            [mailController setToRecipients:recipients];
        }
        if (attachment != nil) {
            NSString *mimeType = @"application/octet-stream";
            [mailController addAttachmentData:attachment mimeType:mimeType fileName:fileName];
        }
        mailController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:mailController animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultSent) {
        DLog(@"MFMailComposeResultSent");
        [self.controller dismissModalViewControllerAnimated:YES];
        [self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil)];
        [self.loadingView hideAfterDelay:2.0];
    }
    else if (result == MFMailComposeResultFailed) {
        DLog(@"MFMailComposeResultFailed");
        [self.controller dismissModalViewControllerAnimated:YES];
        [UIAlertView showWithTitle:NSLocalizedString(@"Email Error", nil)
                           message:[error localizedDescription]
                          delegate:self
                               tag:AlertViewError
                            cancel:NSLocalizedString(@"OK", nil)
                           buttons:nil];
    }
    else if (result == MFMailComposeResultCancelled) {
        DLog(@"MFMailComposeResultCancelled");
        [self.controller dismissModalViewControllerAnimated:YES];
    }
    else {
        [self.controller dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UIPrintInteractionController

- (BOOL) canPrintText {
    return [UIPrintInteractionController isPrintingAvailable];
}

- (void) printData:(NSData*)data title:(NSString*)title {
    if ([self canPrintText]) {
        UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
        if (printController && [UIPrintInteractionController canPrintData:data]) {
            printController.delegate = self;
            UIPrintInfo *printInfo = [UIPrintInfo printInfo];
            printInfo.jobName = title;
            printInfo.outputType = UIPrintInfoOutputGeneral;
            printInfo.duplex = UIPrintInfoDuplexLongEdge;
            printController.printInfo = printInfo;
            printController.showsPageRange = YES;
            printController.printingItem = data;
            void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
            ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
                if (completed && !error) {
                    [self.loadingView showWithMessage:NSLocalizedString(@"Printed", nil)];
                    [self.loadingView hideAfterDelay:2.0];
                }
                else if (!completed && error) {
                    DLog(@"Error:%@ Domain:%@ Code:%u", error, error.domain, error.code);
                    [UIAlertView showWithTitle:NSLocalizedString(@"Print Error", nil)
                                       message:[error localizedDescription]
                                      delegate:self
                                           tag:AlertViewError
                                        cancel:NSLocalizedString(@"OK", nil)
                                       buttons:nil];
                }
            };
            if ([USHDevice isIPad]) {
                [printController presentFromRect:self.rect inView:self.controller.view animated:YES completionHandler:completionHandler];
            }
            else {
                [printController presentAnimated:YES completionHandler:completionHandler];
            }
        }
    }
}

- (void) printText:(NSString*)text title:(NSString*)title {
    DLog(@"Text:%@ Title:%@", text, title);
    if (text != nil) {
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        [self printData:data title:title];
    }
}

#pragma mark - UIDocumentInteractionController

- (BOOL) canOpenIn:(NSString *)url {
    if (url != nil) {
        return [self canOpenInWithUrl:[NSURL URLWithString:url]];
    }
    return NO;
}

- (BOOL) canOpenInWithUrl:(NSURL *)url {
    BOOL canOpen = NO;
    if (url != nil) {
        UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        if (docController) {
            docController.delegate = self;
            canOpen = [docController presentOpenInMenuFromRect:CGRectZero inView:self.controller.view animated:NO];
            [docController dismissMenuAnimated:NO];
        }
    }
    return canOpen;
}

- (void) showOpenInWithUrl:(NSString*)url {
    if (url != nil) {
        UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL URLWithString:url]];
        docController.delegate = self;
        [docController presentOpenInMenuFromRect:self.rect inView:self.controller.view animated:YES];
        [docController retain];
    }
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
    DLog(@"");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
    DLog(@"");
}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    DLog(@"");
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    [controller autorelease];
}

#pragma mark - MFMessageComposeViewController

- (BOOL) canSendSMS {
    return [MFMessageComposeViewController canSendText];
}

- (void) sendSMS:(NSString *)message {
    [self sendSMS:message recipients:nil];
}

- (void) sendSMS:(NSString *)message recipient:(NSString*)recipient {
    if ([NSString isNilOrEmpty:recipient] == NO) {
        [self sendSMS:message recipients:[NSArray arrayWithObject:recipient]];
    }
    else {
        [self sendSMS:message recipients:nil];
    }
}

- (void) sendSMS:(NSString *)message recipients:(NSArray*)recipients {
    DLog(@"Message:%@ Recipients:%@", message, recipients);
    if ([self canSendSMS]) {
        MFMessageComposeViewController *smsController = [[[MFMessageComposeViewController alloc] init] autorelease];
        smsController.navigationBar.tintColor = self.navBarColor;
        smsController.messageComposeDelegate = self;
        if (message != nil) {
            smsController.body = message;
        }
        if (recipients != nil) {
            smsController.recipients = recipients;
        }
        smsController.modalPresentationStyle = UIModalPresentationFormSheet;
        smsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self.controller presentModalViewController:smsController animated:YES];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultSent) {
        DLog(@"MessageComposeResultSent");
        [self.controller dismissModalViewControllerAnimated:YES];
        [self.loadingView showWithMessage:NSLocalizedString(@"Sent", nil) hide:2.0];
        [self.controller performSelector:@selector(sendSMSWasSent:) withObjects:self, nil];
    }
    else if (result == MessageComposeResultFailed) {
        DLog(@"MessageComposeResultFailed");
        [self.controller dismissModalViewControllerAnimated:YES];
        [UIAlertView showWithTitle:NSLocalizedString(@"SMS Error", nil)
                           message:NSLocalizedString(@"There was a problem sending SMS message.", nil)
                          delegate:self
                               tag:AlertViewError
                            cancel:NSLocalizedString(@"OK", nil)
                           buttons:nil];
        [self.controller performSelector:@selector(sendSMSWasFailed:) withObjects:self, nil];
    }
    else if (result == MessageComposeResultCancelled) {
        DLog(@"MessageComposeResultCancelled");
        [self.controller dismissModalViewControllerAnimated:YES];
        [self.controller performSelector:@selector(sendSMSWasCancelled:) withObjects:self, nil];
    }
    else {
        [self.controller dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - USHQrCodeViewController

- (void) showQRCode:(NSString*)text title:(NSString*)title {
    NSBundle *bundle = [NSBundle bundleWithName:@"Ushahidi.bundle"];
    NSString *nibName = [USHDevice isIPad] ? @"USHQrCodeViewController_iPad" : @"USHQrCodeViewController_iPhone";
    USHQrCodeViewController *qrCodeViewController = [[[USHQrCodeViewController alloc] initWithNibName:nibName bundle:bundle] autorelease];
    qrCodeViewController.title = title;
    qrCodeViewController.text = text;
    qrCodeViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    qrCodeViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.controller presentModalViewController:qrCodeViewController animated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewWebsite) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alertView.message]];
        }
    }
}

#pragma mark - FBLoginViewDelegate

- (BOOL) canPostFacebook {
    return [FBSession class] != nil && [FBNativeDialogs class] != nil && [NSString isNilOrEmpty:self.defaults.facebookAppID] == NO;
}

- (void) postFacebook:(NSString*)text url:(NSString*)url {
    [self postFacebook:text url:url image:nil];
}

- (void) postFacebook:(NSString*)text url:(NSString*)url image:(UIImage *)image {
    if (FBSession.activeSession.isOpen == NO) {
        [FBSession openActiveSessionWithReadPermissions:nil
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          if (error) {
                                              [UIAlertView showWithTitle:NSLocalizedString(@"Facebook Error", nil)
                                                                 message:error.localizedDescription
                                                                delegate:self
                                                                     tag:AlertViewError
                                                                  cancel:NSLocalizedString(@"OK", nil)
                                                                 buttons:nil];
                                          }
                                          else if (state == FBSessionStateOpen) {
                                              [self postFacebook:text url:url image:image];
                                          }
                                          else if (state == FBSessionStateClosed) {
                                              [FBSession.activeSession closeAndClearTokenInformation];
                                          }
                                          else if (state == FBSessionStateClosedLoginFailed) {
                                              [FBSession.activeSession closeAndClearTokenInformation];
                                          }
                                      }];
    }
    else if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (error) {
                                                         [UIAlertView showWithTitle:NSLocalizedString(@"Facebook Error", nil)
                                                                            message:error.localizedDescription
                                                                           delegate:self
                                                                                tag:AlertViewError
                                                                             cancel:NSLocalizedString(@"OK", nil)
                                                                            buttons:nil];
                                                     }
                                                     else {
                                                         [self postFacebook:text url:url image:image];
                                                     }
                                                 }];
    }
    else {
        BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self.controller
                                                                        initialText:text
                                                                              image:image
                                                                                url:url != nil ? [NSURL URLWithString:url] : nil
                                                                            handler:^(FBNativeDialogResult result, NSError *error) {
                                                                                if (error) {
                                                                                    [UIAlertView showWithTitle:NSLocalizedString(@"Facebook Error", nil)
                                                                                                       message:error.localizedDescription
                                                                                                      delegate:self
                                                                                                           tag:AlertViewError
                                                                                                        cancel:NSLocalizedString(@"OK", nil)
                                                                                                       buttons:nil];
                                                                                }
                                                                                else if (result == FBNativeDialogResultError){
                                                                                    [UIAlertView showWithTitle:NSLocalizedString(@"Facebook Error", nil)
                                                                                                       message:NSLocalizedString(@"Unable to post to Facebook", nil)
                                                                                                      delegate:self
                                                                                                           tag:AlertViewError
                                                                                                        cancel:NSLocalizedString(@"OK", nil)
                                                                                                       buttons:nil];
                                                                                }
                                                                                else if (result == FBNativeDialogResultSucceeded){
                                                                                    [self.loadingView showWithMessage:NSLocalizedString(@"Posted", nil) hide:2.0];
                                                                                }
                                                                            }];
        if (!displayedNativeDialog) {
            [self.loadingView showWithMessage:NSLocalizedString(@"Posting...", nil)];
            [FBRequestConnection startForUploadPhoto:image
                                   completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                       if (error) {
                                           [self.loadingView hide];
                                           [UIAlertView showWithTitle:NSLocalizedString(@"Facebook Error", nil)
                                                              message:error.localizedDescription
                                                             delegate:self
                                                                  tag:AlertViewError
                                                               cancel:NSLocalizedString(@"OK", nil)
                                                              buttons:nil];
                                       }
                                       else {
                                           NSDictionary *dictionary = (NSDictionary *)result;
                                           DLog(@"Result:%@", dictionary);
                                           [self.loadingView showWithMessage:NSLocalizedString(@"Posted", nil) hide:2.0];
                                       }
                                   }];
        }
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [self.loadingView showWithMessage:NSLocalizedString(@"Logged in", nil) hide:2.0];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    [self.loadingView showWithMessage:NSLocalizedString(@"Logged out", nil) hide:2.0];
}


@end
