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

@interface SubtitleTableCell ()


@end

@implementation SubtitleTableCell

- (id)initWithIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    return self;
}

- (void)dealloc {
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

- (NSString *) getText {
	return self.textLabel.text;
}

- (void) setDescription:(NSString *)description {
	if (description == nil || [description isEqualToString:@""]) {
		self.detailTextLabel.text = @"";	
	}
	else {
		self.detailTextLabel.text = description;
	}
}

- (NSString *) getDescription {
	return self.detailTextLabel.text;
}

- (void) setSelectedColor:(UIColor *)color {
	UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
	[selectedBackgroundView setBackgroundColor:color];
	[self setSelectedBackgroundView:selectedBackgroundView];
	[selectedBackgroundView release];	
}

- (UIColor *) selectedColor {
	return self.selectedBackgroundView.backgroundColor;
}

+ (CGFloat) getCellHeight {
	return 50;
}

@end
