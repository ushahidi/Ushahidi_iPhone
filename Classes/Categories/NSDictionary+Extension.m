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

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)

- (NSString *) stringForKey:(NSString *)key {
	NSObject *object = [self objectForKey:key];
	if (object != nil) {
		if ([object isKindOfClass:[NSString class]]) {
			return (NSString *)object;
		}
		if ([object isKindOfClass:[NSNumber class]]) {
			NSNumber *number = (NSNumber *)object;
			return [number stringValue];
		}
		if ([object isKindOfClass:[NSDecimalNumber class]]) {
			NSDecimalNumber *number = (NSDecimalNumber *)object;
			return [number stringValue];
		}
	}
	return @"";
}

- (NSInteger) intForKey:(NSString *)key {
	NSObject *object = [self objectForKey:key];
	if (object != nil) {
		if ([object isKindOfClass:[NSString class]]) {
			return [((NSString *)object) intValue];
		}
		return (NSInteger)object;
	}
	return 0;
}

- (BOOL) boolForKey:(NSString *)key {
	NSObject *object = [self objectForKey:key];
	if (object != nil) {
		if ([object isKindOfClass:[NSString class]]) {
			return [((NSString *)object) boolValue];
		}
		if ([object isKindOfClass:[NSNumber class]]) {
			NSNumber *number = (NSNumber *)object;
			return [number intValue] == 1;
		}
		return ((NSInteger)object) == 1;
	}
	return NO;
}


- (NSDate *) dateForKey:(NSString *)key {
	NSObject *object = [self objectForKey:key];
	if (object != nil) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
		NSDate *date = [formatter dateFromString:((NSString *)object)];
		[formatter release];	
		return date;
	}
	return nil;
}

@end
