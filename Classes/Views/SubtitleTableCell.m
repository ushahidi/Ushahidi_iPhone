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

#import "SubtitleTableCell.h"

@interface SubtitleTableCell (Internal)

- (void) setButtonImage:(UIImage *)image;
- (void) clicked:(id)sender;

@end

@implementation SubtitleTableCell

@synthesize indexPath, defaultImage;

- (id)initWithDefaultImage:(UIImage *)theDefaultImage reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
		self.defaultImage = theDefaultImage;
		self.imageView.image = theDefaultImage;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    return self;
}

- (void)dealloc {
	[indexPath release];
	[defaultImage release];
	[super dealloc];
}

- (void) setText:(NSString *)theText {
	if (theText == nil || [theText isEqualToString:@""]) {
		self.textLabel.text = @"";
	}
	else {
		self.textLabel.text = theText;
	}
}

- (void) setDescription:(NSString *)description {
	if (description == nil || [description isEqualToString:@""]) {
		self.detailTextLabel.text = @"";	
	}
	else {
		self.detailTextLabel.text = description;
	}
}

- (void) setImage:(UIImage *)theImage {
	if (theImage != nil) {
		self.imageView.image = theImage;
	}
	else {
		self.imageView.image = self.defaultImage;
	}
}

@end
