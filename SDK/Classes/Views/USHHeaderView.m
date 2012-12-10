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

#import "USHHeaderView.h"
#import "USHDevice.h"

@interface USHHeaderView ()

- (CGFloat) paddingForTable:(UITableView *)tableView;

@end

@implementation USHHeaderView

+ (id)headerForTable:(UITableView *)tableView text:(NSString *)text {
	return [[[USHHeaderView alloc] initForTable:tableView
                                           text:text
                                      textColor:[UIColor whiteColor]
                                backgroundColor:[UIColor blackColor]] autorelease];
}

+ (id)headerForTable:(UITableView *)tableView text:(NSString *)text textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
	return [[[USHHeaderView alloc] initForTable:tableView
                                           text:text
                                      textColor:textColor
                                backgroundColor:backgroundColor] autorelease];
}

- (id)initForTable:(UITableView *)tableView text:(NSString *)text textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor {
	CGRect frame = CGRectMake(0.0, 0.0, tableView.bounds.size.width, 24.0);
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = backgroundColor;
		self.opaque = YES;
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = backgroundColor;
		label.opaque = YES;
		label.textColor = textColor;
		label.font = [UIFont boldSystemFontOfSize:16];
		CGFloat padding = [self paddingForTable:tableView];
		label.frame = CGRectMake(padding, 0.0, frame.size.width - padding, frame.size.height);
		label.text = text;
        label.textAlignment = NSTextAlignmentLeft;
		label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		[self addSubview:label];
		[label release];
	}
    return self;
}

- (CGFloat) paddingForTable:(UITableView *)tableView {
	if ([USHDevice isIPad]) {
        UIView *parent = tableView.superview;
        DLog(@"Parent:%f Width:%f", parent.frame.size.width, tableView.contentSize.width);
        if (tableView.style == UITableViewStylePlain) {
            return 10;
        }
        if (tableView.contentSize.width == 320) {
            return 18;
        }
        if (tableView.contentSize.width == 540) {
            return 36;
        }
        if (tableView.contentSize.width == 703) {
            return 50;
        }
        return 50;
	}
	return tableView.style == UITableViewStylePlain ? 10 : 15;
}

- (void)dealloc {
	[super dealloc];
}

- (void) setText:(NSString *)text {
	UILabel *label = (UILabel *)[self.subviews objectAtIndex:0];
	if (label != nil && [label isKindOfClass:[UILabel class]]) {
		[label setText:text];
	}
}

+ (CGFloat) headerHeightForStyle:(UITableViewStyle)style {
	return style == UITableViewStylePlain ? 24 : 30;
}

@end
