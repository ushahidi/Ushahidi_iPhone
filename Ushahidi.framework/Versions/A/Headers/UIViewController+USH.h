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
#import <QuartzCore/QuartzCore.h>

@interface UIViewController (USH)

- (BOOL) isTopView:(UIView *)view;
- (BOOL) isTopController;
- (BOOL) isModalViewController;

- (CGRect) touchOfEvent:(UIEvent*)event;

- (UIBarButtonItem *) barButtonWithItems:(UIBarButtonItem*)item, ... NS_REQUIRES_NIL_TERMINATION; 

- (void) animatePageCurlUp:(CGFloat)duration;
- (void) animatePageCurlDown:(CGFloat)duration;
- (void) animatePageCurl:(BOOL)up fillMode:(NSString*)fillMode type:(NSString*)type duration:(CGFloat)duration;
- (CGRect) touchForEvent:(UIEvent*)event;

@end
