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

@interface Location : NSObject<NSCoding> {

@public 
	NSString *identifier;
	NSString *name;
	NSString *latitude;
	NSString *longitude;
	NSString *coordinates;
}

@property(nonatomic,retain)	NSString *identifier;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *latitude;
@property(nonatomic,retain) NSString *longitude;
@property(nonatomic,readonly) NSString *coordinates;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (BOOL) matchesString:(NSString *)string;
- (NSComparisonResult)compareByName:(Location *)location;
- (BOOL) equals:(NSString *)name latitude:(NSString *)latitude longitude:(NSString *)longitude;

@end
