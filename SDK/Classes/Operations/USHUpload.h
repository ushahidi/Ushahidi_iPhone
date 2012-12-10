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
@protocol USHUploadDelegate;

@interface USHUpload : NSOperation<NSURLConnectionDelegate>

@property (nonatomic, strong, readonly) NSObject<USHUploadDelegate> *delegate;
@property (nonatomic, strong, readonly) NSObject<UshahidiDelegate> *callback;
@property (nonatomic, strong, readonly) USHMap *map;

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;
@property (nonatomic, strong, readonly) NSMutableData *response;

@property (nonatomic, strong, readwrite) NSString *url;

@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

- (id) initWithDelegate:(NSObject<USHUploadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
                    url:(NSString*)url
               username:(NSString*)username
               password:(NSString*)password;

- (void) setValue:(NSObject*)value forKey:(NSString*)key;
- (void) setValue:(NSObject*)value forKey:(NSString*)key type:(NSString*)type;
- (void) setValue:(NSObject*)value forKey:(NSString*)key type:(NSString*)type file:(NSString*)file;
- (void) setHeader:(NSString*)value forKey:(NSString*)key;

- (void) prepare;
- (void) start;
- (void) finish;

@end

@protocol USHUploadDelegate <NSObject>

@optional

- (void) upload:(USHUpload*)upload started:(USHMap*)map;
- (void) upload:(USHUpload*)upload connected:(USHMap*)map;
- (void) upload:(USHUpload*)upload uploaded:(USHMap*)map;
- (void) upload:(USHUpload*)upload finished:(USHMap*)map error:(NSError*)error;

@end