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

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

- (NSString *) dateToString:(NSString *)dateFormat {
	return [self dateToString:dateFormat fromTimeZone:nil];
}

- (NSString *) dateToString:(NSString *)dateFormat fromTimeZone:(NSString *)timeZone {
	NSDate *sourceDate = self;
	if (timeZone != nil) {
		NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:timeZone];
		NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
		
		NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
		NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
		NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
		
		sourceDate = [NSDate dateWithTimeInterval:interval sinceDate:self];
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:dateFormat];
	NSString *dateString = [formatter stringFromDate:sourceDate];
	[formatter release];	
	return dateString;
}

+ (NSDate *) dateFromString:(NSString *)string {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *date = [formatter dateFromString:string];
	[formatter release];	
	return date;
}

@end
