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

#import "NSKeyedArchiver+Extension.h"

@implementation NSKeyedArchiver (Extension)

+ (void) archiveObject:(id)object forKey:(NSString *)key {
	@try {
		NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *filePath = [[filePaths objectAtIndex:0] stringByAppendingPathComponent:key];
		DLog(@"Archiving %@", filePath);
		[NSKeyedArchiver archiveRootObject:object toFile:filePath];
	}
	@catch (NSException *e) {
		DLog(@"NSException: %@", e);
	}
}

+ (void) archiveObject:(id)object forKey:(NSString *)key andSubKey:(NSString *)subKey {
	@try {
		NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *folderPath = [[filePaths objectAtIndex:0] stringByAppendingPathComponent:key];
		if ([[NSFileManager defaultManager] fileExistsAtPath:folderPath] == NO) {
			[[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		NSString *filePath = [folderPath stringByAppendingPathComponent:subKey];
		DLog(@"Archiving %@", filePath);
		[NSKeyedArchiver archiveRootObject:object toFile:filePath];
	}
	@catch (NSException *e) {
		DLog(@"NSException: %@", e);
	}
}

@end
