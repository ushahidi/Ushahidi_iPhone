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
@protocol USHUploadDelegate;
@protocol USHSynchronizeDelegate;

@interface USHSynchronize : NSOperation

@property (nonatomic, strong, readonly) NSObject<USHSynchronizeDelegate> *delegate;
@property (nonatomic, strong, readonly) NSObject<UshahidiDelegate> *callback;
@property (nonatomic, assign, readonly) BOOL photos;
@property (nonatomic, assign, readonly) BOOL maps;

@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

- (id) initWithDelegate:(NSObject<USHSynchronizeDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
         downloadPhotos:(BOOL)downloadPhotos
           downloadMaps:(BOOL)downloadMaps
             youtubeKey:(NSString*)youtubeKey
        youtubeUsername:(NSString*)youtubeUsername
        youtubePassword:(NSString*)youtubePassword;

- (void) start;
- (void) finish;

@end

@protocol USHSynchronizeDelegate <USHDownloadDelegate, USHUploadDelegate>

@optional

- (void) synchronize:(USHSynchronize*)synchronize started:(USHMap*)map;
- (void) synchronize:(USHSynchronize*)synchronize finished:(USHMap*)map error:(NSError*)error;

@end