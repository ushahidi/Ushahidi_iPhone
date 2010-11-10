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

#import "TextTableCell.h"

#define kPadding 20

@interface TextTableCell ()

@property (nonatomic, assign) id<TextTableCellDelegate>	delegate;

+ (UIFont *) getLabelFont;

@end

@implementation TextTableCell

@synthesize delegate, indexPath; 

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		self.textLabel.numberOfLines = 0; 
		self.textLabel.font = [TextTableCell getLabelFont];
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    return self;
}

- (NSString *) getText {
	return	self.textLabel.text;
}

- (void) setText:(NSString *)theText {
	if (theText == nil || [theText isEqualToString:@""]) {
		self.textLabel.text = @"";
	}
	else {
		self.textLabel.text = theText;
	}
}

- (void) setTextColor:(UIColor *)textColor {
	self.textLabel.textColor = textColor;
}

- (CGSize) getCellSize {
	CGRect rect = [self.textLabel textRectForBounds:CGRectMake(0.0, 0.0, self.frame.size.width, FLT_MAX) limitedToNumberOfLines:0];
	return CGSizeMake(rect.size.width, rect.size.height);
}

+ (CGSize)getCellSizeForText:(NSString *)theText forWidth:(CGFloat)width {
	CGSize size = [theText sizeWithFont:[TextTableCell getLabelFont] constrainedToSize:CGSizeMake(width, 9999) lineBreakMode:UILineBreakModeWordWrap]; 
	return CGSizeMake(size.width, size.height + kPadding);
}

+ (UIFont *) getLabelFont {
	return [UIFont systemFontOfSize:16];
}

- (void)dealloc {
	[indexPath release];
    [super dealloc];
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

@end
