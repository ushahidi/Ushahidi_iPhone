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

@class Photo;
@class News;
@class Sound;
@class Video;
@class Category;

@interface Incident : NSObject {

@public 
	NSString *identifier;
	NSString *title;
	NSString *description;
	NSDate *date;
	NSString *location;
	NSString *latitude;
	NSString *longitude;
	
	BOOL active;
	BOOL verified;
	BOOL pending;
	
	NSMutableArray *news;
	NSMutableArray *photos;
	NSMutableArray *sounds;
	NSMutableArray *videos;
	NSMutableArray *categories;
	
	NSString *errors;
}

@property(nonatomic,retain) NSString *identifier;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) NSDate *date;
@property(nonatomic,retain) NSString *location;
@property(nonatomic,retain) NSString *latitude;
@property(nonatomic,retain) NSString *longitude;

@property(nonatomic,assign) BOOL active;
@property(nonatomic,assign) BOOL verified;
@property(nonatomic,assign) BOOL pending;

@property(nonatomic,retain) NSMutableArray *news;
@property(nonatomic,retain) NSMutableArray *photos;
@property(nonatomic,retain) NSMutableArray *sounds;
@property(nonatomic,retain) NSMutableArray *videos;
@property(nonatomic,retain) NSMutableArray *categories;

@property(nonatomic,retain) NSString *errors;

- (id)initWithDictionary:(NSDictionary *)dictionary mediaDictionary:(NSDictionary *)media;
- (id)initWithDefaultValues;

- (BOOL) matchesString:(NSString *)string;
- (NSString *) dateString;
- (NSString *) timeString;
- (NSString *) dateDayMonthYear;
- (NSString *) dateHour;
- (NSString *) dateMinute;
- (NSString *) dateAmPm;

- (void) addPhoto:(Photo *)photo;
- (void) addNews:(News *)news;
- (void) addSound:(Sound *)sound;
- (void) addVideo:(Video *)video;
- (void) addCategory:(Category *)category;
- (void) removeCategory:(Category *)category;
- (BOOL) hasCategory:(Category *)category;
- (NSString *) categoryNames;
- (NSString *) categoryNamesWithDefaultText:(NSString *)defaultText;

- (Photo *) getFirstPhoto;
- (BOOL) hasRequiredValues;

- (NSComparisonResult)compareByTitle:(Incident *)incident;
- (NSComparisonResult)compareByDate:(Incident *)incident;

@end
