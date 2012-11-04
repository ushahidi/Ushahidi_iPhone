//
//  FileUtils.m
//  Ushahidi_iOS
//
//  Created by David Grandinetti on 11/2/12.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "FileUtils.h"
#import <sys/xattr.h>

@implementation FileUtils

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path {
    if (SYSTEM_VERSION_LESS_THAN(@"5.0.1")) {

        //5.0 or below, do nothing.
        return NO;

    } else if (SYSTEM_VERSION_EQUAL_TO(@"5.0.1")) {
        assert([[NSFileManager defaultManager] fileExistsAtPath: path]);
        
        const char* filePath = [path fileSystemRepresentation];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    } else if (SYSTEM_VERSION_GREATER_THAN(@"5.0.1")) {
        assert([[NSFileManager defaultManager] fileExistsAtPath: path]);
        
        NSError *error = nil;
        NSURL *URL = [NSURL fileURLWithPath:path];
        BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            DLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
        return success;
    }
    
    return NO;
}

//
// For files that are not user generated, and should not be backed up to iCloud, we'll
// need to (a) put them in the correct location and (b) mark that they should not be
// backed up (using addSkipBackupAttributeToItemAtPath method above).
//
+ (NSString *)pathForNonUserGeneratedFile {

    if ( SYSTEM_VERSION_LESS_THAN(@"5.0.1") ) {
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        return [filePaths objectAtIndex:0];
    }

    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [filePaths objectAtIndex:0];
}

@end
