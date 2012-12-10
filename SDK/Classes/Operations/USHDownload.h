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

@class USHMap;
@protocol UshahidiDelegate;
@protocol USHDownloadDelegate;

@interface USHDownload : NSOperation<NSURLConnectionDelegate>

@property (nonatomic, strong, readonly) NSObject<USHDownloadDelegate> *delegate;
@property (nonatomic, strong, readonly) NSObject<UshahidiDelegate> *callback;
@property (nonatomic, strong, readonly) USHMap *map;
@property (nonatomic, strong, readonly) NSMutableData *response;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong, readonly) NSURL *domain;

@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    url:(NSString*)url;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
                    api:(NSString*)api;

- (void) start;
- (void) finish;

@end

@protocol USHDownloadDelegate <NSObject>
 
@optional

- (void) download:(USHDownload*)download started:(USHMap*)map;
- (void) download:(USHDownload*)download connected:(USHMap*)map;
- (void) download:(USHDownload*)download downloaded:(USHMap*)map;
- (void) download:(USHDownload*)download finished:(USHMap*)map error:(NSError*)error;

@end