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

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)getUUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString *)string autorelease];
}

+ (BOOL) isNilOrEmpty:(NSString *)string {
	return string == nil || [string length] == 0;
}


- (BOOL) anyWordHasPrefix:(NSString *)prefix {
	if (prefix == nil || [prefix length] == 0) {
		return YES;
	}
	for(NSString *word in [[self lowercaseString] componentsSeparatedByString:@" "]) {
		if ([word hasPrefix:[prefix lowercaseString]]) {
			return YES;
		}
	}
	return NO;
}

@end
