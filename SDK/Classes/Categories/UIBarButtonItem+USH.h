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

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (USH)

+ (UIBarButtonItem*) borderedItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor;
+ (UIBarButtonItem*) borderedItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action;
+ (UIBarButtonItem*) borderedItemWithImage:(UIImage*)image tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action;

+ (UIBarButtonItem*) plainItemWithTitle:(NSString*)title;
+ (UIBarButtonItem*) plainItemWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem*) plainItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

+ (UIBarButtonItem*) doneItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor;
+ (UIBarButtonItem*) doneItemWithTitle:(NSString*)title tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action;
+ (UIBarButtonItem*) doneItemWithImage:(UIImage*)image tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action;

+ (UIBarButtonItem*) infoItemWithTarget:(id)target action:(SEL)action;

@end
