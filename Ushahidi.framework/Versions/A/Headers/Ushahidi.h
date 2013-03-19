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
#import "SynthesizeSingleton.h"

#import "USHMap.h"
#import "USHReport.h"
#import "USHCheckin.h"
#import "USHUser.h"
#import "USHCategory.h"
#import "USHLocation.h"
#import "USHComment.h"
#import "USHPhoto.h"
#import "USHVideo.h"
#import "USHSound.h"
#import "USHNews.h"
#import "USHVideo.h"

@class USHMap;
@protocol UshahidiDelegate;

@interface Ushahidi : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(Ushahidi);

@property (nonatomic, assign) NSInteger syncOperations;
@property (nonatomic, strong) NSString *youtubeUsername;
@property (nonatomic, strong) NSString *youtubePassword;
@property (nonatomic, strong) NSString *youtubeDeveloperKey;

- (BOOL) hasMap:(USHMap*)map;
- (BOOL) hasMapWithUrl:(NSString*)url;

- (BOOL) addMap:(USHMap*)map;
- (USHMap*) addMapWithUrl:(NSString*)url title:(NSString*)title;

- (BOOL) removeMap:(USHMap*)map;
- (BOOL) removeMapWithUrl:(NSString*)url;

- (NSDate*) synchronizeDate;
- (NSString*) synchronizeDateWithFormat:(NSString*)format;

- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate;
- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate photos:(BOOL)photos maps:(BOOL)maps limit:(NSInteger)limit;

- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate map:(USHMap*)map;
- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate map:(USHMap*)map photos:(BOOL)photos maps:(BOOL)maps limit:(NSInteger)limit;

- (BOOL) findMapsWithDelegate:(NSObject<UshahidiDelegate>*)delegate;
- (BOOL) findMapsWithDelegate:(NSObject<UshahidiDelegate>*)delegate radius:(NSString*)radius latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude;

- (USHComment*) addCommentForReport:(USHReport*)report;
- (BOOL) uploadComment:(USHComment*)comment delegate:(NSObject<UshahidiDelegate>*)delegate;
- (BOOL) removeComment:(USHComment*)comment;

- (USHMap *) mapWithUrl:(NSString *)url;
- (USHMap *) mapAtIndex:(NSInteger)index;

- (NSArray *) maps;
- (NSInteger) numberOfMaps;

- (USHReport *) addReportForMap:(USHMap*)map;
- (BOOL) uploadReport:(USHReport*)report delegate:(NSObject<UshahidiDelegate>*)delegate;
- (BOOL) removeReport:(USHReport*)report;

- (USHPhoto*) addPhotoForReport:(USHReport*)report;
- (BOOL) removePhoto:(USHPhoto*)photo;

- (USHVideo*) addVideoForReport:(USHReport*)report;
- (BOOL) removeVideo:(USHVideo*)video;

- (BOOL) dowloadCategoriesWithDelegate:(NSObject<UshahidiDelegate>*)delegate map:(USHMap*)map;

- (BOOL) saveChanges;

@end

@protocol UshahidiDelegate <NSObject>

@optional

- (void) ushahidi:(Ushahidi*)ushahidi maps:(NSArray*)maps;

- (void) ushahidi:(Ushahidi*)ushahidi synchronizing:(USHMap*)map;
- (void) ushahidi:(Ushahidi*)ushahidi synchronized:(USHMap*)map error:(NSError*)error;
- (void) ushahidi:(Ushahidi*)ushahidi synchronization:(NSInteger)remaining;

- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map report:(USHReport*)report;
- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map checkin:(USHCheckin*)checkin;
- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map category:(USHCategory*)category;
- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map location:(USHLocation*)location;
- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map photo:(USHPhoto*)photo;
- (void) ushahidi:(Ushahidi*)ushahidi downloaded:(USHMap*)map map:(UIImage*)map;

- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map report:(USHReport*)report error:(NSError*)error;
- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map checkin:(USHCheckin*)checkin error:(NSError*)error;
- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map comment:(USHComment*)comment error:(NSError*)error;
- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map video:(USHVideo*)video error:(NSError*)error;

@end