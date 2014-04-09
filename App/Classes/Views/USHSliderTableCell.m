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

#import "USHSliderTableCell.h"
#import <Ushahidi/NSObject+USH.h>
#import <Ushahidi/NSString+USH.h>

@implementation USHSliderTableCell

@synthesize indexPath = _indexPath;
@synthesize textLabel;
@synthesize sliderView = _sliderView;
@synthesize valueLabel = _valueLabel;
@synthesize delegate = _delegate;
@synthesize imageView;
@synthesize suffix = _suffix;

- (void) setText:(NSString *)text {
	self.textLabel.text = text;
}

- (NSString *)text {
    return self.textLabel.text;
}

- (void)setValue:(NSInteger)value {
    NSNumber *number = [NSNumber numberWithInt:value];
    self.sliderView.value = [number floatValue];
    if ([NSString isNilOrEmpty:self.suffix]) {
        self.valueLabel.text = [NSString stringWithFormat:@"%d", value];
    }
    else {
        self.valueLabel.text = [NSString stringWithFormat:@"%d%@", value, self.suffix];
    }
}

- (NSInteger)value {
    return [[NSNumber numberWithFloat:self.sliderView.value] intValue];
}

- (NSInteger) min {
    NSNumber *number = [NSNumber numberWithFloat:self.sliderView.minimumValue];
    return [number intValue];
}

- (void) setMin:(NSInteger)min {
    NSNumber *number = [NSNumber numberWithInt:min];
    self.sliderView.minimumValue = [number floatValue];
}

- (NSInteger) max {
    NSNumber *number = [NSNumber numberWithFloat:self.sliderView.maximumValue];
    return [number intValue];
}

- (void) setMax:(NSInteger)max {
    NSNumber *number = [NSNumber numberWithInt:max];
    self.sliderView.maximumValue = [number floatValue];
}

- (void) setEnabled:(BOOL)enabled {
    self.sliderView.enabled = enabled;
    [self.sliderView setNeedsDisplay];
}

- (BOOL) enabled {
    return self.sliderView.enabled;
}

- (IBAction) changed:(id)sender {
    NSNumber *number = [NSNumber numberWithFloat:self.sliderView.value];
    if ([NSString isNilOrEmpty:self.suffix]) {
        self.valueLabel.text = [NSString stringWithFormat:@"%d", [number intValue]];
    }
    else {
        self.valueLabel.text = [NSString stringWithFormat:@"%d%@", [number intValue], self.suffix];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(sliderTableViewCell:index:value:)]) {
        [self.delegate sliderTableViewCell:self index:self.indexPath value:[number intValue]];
	}
}


@end
