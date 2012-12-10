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

#import "USHMapTableCell.h"
#import <Ushahidi/USHDevice.h>

@interface USHMapTableCell()

@end

@implementation USHMapTableCell

@synthesize titleLabel = _titleLabel;
@synthesize urlLabel = _urlLabel;
@synthesize reportsLabel = _reportsLabel;
@synthesize checkinsLabel = _checkinsLabel;
@synthesize reportsIcon = _reportsIcon;
@synthesize checkinsIcon = _checkinsIcon;

- (void)dealloc {
	[_titleLabel release];
	[_urlLabel release];
    [_reportsLabel release];
    [_checkinsLabel release];
    [_checkinsIcon release];
    [_reportsIcon release];
    [super dealloc];
}

- (void) setLoading:(BOOL)loading {
	if (loading) {
        if (self.accessoryView == nil) {
            UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityView startAnimating];
            [self setAccessoryView:activityView];
            [activityView release];
        }
	}
	else {
        [self setAccessoryView:nil];
	}
}

- (BOOL) loading {
    return self.accessoryView != nil;
}

- (void) setReports:(NSInteger)reports {
    CGRect frame = self.titleLabel.frame;
    if (reports > 0) {
        self.reportsLabel.text = [NSString stringWithFormat:@"%d", reports];
        self.reportsLabel.hidden = NO;
        self.reportsIcon.hidden = NO;
        frame.size.width = self.reportsLabel.frame.origin.x - frame.origin.x;
    }
    else {
        self.reportsLabel.hidden = YES;
        self.reportsIcon.hidden = YES;
        frame.size.width = (self.reportsIcon.frame.origin.x + self.reportsIcon.frame.size.width) - frame.origin.x;
    }
    self.titleLabel.frame = frame;
}

- (void) setCheckins:(NSInteger)checkins {
    CGRect frame = self.urlLabel.frame;
    if (checkins > 0) {
        self.checkinsLabel.text = [NSString stringWithFormat:@"%d", checkins];
        self.checkinsLabel.hidden = NO;
        self.checkinsIcon.hidden = NO;
        frame.size.width = self.checkinsLabel.frame.origin.x - frame.origin.x;
    }
    else {
        self.checkinsLabel.hidden = YES;
        self.checkinsIcon.hidden = YES;
        frame.size.width = (self.checkinsIcon.frame.origin.x + self.checkinsIcon.frame.size.width) - frame.origin.x;
    }
    self.urlLabel.frame = frame;
}

- (NSInteger) reports {
    return self.checkinsLabel.hidden ? 0 : [self.checkinsLabel.text intValue];
}

- (NSInteger) checkins {
    return self.checkinsLabel.hidden ? 0 : [self.checkinsLabel.text intValue];
}

+ (CGFloat) cellHeight {
	return [USHDevice isIPad] ? 65 : 55;
}

@end
