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
#import <CoreData/CoreData.h>

@class USHCategory, USHComment, USHMap, USHNews, USHPhoto, USHSound, USHVideo;

@interface USHReport : NSManagedObject

@property (nonatomic, retain) NSDate *viewed;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSData *snapshot;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *pending;
@property (nonatomic, retain) NSNumber *verified;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) USHMap *map;
@property (nonatomic, retain) NSSet *news;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *sounds;
@property (nonatomic, retain) NSSet *videos;
@property (nonatomic, retain) NSNumber *starred;

@property (nonatomic, retain) NSString *authorFirst;
@property (nonatomic, retain) NSString *authorLast;
@property (nonatomic, retain) NSString *authorEmail;

@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSString *timeString;
@property (nonatomic, readonly) NSString *dateTimeString;
@property (nonatomic, readonly) NSString *dateDayMonthYear;
@property (nonatomic, readonly) NSString *date12Hour;
@property (nonatomic, readonly) NSString *date24Hour;
@property (nonatomic, readonly) NSString *dateMinute;
@property (nonatomic, readonly) NSString *dateAmPm;

- (NSString *) dateFormatted:(NSString*)format;

- (NSString *) categoryTitles:(NSString*)separator;
- (NSString *) categoryIDs:(NSString*)separator;

- (BOOL) containsCategory:(USHCategory*)category;

- (NSArray *) commentsSortedBy:(NSString*)sort ascending:(BOOL)ascending;
- (NSArray *) commentsSortedByDate;

- (USHVideo *) videoAtIndex:(NSInteger)index;
- (USHNews *) newsAtIndex:(NSInteger)index;
- (USHPhoto *) photoAtIndex:(NSInteger)index;

@end

@interface USHReport (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(USHCategory *)value;
- (void)removeCategoriesObject:(USHCategory *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;
- (void)addCommentsObject:(USHComment *)value;
- (void)removeCommentsObject:(USHComment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;
- (void)addNewsObject:(USHNews *)value;
- (void)removeNewsObject:(USHNews *)value;
- (void)addNews:(NSSet *)values;
- (void)removeNews:(NSSet *)values;
- (void)addPhotosObject:(USHPhoto *)value;
- (void)removePhotosObject:(USHPhoto *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;
- (void)addSoundsObject:(USHSound *)value;
- (void)removeSoundsObject:(USHSound *)value;
- (void)addSounds:(NSSet *)values;
- (void)removeSounds:(NSSet *)values;
- (void)addVideosObject:(USHVideo *)value;
- (void)removeVideosObject:(USHVideo *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end
