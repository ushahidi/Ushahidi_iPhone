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

#import "USHSynchronize.h"
#import "Ushahidi.h"
#import "USHMap.h"
#import "USHDownload.h"
#import "USHDownloadVersion.h"
#import "USHDownloadReport.h"
#import "USHDownloadCategory.h"
#import "USHDownloadCheckin.h"
#import "USHDownloadLocation.h"
#import "USHDownloadPhoto.h"
#import "USHDownloadMap.h"
#import "USHUpload.h"
#import "USHUploadReport.h"
#import "USHUploadCheckin.h"
#import "USHUploadComment.h"
#import "USHUploadVideo.h"

#import "NSObject+USH.h"

@interface USHSynchronize ()

@property (nonatomic, strong, readwrite) NSObject<USHSynchronizeDelegate> *delegate;
@property (nonatomic, strong, readwrite) NSObject<UshahidiDelegate> *callback;

@property (nonatomic, assign, readwrite) BOOL photos;
@property (nonatomic, assign, readwrite) BOOL maps;

@property (nonatomic, strong) NSOperationQueue *operations;
@property (nonatomic, strong) NSOperationQueue *images;
@property (nonatomic, strong) USHMap *map;

@property (nonatomic, strong) NSString *youtubeKey;
@property (nonatomic, strong) NSString *youtubeUsername;
@property (nonatomic, strong) NSString *youtubePassword;

@end

@implementation USHSynchronize

@synthesize map = _map;
@synthesize photos = _photos;
@synthesize maps = _maps;
@synthesize operations = _operations;
@synthesize images = _images;
@synthesize delegate = _delegate;
@synthesize callback = _callback;

@synthesize youtubeKey = _youtubeKey;
@synthesize youtubeUsername = _youtubeUsername;
@synthesize youtubePassword = _youtubePassword;

@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

#pragma mark - NSObject

- (id) initWithDelegate:(NSObject<USHSynchronizeDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
         downloadPhotos:(BOOL)photos
           downloadMaps:(BOOL)maps
             youtubeKey:(NSString*)youtubeKey
        youtubeUsername:(NSString*)youtubeUsername
        youtubePassword:(NSString*)youtubePassword {
    if ((self = [super init])) {
        self.delegate = delegate;
        self.callback = callback;
        self.map = map;
        self.photos = photos;
        self.maps = maps;
        
        self.youtubeKey = youtubeKey;
        self.youtubeUsername = youtubeUsername;
        self.youtubePassword = youtubePassword;
        
        self.operations = [[[NSOperationQueue alloc] init] autorelease];
        [self.operations setMaxConcurrentOperationCount:1];
        [self.operations addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
        
        self.images = [[[NSOperationQueue alloc] init] autorelease];
        [self.images setMaxConcurrentOperationCount:1];
        [self.images addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    DLog(@"%@", self.map.url);
    [_callback release];
    [_delegate release];
    [_operations removeObserver:self forKeyPath:@"operations"];
    [_operations release];
    [_images removeObserver:self forKeyPath:@"operations"];
    [_images release];
    [_map release];
    [_youtubeKey release];
    [_youtubeUsername release];
    [_youtubePassword release];
    [super dealloc];
}

#pragma mark - NSOperation

- (BOOL) isConcurrent {
    return YES;
}

- (void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
        return;
    }
    DLog(@"%@", self.map.url);
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.delegate performSelector:@selector(synchronize:started:)
                       withObjects:self, self.map, nil];
    
    for (USHReport *report in self.map.reportsPending) {
        USHUploadReport *uploadReport = [[[USHUploadReport alloc] initWithDelegate:self.delegate
                                                                          callback:self.callback
                                                                               map:self.map
                                                                            report:report] autorelease];
        if (report.videos.count > 0) {
            USHUploadVideo *uploadVideo = [[[USHUploadVideo alloc] initWithDelegate:self.delegate
                                                                           callback:self.callback
                                                                                map:self.map
                                                                             report:report
                                                                                key:self.youtubeKey
                                                                           username:self.youtubeUsername
                                                                           password:self.youtubePassword] autorelease];
            [uploadReport addDependency:uploadVideo];
            [self.operations addOperation:uploadVideo];
        }
        [self.operations addOperation:uploadReport];
    }
    for (USHComment *comment in self.map.commentsPending) {
        USHUploadComment *uploadComment = [[[USHUploadComment alloc] initWithDelegate:self.delegate
                                                                             callback:self.callback
                                                                                  map:self.map
                                                                              comment:comment] autorelease];
        [self.operations addOperation:uploadComment];
    }
    USHDownloadVersion *downloadVersion = [[[USHDownloadVersion alloc] initWithDelegate:self.delegate
                                                                               callback:self.callback
                                                                                    map:self.map] autorelease];
    [self.operations addOperation:downloadVersion];
    
    USHDownloadReport *downloadReport = [[[USHDownloadReport alloc] initWithDelegate:self.delegate
                                                                            callback:self.callback
                                                                                 map:self.map] autorelease];
    [downloadReport addDependency:downloadVersion];
    [self.operations addOperation:downloadReport];
    
    USHDownloadCategory *downloadCategory = [[[USHDownloadCategory alloc] initWithDelegate:self.delegate
                                                                                  callback:self.callback
                                                                                       map:self.map] autorelease];
    [downloadCategory addDependency:downloadReport];
    [self.operations addOperation:downloadCategory];
    
    USHDownloadLocation *downloadLocation = [[[USHDownloadLocation alloc] initWithDelegate:self.delegate
                                                                                  callback:self.callback
                                                                                       map:self.map] autorelease];
    [downloadLocation addDependency:downloadCategory];
    [self.operations addOperation:downloadLocation];
    
    if ([self.map.checkin boolValue]) {
        USHDownloadCheckin *downloadCheckin = [[[USHDownloadCheckin alloc] initWithDelegate:self.delegate
                                                                                   callback:self.callback
                                                                                        map:self.map] autorelease];
        [downloadCheckin addDependency:downloadLocation];
        [self.operations addOperation:downloadCheckin];
    }
}

- (void) finish {
    DLog(@"%@", self.map.url);
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.operations && [keyPath isEqualToString:@"operations"]) {
        //DLog(@"%@ Operations:%d", self.map.name, self.operations.operationCount);
        if (self.operations.operationCount == 0) {
            BOOL hasDownloads = NO;
            if (self.photos) {
                for (USHReport *report in self.map.reports) {
                    for (USHPhoto *photo in report.photos) {
                        if (photo.url != nil && photo.image == nil) {
                            hasDownloads = YES;
                            DLog(@"Image:%@", photo.url);
                            USHDownloadPhoto *downloadPhoto = [[[USHDownloadPhoto alloc] initWithDelegate:self.delegate
                                                                                                 callback:self.callback
                                                                                                      map:self.map
                                                                                                   report:report
                                                                                                    photo:photo] autorelease];
                            [self.images addOperation:downloadPhoto];
                        }
                    }
                }
            }
            if (self.maps){
                for (USHReport *report in self.map.reports) {
                    if (report.snapshot == nil) {
                        hasDownloads = YES;
                        DLog(@"Map:%@", report.url);
                        USHDownloadMap *downloadMap = [[[USHDownloadMap alloc] initWithDelegate:self.delegate
                                                                                       callback:self.callback
                                                                                            map:self.map
                                                                                         report:report] autorelease];
                        [self.images addOperation:downloadMap];
                    }
                }
            }
            if (self.images.operationCount == 0 && hasDownloads == NO) {
                [self.delegate performSelector:@selector(synchronize:finished:error:)
                                   withObjects:self, self.map, nil, nil];
                [self finish];
            }
        }
    }
    else if (object == self.images && [keyPath isEqualToString:@"operations"]) {
        //DLog(@"%@ Images:%d", self.map.name, self.operations.operationCount);
        if (self.operations.operationCount == 0 && self.images.operationCount == 0) {
            [self.delegate performSelector:@selector(synchronize:finished:error:)
                               withObjects:self, self.map, nil, nil];
            [self finish];
        }
    }
}

@end
