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

#import "USHDefaults.h"
#import "UIColor+USH.h"

@implementation USHDefaults

#pragma mark - Properties

- (NSString*) facebookAppID {
    return [self stringFromBundleForKey:@"FacebookAppID"];
}

#pragma mark - Methods

- (BOOL) saveChanges {
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - NSBundle

- (NSString*) stringFromBundleForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:key];
}

- (BOOL) boolFromBundleForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber *number = [infoDictionary objectForKey:key];
    return [number boolValue];
}

- (BOOL) boolFromBundleForKey:(NSString *)key defaultValue:(BOOL)value {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber *number = [infoDictionary objectForKey:key];
    if (number != nil) {
        return [number boolValue];
    }
    return value;
}

- (NSInteger) integerFromBundleForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSNumber *number = [infoDictionary objectForKey:key];
    return [number integerValue];
}

- (UIColor*) colorFromBundleForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [UIColor colorFromHexString:[infoDictionary objectForKey:key]];
}

- (NSDictionary*) dictionaryFromBundleForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSObject *object = [infoDictionary objectForKey:key];
    return [object isKindOfClass:NSDictionary.class] ? (NSDictionary*)object : nil;
}

- (NSArray*) arrayFromBundleForKey:(NSString *)key {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSObject *object = [infoDictionary objectForKey:key];
    return [object isKindOfClass:NSArray.class] ? (NSArray*)object : nil;
}

#pragma mark - NSUserDefaults

- (BOOL) boolFromDefaultsForKey:(NSString*)key defaultValue:(BOOL)value {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil
    ? [[NSUserDefaults standardUserDefaults] boolForKey:key] : value;
}

- (NSString*) stringFromDefaultsForKey:(NSString*)key defaultValue:(NSString*)value {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil
    ? [[NSUserDefaults standardUserDefaults] stringForKey:key] : value;
}

- (NSDate*) dateFromDefaultsForKey:(NSString*)key defaultValue:(NSDate*)value {
    NSString *dateString = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (dateString != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
        NSDate *date = [formatter dateFromString:dateString];
        [formatter release];
        return date;
    }
    return value;
}

- (void) setDate:(NSDate*)date forKey:(NSString*)key {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *dateString = [formatter stringFromDate:date];
    [formatter release];
    [[NSUserDefaults standardUserDefaults] setValue:dateString forKey:key];
}

- (void) setBool:(BOOL)boolean forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setBool:boolean forKey:key];
}

- (void) setString:(NSString*)string forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setValue:string forKey:key];
}

- (void) setInteger:(NSInteger)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
}

- (NSInteger) integerFromDefaultsForKey:(NSString*)key defaultValue:(NSInteger)value {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil
    ? [[NSUserDefaults standardUserDefaults] integerForKey:key] : value;
}

- (void) setFloat:(CGFloat)value forKey:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
}

- (CGFloat) floatFromDefaultsForKey:(NSString*)key defaultValue:(CGFloat)value {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key] != nil
    ? [[NSUserDefaults standardUserDefaults] floatForKey:key] : value;
}

@end