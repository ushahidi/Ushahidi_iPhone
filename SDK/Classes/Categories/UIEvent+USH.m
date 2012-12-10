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

#import "UIEvent+USH.h"

@implementation UIEvent (USH)

- (CGRect) getRectForView:(UIView*)view {
    UITouch *touch = [[self allTouches] anyObject];
    CGPoint location = [touch locationInView:view];
    CGRect rect;
    rect.origin.x = location.x;
    rect.origin.y = location.y;
    rect.size.width = 5;
    rect.size.height = 5;
    return rect;
}

@end
