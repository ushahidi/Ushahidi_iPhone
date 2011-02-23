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

#import <Foundation/Foundation.h>

@interface NSString (Extension) 

+ (BOOL) isNilOrEmpty:(NSString *)string;
- (BOOL) anyWordHasPrefix:(NSString *)prefix;

- (NSString *)stringByTrimmingSuffix:(NSString *)suffix;
- (NSString *) stringWithMaxLength:(NSInteger)maxLength;

+ (NSString *)getUUID;

- (BOOL) isUUID;
- (BOOL) isValidEmail;
- (BOOL) isValidURL;

+ (BOOL) stringIsUUID:(NSString *)string;
+ (BOOL) stringIsValidEmail:(NSString *)string;
+ (BOOL) stringIsValidURL:(NSString *)string;

+ (NSString *) stringByAppendingPathComponents:(NSString *)string, ... NS_REQUIRES_NIL_TERMINATION;
- (NSString *) appendUrlStringWithFormat:(NSString *)format, ...;
+ (NSString *) stringByEscapingCharacters:(NSString *)string;

@end
