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

#import "UIColor+USH.h"

@implementation UIColor (USH)

+ (UIColor *) colorFromHexString:(NSString *)hexString {
	if (hexString != nil && [hexString length] > 0) {
		NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
		if ([cleanString length] == 3) {
			cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@", 
						   [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
						   [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
						   [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
		}
		if ([cleanString length] == 6) {
			cleanString = [cleanString stringByAppendingString:@"ff"];
		}
		
		unsigned int baseValue;
		[[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
		
		float red = ((baseValue >> 24) & 0xFF)/255.0f;
		float green = ((baseValue >> 16) & 0xFF)/255.0f;
		float blue = ((baseValue >> 8) & 0xFF)/255.0f;
		float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
		
		return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];	
	}
	return [UIColor clearColor];
}

- (BOOL) isEqualToColor:(UIColor *)otherColor {
	return CGColorEqualToColor(self.CGColor, otherColor.CGColor);
}

@end
