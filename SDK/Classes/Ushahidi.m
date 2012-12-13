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

#import "Ushahidi.h"
#import "USHDatabase.h"
#import "USHDownloadVersion.h"
#import "USHDownloadReport.h"
#import "USHDownloadCategory.h"
#import "USHDownloadLocation.h"
#import "USHDownloadCheckin.h"
#import "USHUploadReport.h"
#import "USHUploadCheckin.h"
#import "USHUploadComment.h"
#import "USHUploadVideo.h"
#import "USHDownloadPhoto.h"
#import "USHDownloadMaps.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "NSDictionary+USH.h"
#import "USHDownload.h"
#import "USHUpload.h"
#import "USHSynchronize.h"

@interface Ushahidi () <USHSynchronizeDelegate,
                        USHDownloadDelegate,
                        USHUploadDelegate>

@property (strong, nonatomic) NSOperationQueue *synchronize;
@property (strong, nonatomic) NSOperationQueue *uploads;

@end

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(Ushahidi);

@implementation Ushahidi

SYNTHESIZE_SINGLETON_FOR_CLASS(Ushahidi);

NSString * const kUSHSyncDate = @"USHSyncDate";

#pragma mark - Properties

@synthesize synchronize = _synchronize;
@synthesize uploads = _uploads;
@synthesize youtubeUsername = _youtubeUsername;
@synthesize youtubePassword = _youtubePassword;
@synthesize youtubeDeveloperKey = _youtubeDeveloperKey;

#pragma mark - Init

- (id) init {
	if ((self = [super init])) {
        [[USHDatabase sharedInstance] setName:@"Ushahidi"];
        
        self.synchronize = [[[NSOperationQueue alloc] init] autorelease];
        [self.synchronize setMaxConcurrentOperationCount:2];
        [self.synchronize addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
        
        self.uploads = [[[NSOperationQueue alloc] init] autorelease];
        [self.uploads setMaxConcurrentOperationCount:1];
        [self.uploads addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [_synchronize removeObserver:self forKeyPath:@"operations"];
    [_synchronize release];
    [_uploads removeObserver:self forKeyPath:@"operations"];
    [_uploads release];
    [_youtubeUsername release];
    [_youtubePassword release];
    [_youtubeDeveloperKey release];
    [super dealloc];
}

#pragma mark - Sync Operations

- (void) setSyncOperations:(NSInteger)syncOperations {
    [self.synchronize setMaxConcurrentOperationCount:syncOperations];
}

- (NSInteger) syncOperations {
    return self.synchronize.maxConcurrentOperationCount;
}

#pragma mark - Has Maps

- (BOOL) hasMap:(USHMap*)map {
    if (map != nil && map.url != nil) {
         return [[USHDatabase sharedInstance] fetchCountForName:@"Map" query:@"url = %@ && added != nil" param:map.url] > 0;
    }
    return NO;
}

- (BOOL) hasMapWithUrl:(NSString*)url {
    if ([NSString isNilOrEmpty:url] == NO) {
        return [[USHDatabase sharedInstance] fetchCountForName:@"Map" query:@"url = %@ && added != nil" param:url] > 0;
    }
    return NO;
}

#pragma mark - Find Maps

- (BOOL) findMapsWithDelegate:(NSObject<UshahidiDelegate>*)delegate {
    return [self findMapsWithDelegate:delegate radius:nil latitude:nil longitude:nil];
}

- (BOOL) findMapsWithDelegate:(NSObject<UshahidiDelegate>*)delegate radius:(NSString*)radius latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    for (USHMap *map in [[USHDatabase sharedInstance] fetchArrayForName:@"Map" query:@"added = nil" param:nil sort:nil]) {
        [[USHDatabase sharedInstance] remove:map];
    }
    [[USHDatabase sharedInstance] saveChanges];
    DLog(@"Radius:%@ Latitude:%@ Longitude:%@", radius, latitude, longitude);
    NSMutableString *url = [NSMutableString stringWithFormat:@"http://tracker.ushahidi.com/list/?return_vars=url,name,description,discovery_date"];
    if (latitude != nil) {
        [url appendFormat:@"&lat=%@", latitude];
    }
    if (longitude != nil) {
        [url appendFormat:@"&lon=%@", longitude];
    }
    if (radius != nil) {
        [url appendFormat:@"&distance=%@", radius];
        [url appendFormat:@"&units=km"];
    }
    USHDownloadMaps *downloadMaps = [[[USHDownloadMaps alloc] initWithDelegate:self
                                                                      callback:delegate
                                                                           url:url] autorelease];
    [self.synchronize addOperation:downloadMaps];
    return YES;
}

#pragma mark - USHCategory

- (BOOL) dowloadCategoriesWithDelegate:(NSObject<UshahidiDelegate>*)delegate map:(USHMap*)map {
    if (map != nil) {
        USHDownloadCategory *downloadCategory = [[[USHDownloadCategory alloc] initWithDelegate:self
                                                                                      callback:delegate
                                                                                           map:map] autorelease];
        [self.synchronize addOperation:downloadCategory];
    }
    return YES;
}

#pragma mark - USHComment

- (USHComment*) addCommentForReport:(USHReport*)report {
    USHComment *comment = [[USHDatabase sharedInstance] insertItemWithName:@"Comment"];
    comment.date = [NSDate date];
    comment.pending = [NSNumber numberWithBool:YES];
    comment.report = report;
    return comment;
}

- (BOOL) uploadComment:(USHComment*)comment delegate:(NSObject<UshahidiDelegate>*)delegate {
    if (comment != nil) {
        USHUploadComment *uploadComment = [[[USHUploadComment alloc] initWithDelegate:self
                                                                             callback:delegate
                                                                                  map:comment.report.map
                                                                              comment:comment] autorelease];
        [self.synchronize addOperation:uploadComment];
        return YES;   
    }
    return NO;
}

- (BOOL) removeComment:(USHComment*)comment {
    return [[USHDatabase sharedInstance] remove:comment];
}

#pragma mark - USHVideo

- (USHVideo*) addVideoForReport:(USHReport*)report {
    USHVideo *video = [[USHDatabase sharedInstance] insertItemWithName:@"Video"];
    video.pending = [NSNumber numberWithBool:YES];
    video.report = report;
    return video;
}

- (BOOL) removeVideo:(USHVideo*)video {
    return [[USHDatabase sharedInstance] remove:video];
}

#pragma mark - USHReport

- (USHReport *) addReportForMap:(USHMap*)map {
    USHReport *report = [[USHDatabase sharedInstance] insertItemWithName:@"Report"];
    report.date = [NSDate date];
    report.pending = [NSNumber numberWithBool:YES];
    report.map = map;
    return report;
}

- (BOOL) uploadReport:(USHReport*)report delegate:(NSObject<UshahidiDelegate>*)delegate {
    if (report != nil) {
        USHUploadReport *uploadReport = [[[USHUploadReport alloc] initWithDelegate:self
                                                                          callback:delegate
                                                                               map:report.map
                                                                            report:report] autorelease];
        if (report.videos.count > 0) {
            USHUploadVideo *uploadVideo = [[[USHUploadVideo alloc] initWithDelegate:self
                                                                           callback:delegate
                                                                                map:report.map
                                                                             report:report
                                                                                key:self.youtubeDeveloperKey
                                                                           username:self.youtubeUsername
                                                                           password:self.youtubePassword] autorelease];
            [uploadReport addDependency:uploadVideo];
            [self.uploads addOperation:uploadVideo];    
        }
        [self.uploads addOperation:uploadReport];
        return YES;
    }
    return NO;
}

- (BOOL) removeReport:(USHReport*)report {
    return  [[USHDatabase sharedInstance] remove:report] &&
            [[USHDatabase sharedInstance] saveChanges];
}

#pragma mark - USHMap

- (BOOL) addMap:(USHMap*)map {
    if (map != nil) {
        map.added = [NSDate date];
        return [[USHDatabase sharedInstance] saveChanges];
    }
    return NO;
}

- (USHMap*) addMapWithUrl:(NSString*)url title:(NSString*)title {
    if ([NSString isNilOrEmpty:url] == NO && [NSString isNilOrEmpty:title] == NO) {
        USHMap *map = [[USHDatabase sharedInstance] insertItemWithName:@"Map"];
        map.name = title;
        map.url = url;
        map.added = [NSDate date];
        if ([[USHDatabase sharedInstance] saveChanges]) {
            return map;
        }
    }
    return nil;
}

- (USHMap *) mapWithUrl:(NSString *)url {
    return (USHMap*)[[USHDatabase sharedInstance] fetchItemForName:@"Map" query:@"url = %@ && added != nil" param:url];
}

- (BOOL) removeMap:(USHMap*)map {
    return  [[USHDatabase sharedInstance] remove:map] &&
            [[USHDatabase sharedInstance] saveChanges];
}

- (BOOL) removeMapWithUrl:(NSString*)url {
    USHMap *map = [self mapWithUrl:url];
    return  [[USHDatabase sharedInstance] remove:map] &&
            [[USHDatabase sharedInstance] saveChanges];
}

- (NSInteger) numberOfMaps {
    return [[USHDatabase sharedInstance] fetchCountForName:@"Map" query:@"added != nil" param:nil];
}

- (USHMap *) mapAtIndex:(NSInteger)index {
    NSArray *maps = [self maps];
    return [maps objectAtIndex:index];
}

- (NSArray *) maps {
    return [[USHDatabase sharedInstance] fetchArrayForName:@"Map" query:@"added != nil" param:nil sort:@"name", nil];
}

#pragma mark - USHPhoto

- (USHPhoto*) addPhotoForReport:(USHReport*)report {
    USHPhoto *photo = (USHPhoto*)[[USHDatabase sharedInstance] insertItemWithName:@"Photo"];
    photo.report = report;
    return photo;
}

- (BOOL) removePhoto:(USHPhoto*)photo {
    return  [[USHDatabase sharedInstance] remove:photo] &&
            [[USHDatabase sharedInstance] saveChanges];
}

#pragma mark - Synchronize

- (NSDate*) synchronizeDate {
    return (NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kUSHSyncDate];
}

- (NSString*) synchronizeDateWithFormat:(NSString*)format {
    if ([self synchronizeDate] != nil) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:format];
        return [formatter stringFromDate:[self synchronizeDate]];
    }
    return nil;
}

- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate {
    return [self synchronizeWithDelegate:delegate photos:YES maps:NO];
}

- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate photos:(BOOL)photos maps:(BOOL)maps {
    if ([self numberOfMaps] > 0) {
        for (USHMap *map in self.maps) {
            USHSynchronize *synchronize = [[[USHSynchronize alloc] initWithDelegate:self
                                                                           callback:delegate
                                                                                map:map
                                                                             downloadPhotos:photos
                                                                       downloadMaps:maps
                                                                         youtubeKey:self.youtubeDeveloperKey
                                                                    youtubeUsername:self.youtubeUsername
                                                                    youtubePassword:self.youtubePassword] autorelease];
            [self.synchronize addOperation:synchronize];
        }
        return YES;
    }
    return NO;
}

- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate map:(USHMap*)map {
    return [self synchronizeWithDelegate:delegate map:map photos:YES maps:NO];
}

- (BOOL) synchronizeWithDelegate:(NSObject<UshahidiDelegate>*)delegate map:(USHMap*)map photos:(BOOL)photos maps:(BOOL)maps {
    if (map != nil) {
        USHSynchronize *synchronize = [[[USHSynchronize alloc] initWithDelegate:self
                                                                       callback:delegate
                                                                            map:map
                                                                 downloadPhotos:photos
                                                                   downloadMaps:maps
                                                                     youtubeKey:self.youtubeDeveloperKey
                                                                youtubeUsername:self.youtubeUsername
                                                                youtubePassword:self.youtubePassword] autorelease];
        [self.synchronize addOperation:synchronize];
        return YES;
    }
    return NO;
}

#pragma mark - USHDatabase

- (BOOL) saveChanges {
    return  [[USHDatabase sharedInstance] hasChanges] &&
            [[USHDatabase sharedInstance] saveChanges];
}

#pragma mark - USHSynchronizeDelegate

- (void) synchronize:(USHSynchronize*)synchronize started:(USHMap*)map {
    DLog(@"Map:%@", map.name);
    map.syncing = [NSNumber numberWithBool:YES];
    [self saveChanges];
    [synchronize.callback performSelectorOnMainThread:@selector(ushahidi:synchronizing:)
                                        waitUntilDone:YES  
                                          withObjects:self, map, nil];
}

- (void) synchronize:(USHSynchronize*)synchronize finished:(USHMap*)map error:(NSError*)error {
    if (error != nil) {
        DLog(@"Map:%@ Error:%@", map.name, [error description]);
    }
    else {
        DLog(@"Map:%@", map.name);
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUSHSyncDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    map.syncing = [NSNumber numberWithBool:NO];
    map.synced = [NSDate date];
    [self saveChanges];
    [synchronize.callback performSelectorOnMainThread:@selector(ushahidi:synchronized:error:)
                                        waitUntilDone:YES  
                                          withObjects:self, map, error, nil];
    [synchronize.callback performSelectorOnMainThread:@selector(ushahidi:synchronization:)
                                        waitUntilDone:YES
                                          withObjects:self, (self.synchronize.operationCount-1), nil];
}

#pragma mark - USHDownloadDelegate

- (void) download:(USHDownload*)download started:(USHMap*)map {
    DLog(@"%@ Map:%@", download.class, map.name);
}

- (void) download:(USHDownload*)download connected:(USHMap*)map {
    DLog(@"%@ Map:%@", download.class, map.name);
}

- (void) download:(USHDownload*)download downloaded:(USHMap*)map {
    if ([download isKindOfClass:[USHDownloadReport class]]) {
        USHDownloadReport *downloadReport = (USHDownloadReport*)download;
        DLog(@"USHDownloadReport Map:%@ Report:%@", map.name, downloadReport.report.title);
        [download.callback performSelectorOnMainThread:@selector(ushahidi:downloaded:report:)
                                         waitUntilDone:YES
                                           withObjects:self, map, downloadReport.report, nil];
    }
    else if ([download isKindOfClass:[USHDownloadCategory class]]) {
        USHDownloadCategory *downloadCategory = (USHDownloadCategory*)download;
        DLog(@"USHDownloadCategory Map:%@ Category:%@", map.name, downloadCategory.category.title);
        [download.callback performSelectorOnMainThread:@selector(ushahidi:downloaded:category:)
                                         waitUntilDone:YES
                                           withObjects:self, map, downloadCategory.category, nil];
    }
    else if ([download isKindOfClass:[USHDownloadLocation class]]) {
        USHDownloadLocation *downloadLocation = (USHDownloadLocation*)download;
        DLog(@"USHDownloadLocation Map:%@ Location:%@", map.name, downloadLocation.location.name);
        [download.callback performSelectorOnMainThread:@selector(ushahidi:downloaded:location:)
                                         waitUntilDone:YES
                                           withObjects:self, map, downloadLocation.location, nil];
    }
    else if ([download isKindOfClass:[USHDownloadCheckin class]]) {
        USHDownloadCheckin *downloadCheckin = (USHDownloadCheckin*)download;
        DLog(@"USHDownloadCheckin Map:%@ Checkin:%@", map.name, downloadCheckin.checkin.message);
        [download.callback performSelectorOnMainThread:@selector(ushahidi:downloaded:checkin:)
                                         waitUntilDone:YES
                                           withObjects:self, map, downloadCheckin.checkin, nil];
    }
    else if ([download isKindOfClass:[USHDownloadPhoto class]]) {
        USHDownloadPhoto *downloadPhoto = (USHDownloadPhoto*)download;
        DLog(@"USHDownloadPhoto Map:%@ Photo:%@", downloadPhoto.map.name, downloadPhoto.photo.url);
        [download.callback performSelectorOnMainThread:@selector(ushahidi:downloaded:photo:)
                                         waitUntilDone:YES
                                           withObjects:self, map, downloadPhoto.photo, nil];
    }
    else if ([download isKindOfClass:[USHDownloadMaps class]]) {
        USHDownloadMaps *downloadMaps = (USHDownloadMaps*)download;
        DLog(@"USHDownloadMaps Map:%@", downloadMaps.map.name);
    }
    else {
        DLog(@"Unknown:%@ Map:%@", download.class, map.name);
    }
}

- (void) download:(USHDownload*)download finished:(USHMap*)map error:(NSError*)error {
    if (error != nil) {
        DLog(@"%@ Map:%@ Error:%@", download.class, map.name, [error description]);
        map.error = error.localizedDescription;
        [[USHDatabase sharedInstance] saveChanges];
        if ([download isKindOfClass:[USHDownloadVersion class]]) {
            [download.callback performSelectorOnMainThread:@selector(ushahidi:synchronized:error:)
                                             waitUntilDone:YES
                                               withObjects:self, map, error, nil];
        }
    }
    else if ([download isKindOfClass:[USHDownloadVersion class]]) {
        DLog(@"USHDownloadVersion Map:%@ Version:%@ Checkins:%@ OpenGeoSMS:%@", map.name,  map.version, map.checkin, map.opengeosms);
        [self saveChanges];
    }
    else if ([download isKindOfClass:[USHDownloadMaps class]]) {
        NSArray *maps = [[USHDatabase sharedInstance] fetchArrayForName:@"Map" query:@"added = nil" param:nil sort:nil];
        DLog(@"USHDownloadMaps:%d", maps.count);
        [download.callback performSelectorOnMainThread:@selector(ushahidi:maps:)
                                         waitUntilDone:YES
                                           withObjects:self, maps, nil];
    }
    else {
        DLog(@"%@ Map:%@", download.class, map.name);
        map.error = nil;
        [self saveChanges];
    }
    
}

- (void) upload:(USHUpload*)upload started:(USHMap*)map {
    DLog(@"%@ %@", upload.class, map.name);
}

- (void) upload:(USHUpload*)upload connected:(USHMap*)map {
    DLog(@"%@ %@", upload.class, map.name);
}

- (void) upload:(USHUpload*)upload uploaded:(USHMap*)map {
    DLog(@"%@ %@", upload.class, map.name);
}

- (void) upload:(USHUpload*)upload finished:(USHMap*)map error:(NSError*)error {
    DLog(@"%@ %@", upload.class, map.name);
    if ([upload isKindOfClass:[USHUploadReport class]]) {
        USHUploadReport *uploadReport = (USHUploadReport*)upload;
        [upload.callback performSelectorOnMainThread:@selector(ushahidi:uploaded:report:error:)
                                       waitUntilDone:YES
                                         withObjects:self, map, uploadReport.report, error, nil];
    }
    else if ([upload isKindOfClass:[USHUploadCheckin class]]) {
        USHUploadCheckin *uploadComment = (USHUploadCheckin*)upload;
        [upload.callback performSelectorOnMainThread:@selector(ushahidi:uploaded:checkin:error:)
                                       waitUntilDone:YES
                                         withObjects:self, map, uploadComment.checkin, error, nil];
    }
    else if ([upload isKindOfClass:[USHUploadComment class]]) {
        USHUploadComment *uploadComment = (USHUploadComment*)upload;
        [upload.callback performSelectorOnMainThread:@selector(ushahidi:uploaded:comment:error:)
                                       waitUntilDone:YES
                                         withObjects:self, map, uploadComment.comment, error, nil];
    }
    else if ([upload isKindOfClass:[USHUploadVideo class]]) {
        USHUploadVideo *uploadVideo = (USHUploadVideo*)upload;
        [upload.callback performSelectorOnMainThread:@selector(ushahidi:uploaded:video:error:)
                                       waitUntilDone:YES
                                         withObjects:self, map, uploadVideo.video, error, nil];
    }
}

#pragma mark - NSOperationQueue

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.synchronize) {
        DLog(@"Synchronize:%d", self.synchronize.operationCount);
    }
    else if (object == self.uploads) {
        DLog(@"Uploads:%d", self.uploads.operationCount);
    }
}

@end
