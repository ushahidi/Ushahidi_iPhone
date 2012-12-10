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

#import "UIActionSheet+USH.h"
#import "UIEvent+USH.h"
#import "USHDevice.h"

@implementation UIActionSheet (USH)

+ (UIActionSheet*) showWithTitle:(NSString *)title
                        delegate:(UIViewController<UIActionSheetDelegate>*)delegate
                           event:(UIEvent*)event
                          cancel:(NSString *)cancel
                         buttons:(NSString *)buttons, ... {
    va_list args;
    va_start(args, buttons);
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title 
                                                              delegate:delegate
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
    
    for (NSString *arg = buttons; arg != nil; arg = va_arg(args, NSString*)){
        [actionSheet addButtonWithTitle:arg];
    }
    if (cancel != nil) {
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancel];
    }
    va_end(args);
    if ([USHDevice isIPad] && [USHDevice isPortraitMode]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [delegate.view convertRect:[event getRectForView:delegate.view] toView:window];
        [actionSheet showFromRect:rect inView:window animated:YES];
    }
    else {
        CGRect rect = [event getRectForView:delegate.view];
        [actionSheet showFromRect:rect inView:delegate.view animated:YES];
    }
    return actionSheet;
}

+ (UIActionSheet*) showWithTitle:(NSString *)title
                        delegate:(UIViewController<UIActionSheetDelegate>*)delegate
                           event:(UIEvent*)event
                             tag:(NSInteger)tag
                          cancel:(NSString *)cancel
                         buttons:(NSString *)buttons, ... {
    va_list args;
    va_start(args, buttons);
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title 
                                                              delegate:delegate
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
    
    for (NSString *arg = buttons; arg != nil; arg = va_arg(args, NSString*)){
        [actionSheet addButtonWithTitle:arg];
    }
    if (cancel != nil) {
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancel];
    }
    va_end(args);
    actionSheet.tag = tag;
    if ([USHDevice isIPad] && [USHDevice isPortraitMode]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [delegate.view convertRect:[event getRectForView:delegate.view] toView:window];
        [actionSheet showFromRect:rect inView:window animated:YES];
    }
    else {
        CGRect rect = [event getRectForView:delegate.view];
        [actionSheet showFromRect:rect inView:delegate.view animated:YES];
    }
    return actionSheet;
}

+ (UIActionSheet*) showWithTitle:(NSString *)title
                        delegate:(UIViewController<UIActionSheetDelegate>*)delegate
                           event:(UIEvent*)event
                             tag:(NSInteger)tag
                          cancel:(NSString *)cancel
                     destructive:(NSString *)destructive
                         buttons:(NSString *)buttons, ... {
    va_list args;
    va_start(args, buttons);
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:title 
                                                              delegate:delegate
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:nil] autorelease];
    
    for (NSString *button = buttons; button != nil; button = va_arg(args, NSString*)){
        [actionSheet addButtonWithTitle:button];
    }
    if (cancel != nil) {
        actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:cancel];
    }
    if (destructive != nil) {
        actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:cancel];
    }
    va_end(args);
    actionSheet.tag = tag;
    if ([USHDevice isIPad] && [USHDevice isPortraitMode]) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGRect rect = [delegate.view convertRect:[event getRectForView:delegate.view] toView:window];
        [actionSheet showFromRect:rect inView:window animated:YES];
    }
    else {
        CGRect rect = [event getRectForView:delegate.view];
        [actionSheet showFromRect:rect inView:delegate.view animated:YES];
    }
    return actionSheet;
}

@end
