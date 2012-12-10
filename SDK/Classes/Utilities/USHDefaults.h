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

#import <Foundation/Foundation.h>

@interface USHDefaults : NSObject

@property(nonatomic, assign, readonly) NSString *facebookAppID;

- (NSString*) stringFromBundleForKey:(NSString *)key;
- (NSString*) stringFromDefaultsForKey:(NSString*)key defaultValue:(NSString*)value;
- (void) setString:(NSString*)string forKey:(NSString*)key;

- (BOOL) boolFromBundleForKey:(NSString *)key;
- (BOOL) boolFromBundleForKey:(NSString *)key defaultValue:(BOOL)value;
- (BOOL) boolFromDefaultsForKey:(NSString*)key defaultValue:(BOOL)value;
- (void) setBool:(BOOL)boolean forKey:(NSString*)key;

- (NSInteger) integerFromBundleForKey:(NSString *)key;
- (NSInteger) integerFromDefaultsForKey:(NSString*)key defaultValue:(NSInteger)value;
- (void) setInteger:(NSInteger)value forKey:(NSString*)key;

- (CGFloat) floatFromDefaultsForKey:(NSString*)key defaultValue:(CGFloat)value;
- (void) setFloat:(CGFloat)value forKey:(NSString*)key;

- (NSDate*) dateFromDefaultsForKey:(NSString*)key defaultValue:(NSDate*)value;
- (void) setDate:(NSDate*)date forKey:(NSString*)key;

- (UIColor*) colorFromBundleForKey:(NSString *)key;
- (NSDictionary*) dictionaryFromBundleForKey:(NSString *)key;
- (NSArray*) arrayFromBundleForKey:(NSString *)key;

- (BOOL) saveChanges;

@end
