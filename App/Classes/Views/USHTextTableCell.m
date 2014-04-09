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

#import "USHTextTableCell.h"
#import <Ushahidi/UITableView+USH.h>

@interface USHTextTableCell ()

@end

@implementation USHTextTableCell

@synthesize textLabel;

- (void) awakeFromNib {
    [super awakeFromNib];
    self.textLabel.font = [UIFont systemFontOfSize:16];
}

+ (CGFloat) heightForTable:(UITableView *)tableView text:(NSString *)text {
    CGFloat width = [tableView contentWidth];
    width -= 6; //left
    width -= 6; //right
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16]
                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) 
                       lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat height = size.height;
    height += 6; //top
    height += 6; //bottom
    return MAX(44, height);
}


@end
