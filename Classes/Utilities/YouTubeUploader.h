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
#import "ASIFormDataRequest.h"

@class YouTubeUploader;

@protocol YoutubeUploaderDelegate <NSObject>

- (void)youtubeUploaderDidStart:(YouTubeUploader *)uploader;
- (void)youtubeUploaderDidFail:(YouTubeUploader *)uploader withError:(NSString *)error;
- (void)youtubeUploaderDidFinish:(YouTubeUploader *)uploader withAddress:(NSString *)address;

@end

@interface YouTubeUploader : NSObject <NSXMLParserDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate>

@property (nonatomic, retain) NSString* authToken;
@property (nonatomic, retain) NSString* uploadURL;
@property (nonatomic, retain) NSString* uploadToken;

@property (nonatomic, retain) NSString* source;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;

@property (nonatomic, retain) id <YoutubeUploaderDelegate> delegate;

-(BOOL)uploadVideo:(NSString*)filepath;

@end
