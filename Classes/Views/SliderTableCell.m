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

#import "SliderTableCell.h"

@interface SliderTableCell()

@end

@implementation SliderTableCell

@synthesize slider, delegate, textLabel, valueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void) setMinimum:(CGFloat)minimum {
	self.slider.minimumValue = minimum;
}

- (void) setMaximum:(CGFloat)maximum {
	self.slider.maximumValue = maximum;
}

- (void) setValue:(CGFloat)value {
	self.slider.value = value;
}

- (CGFloat) getValue {
	return self.slider.value;
}

- (void) setEnabled:(BOOL)enabled {
	self.textLabel.textColor = enabled ? [UIColor blackColor] : [UIColor grayColor];
	self.valueLabel.textColor = enabled ? [UIColor blackColor] : [UIColor grayColor];
	self.slider.enabled = enabled;
}

- (BOOL) getEnabled {
	return self.slider.enabled;
}

- (IBAction) sliderValueChanged:(id)sender {
	SEL selector = @selector(sliderCellChanged:value:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate sliderCellChanged:self value:self.slider.value];
	}
}

- (void)dealloc {
	delegate = nil;
	[slider release];
	[textLabel release];
	[valueLabel release];
    [super dealloc];
}

@end
