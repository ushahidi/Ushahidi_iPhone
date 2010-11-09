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

@property (nonatomic, assign) id<SliderTableCellDelegate> delegate;

@end

@implementation SliderTableCell

@synthesize delegate, indexPath;

- (id)initForDelegate:(id<SliderTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
        self.delegate = theDelegate;
		UISlider *slider = [[UISlider alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		slider.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		slider.continuous = YES;
		[slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
		[slider setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:slider];
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void) setMinimum:(CGFloat)minimum {
	UISlider *slider = [self.contentView.subviews objectAtIndex:0];
	slider.minimumValue = minimum;
}

- (void) setMaximum:(CGFloat)maximum {
	UISlider *slider = [self.contentView.subviews objectAtIndex:0];
	slider.maximumValue = maximum;
}

- (void) setValue:(CGFloat)value {
	UISlider *slider = [self.contentView.subviews objectAtIndex:0];
	slider.value = value;
}

- (void) sliderValueChanged:(id)sender {
	UISlider *slider = (UISlider *)sender;
	SEL selector = @selector(sliderCellChanged:value:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate sliderCellChanged:self value:slider.value];
	}
}

- (void)dealloc {
	delegate = nil;
	[indexPath release];
    [super dealloc];
}

@end
