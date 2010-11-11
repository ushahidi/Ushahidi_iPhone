/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
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

#import "DeploymentTableCell.h"

@interface DeploymentTableCell()

@end

@implementation DeploymentTableCell

@synthesize titleLabel, urlLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    }
    return self;
}

- (void)dealloc {
	[titleLabel release];
	[urlLabel release];
    [super dealloc];
}

- (NSString *) title {
	return self.titleLabel.text;
}

- (void) setTitle:(NSString *)title {
	self.titleLabel.text = title;
}

- (NSString *) url {
	return self.urlLabel.text;
}

- (void) setUrl:(NSString *)url {
	self.urlLabel.text = url;
}

- (void) setSelectedColor:(UIColor *)color {
	UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
	[selectedBackgroundView setBackgroundColor:color];
	[self setSelectedBackgroundView:selectedBackgroundView];
	[selectedBackgroundView release];	
}

+ (CGFloat) getCellHeight {
	return 44;
}

@end
