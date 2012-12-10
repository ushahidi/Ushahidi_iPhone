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

#import "UITableView+USH.h"
#import "USHDevice.h"

@implementation UITableView (USH)

- (CGFloat) headerPadding {
	if ([USHDevice isIPad]) {
        if (self.style == UITableViewStylePlain) {
            return 10;
        }
        return self.contentSize.width > 320 ? 50 : 18;
	}
	return self.style == UITableViewStylePlain ? 10 : 15;
}

- (CGFloat) contentWidth {
    if (self.style == UITableViewStyleGrouped) {
        return self.frame.size.width - [self contentMargin] - [self contentMargin];
    }
    return self.frame.size.width;
}

- (CGFloat)contentMargin {
    if (self.style == UITableViewStylePlain) {
        return 0;
    }
    if ([USHDevice isIPhone]) {
        return 10;
    }
    CGFloat tableWidth = self.frame.size.width;
    if (tableWidth <= 20) {
        return tableWidth - 10;
    }
    if (tableWidth < 400) {
        return 10;
    }
    CGFloat marginWidth  = tableWidth * 0.06;
    marginWidth = MAX(31, MIN(45, marginWidth));
    return marginWidth;
}

- (CGFloat) cellHeightForText:(NSString*)text font:(UIFont*)font {
    CGFloat width = [self contentWidth];
    CGSize size = [text sizeWithFont:font 
                   constrainedToSize:CGSizeMake(width, 9999) 
                       lineBreakMode:UILineBreakModeWordWrap]; 
	return MAX(44, size.height + 20);
}

- (void) reloadCellAtIndexPath:(NSIndexPath*)indexPath {
    [self beginUpdates];
    NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
    [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
}

- (void) reloadRowsAtSection:(NSInteger)section {
    [self beginUpdates];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
}

@end
