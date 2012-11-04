//
//  FileUtils.h
//  Ushahidi_iOS
//
//  Created by David Grandinetti on 11/2/12.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;
+ (NSString *)pathForNonUserGeneratedFile;

@end
