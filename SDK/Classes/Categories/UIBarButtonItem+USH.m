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

#import "UIBarButtonItem+USH.h"

@implementation UIBarButtonItem (USH)

+ (UIBarButtonItem*) borderedItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor {
    UIBarButtonItem *barButtonItem =  [[[UIBarButtonItem alloc] initWithTitle:title
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:nil
                                                                       action:nil] autorelease];
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = tintColor;
    }
    return barButtonItem;
}

+ (UIBarButtonItem*) borderedItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action {
    UIBarButtonItem *barButtonItem =  [[[UIBarButtonItem alloc] initWithTitle:title
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:target
                                                                       action:action] autorelease];
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = tintColor;
    }
    return barButtonItem;
}

+ (UIBarButtonItem*) borderedItemWithImage:(UIImage*)image tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action {
    UIBarButtonItem *barButtonItem =  [[[UIBarButtonItem alloc] initWithImage:image
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:target
                                                                       action:action] autorelease];
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = tintColor;
    }
    return barButtonItem;
}

+ (UIBarButtonItem*) plainItemWithTitle:(NSString*)title {
    return [[[UIBarButtonItem alloc] initWithTitle:title
                                             style:UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil] autorelease];
}

+ (UIBarButtonItem*) plainItemWithTitle:(NSString*)title target:(id)target action:(SEL)action {
    return [[[UIBarButtonItem alloc] initWithTitle:title
                                             style:UIBarButtonItemStylePlain
                                            target:target
                                            action:action] autorelease];
}

+ (UIBarButtonItem*) plainItemWithImage:(UIImage*)image target:(id)target action:(SEL)action {
    return [[[UIBarButtonItem alloc] initWithImage:image 
                                             style:UIBarButtonItemStylePlain 
                                            target:target 
                                            action:action] autorelease];
}

+ (UIBarButtonItem*) doneItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor {
    UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithTitle:title
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:nil
                                                                       action:nil] autorelease];
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = tintColor;
    }
    return barButtonItem;
}

+ (UIBarButtonItem*) doneItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action {
    UIBarButtonItem *barButtonItem =  [[[UIBarButtonItem alloc] initWithTitle:title
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:target
                                                                       action:action] autorelease];
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = tintColor;
    }
    return barButtonItem;
}

+ (UIBarButtonItem*) doneItemWithImage:(UIImage*)image tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action {
    UIBarButtonItem *barButtonItem = [[[UIBarButtonItem alloc] initWithImage:image
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:target
                                                                      action:action] autorelease];
    if ([barButtonItem respondsToSelector:@selector(tintColor)]) {
        barButtonItem.tintColor = tintColor;
    }
    return barButtonItem;
}

+ (UIBarButtonItem*) infoItemWithTarget:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

@end
