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

#import "ImageTableCell.h"

@implementation ImageTableCell

@synthesize indexPath, cellImageView;

- (id)initWithImage:(UIImage *)theImage reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		self.cellImageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.cellImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.cellImageView.contentMode = UIViewContentModeScaleAspectFit;
		self.cellImageView.image = theImage;
		[self.contentView addSubview:self.cellImageView];
	}
    return self;
}

- (void) setImage:(UIImage *)theImage {
	self.cellImageView.image = theImage;
}

- (UIImage *) getImage {
	return self.cellImageView.image;
}

- (void)dealloc {
	[indexPath release];
	[cellImageView release];
    [super dealloc];
}

@end
