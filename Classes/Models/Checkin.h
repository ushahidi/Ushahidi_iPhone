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

@class Location;
@class Photo;

@interface Checkin : NSObject<NSCoding> {

@public 
	NSString *identifier;
	NSString *message;
	NSString *latitude;
	NSString *longitude;
	NSString *coordinates;
	NSDate *date;
	
	NSString *user;
	NSString *name;
	NSString *email;

	NSString *firstName;
	NSString *lastName;
	NSString *mobile;
	
	Location *location;
	NSMutableArray *photos;
	Photo *firstPhoto;
	UIImage *map;
	
	BOOL hasName;
	BOOL hasDate;
	BOOL hasMessage;
	BOOL hasLocation;
	BOOL hasPhotos;
	BOOL hasMap;
}

@property(nonatomic,retain)	NSString *identifier;
@property(nonatomic,retain) NSString *message;
@property(nonatomic,retain) NSString *latitude;
@property(nonatomic,retain) NSString *longitude;
@property(nonatomic,retain) NSDate *date;

@property(nonatomic,retain) NSString *user;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *email;

@property(nonatomic,retain) NSString *firstName;
@property(nonatomic,retain) NSString *lastName;
@property(nonatomic,retain) NSString *mobile;

@property(nonatomic,retain) Location *location;

@property(nonatomic,retain) NSMutableArray *photos;

@property(nonatomic,readonly) NSString *dateString;
@property(nonatomic,readonly) NSString *timeString;
@property(nonatomic,readonly) NSString *dateTimeString;
@property(nonatomic,readonly) NSString *coordinates;

@property(nonatomic,readonly) BOOL hasName;
@property(nonatomic,readonly) BOOL hasDate;
@property(nonatomic,readonly) BOOL hasMessage;
@property(nonatomic,readonly) BOOL hasLocation;
@property(nonatomic,readonly) BOOL hasPhotos;
@property(nonatomic,readonly) BOOL hasMap;
@property(nonatomic,readonly) Photo *firstPhoto;
@property(nonatomic,retain) UIImage *map;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDefaultValues;

- (NSArray *) photoImages;
- (void) addPhoto:(Photo *)photo;
- (void) removePhotos;
- (UIImage *) getFirstPhotoThumbnail;

- (NSComparisonResult)compareByDate:(Checkin *)checkin;
- (NSComparisonResult)compareByName:(Checkin *)checkin;

@end
