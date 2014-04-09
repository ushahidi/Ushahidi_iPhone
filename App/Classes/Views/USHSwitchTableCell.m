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

#import "USHSwitchTableCell.h"
#import <UShahidi/NSObject+USH.h>

@implementation USHSwitchTableCell

@synthesize imageView;
@synthesize delegate = _delegate;
@synthesize textLabel;
@synthesize switchControl = _switchControl;

- (void) setText:(NSString *)text {
	self.textLabel.text = text;
}

- (NSString *)text {
    return self.textLabel.text;
}

- (void)setOn:(BOOL)on {
	self.switchControl.on = on;
}

- (BOOL)on {
    return self.switchControl.on;
}

- (IBAction) changed:(id)sender {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(switchTableViewCell:index:on:)]) {
        [self.delegate switchTableViewCell:self index:self.indexPath on:self.switchControl.on];
	}
}


@end
