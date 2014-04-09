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

#import "USHCheckinTableCell.h"
#import <Ushahidi/USHTableCell.h>
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/UITableView+USH.h>

@implementation USHCheckinTableCell

@synthesize nameLabel = _nameLabel;
@synthesize messageLabel = _messageLabel;
@synthesize dateLabel = _dateLabel;
@synthesize imageView;

- (void) awakeFromNib {
    [super awakeFromNib];
    self.imageView.superview.layer.cornerRadius = 5.0f;
}


- (void) setName:(NSString *)name {
	self.nameLabel.text = name;
}

- (NSString *)name {
	return self.nameLabel.text;
}

- (void) setMessage:(NSString *)message {
	self.messageLabel.text = message;
}

- (NSString *)message {
	return self.messageLabel.text;
}

- (void) setDate:(NSString *)date {
	self.dateLabel.text = date;
}

- (NSString *)date {
	return self.dateLabel.text;
}

- (void) setImage:(UIImage *)image {
    if (image != nil) {
		self.imageView.image = image;
	} 
	else {
		self.imageView.image = [UIImage imageNamed:@"placeholder.png"];
	}
}

- (UIImage *) image {
	return self.imageView.image;
}

+ (CGFloat) heightForTable:(UITableView *)tableView text:(NSString *)text image:(BOOL)image {
    CGFloat width = [tableView contentWidth];
    width -= 9; //left
    width -= 9; //right
    if (image) {
        if ([USHDevice isIPad]) {
            width -= 80;
        }
        else {
            width -= 70;
        }
    }
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:16]
                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                       lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat height = size.height;
    height += 3; //top
    height += 3; //bottom
    height += 20; //name
    height += 20; //date
    height += 4; //bottom
    return [USHDevice isIPad] ? MAX(90, height) : MAX(75, height);
}

@end
