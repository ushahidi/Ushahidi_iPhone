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

#import "USHCommentTableCell.h"
#import <Ushahidi/UITableView+USH.h>

@interface USHCommentTableCell ()

@end

@implementation USHCommentTableCell

@synthesize commentLabel = _commentLabel;
@synthesize authorLabel = _authorLabel;
@synthesize dateLabel = _dateLabel;
@synthesize imageView;

+ (CGFloat) heightForTable:(UITableView *)tableView text:(NSString *)text {
    CGFloat width = [tableView contentWidth];
    width -= 32; //left
    width -= 8; //right
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17] 
                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) 
                       lineBreakMode:NSLineBreakByWordWrapping]; 
    CGFloat height = size.height;
    height += 2; //top
    height += 2; //bottom
    height += 20; //label
    height += 12; //padding
	return MAX(44, height);
}


@end
