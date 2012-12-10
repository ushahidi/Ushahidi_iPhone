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

#import "UIAlertView+USH.h"

@implementation UIAlertView (USH)

+ (UIAlertView*) showWithTitle:(NSString *)title 
                       message:(NSString *)message 
                      delegate:(id<UIAlertViewDelegate>)delegate 
                        cancel:(NSString *)cancel 
                       buttons:(NSString *)buttons, ... {
    va_list args;
    va_start(args, buttons);
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:delegate
                                               cancelButtonTitle:nil
                                               otherButtonTitles:nil] autorelease];
    for (NSString *button = buttons; button != nil; button = va_arg(args, NSString*)){
        [alertView addButtonWithTitle:button];
    }
    if (cancel != nil) {
        alertView.cancelButtonIndex = [alertView addButtonWithTitle:cancel];
    }
    va_end(args);
    [alertView show];
    return alertView;
}

+ (UIAlertView*) showWithTitle:(NSString *)title 
                       message:(NSString *)message 
                      delegate:(id<UIAlertViewDelegate>)delegate 
                           tag:(NSInteger)tag
                        cancel:(NSString *)cancel 
                       buttons:(NSString *)buttons, ... {
    va_list args;
    va_start(args, buttons);
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:title
                                                         message:message
                                                        delegate:delegate
                                               cancelButtonTitle:nil
                                               otherButtonTitles:nil] autorelease];
    for (NSString *button = buttons; button != nil; button = va_arg(args, NSString*)){
        [alertView addButtonWithTitle:button];
    }
    if (cancel != nil) {
        alertView.cancelButtonIndex = [alertView addButtonWithTitle:cancel];
    }
    va_end(args);
    alertView.tag = tag;
    [alertView show];
    return alertView;
}

@end
