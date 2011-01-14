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

- (NSString *)stringByTrimmingSuffix:(NSString *)suffix {
    if([self hasSuffix:suffix])
		self = [self substringToIndex:[self length] - [suffix length]];
    return self;
}

- (BOOL) isValidEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:self];
}

- (BOOL) isValidURL {
	//NSString *urlRegex = @"(http|https)://([\\w\\.\\-\\+]+:{0,1}[\\w\\.\\-\\+]*@)?([A-Za-z0-9\\-\\.]+)(:[0-9]+)?(/|/([\\w#!:\\.\\?\\+=&%@!\\-\\/\\(\\)]+))?";
	NSString *urlRegex = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+(:[0-9]+)?(/|/([\\w#!:\\.\\?\\+=&%@!\\-\\/\\(\\)]+))?";
    //NSString *urlRegex = @"(http|https)://(?::\\/{2}[\\w]+)(?:[\\/|\\.]?)(?:[^\\s\"]*)";
	NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex]; 
    return [urlTest evaluateWithObject:self];
}

+ (NSString *)stringByAppendingPathComponents:(NSString *)string, ... {
    va_list args;
    va_start(args, string);
	NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [filePaths objectAtIndex:0];
	for (NSString *arg = string; arg != nil; arg = va_arg(args, NSString*)) {
		if (arg != nil && [arg length] > 0) {
			filePath = [filePath stringByAppendingPathComponent:arg];
		}
	}
	va_end(args);
	return filePath;
}

@end
