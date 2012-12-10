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

#import "USHUploadVideo.h"
#import "USHUploadJSON.h"
#import "USHMap.h"
#import "USHReport.h"
#import "USHVideo.h"
#import "NSString+USH.h"
#import "NSObject+USH.h"
#import "NSError+USH.h"
#import "NSURL+USH.h"
#import "Ushahidi.h"

@interface USHUploadVideo ()

@property (strong, nonatomic, readwrite) USHVideo *video;
@property (strong, nonatomic, readwrite) USHReport *report;
@property (strong, nonatomic, readwrite) NSString *authToken;
@property (strong, nonatomic, readwrite) NSString *uploadURL;
@property (strong, nonatomic, readwrite) NSString *uploadToken;
@property (strong, nonatomic, readwrite) NSString *key;
@property (strong, nonatomic, readwrite) NSString *username;

@end

@implementation USHUploadVideo

@synthesize report = _report;
@synthesize video = _video;
@synthesize authToken = _authToken;
@synthesize uploadURL = _uploadURL;
@synthesize uploadToken = _uploadToken;
@synthesize key = _key;

- (id) initWithDelegate:(NSObject<USHUploadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map
                 report:(USHReport*)report
                    key:(NSString*)key
               username:(NSString*)username
               password:(NSString*)password {
    if ((self = [super initWithDelegate:delegate
                               callback:callback
                                    map:map
                                    url:@"http://uploads.gdata.youtube.com/feeds/api/users/default/uploads"
                               username:username
                               password:password])) {
        self.report = report;
        self.video = report.videos.allObjects.lastObject;
        self.key = key;
    }
    return self;
}

- (void) prepare {
    if ([self loginUser] && [self prepareVideo]) {
        self.url = [NSString stringWithFormat:@"%@?nexturl=%@", self.uploadURL, self.map.url];
        [self setValue:self.uploadToken forKey:@"token"];
        [self setValue:self.video.data forKey:@"file" type:@"application/octet-stream"];
    }
    else {
        NSError *error = [NSError errorWithDomain:self.map.url
                                             code:NSURLErrorUserAuthenticationRequired
                                          message:NSLocalizedString(@"Unable To Authenticate", nil)];
        [self.delegate performSelector:@selector(upload:finished:error:)
                           withObjects:self, self.map, error, nil];
        [self finish];
    }
}

- (BOOL) loginUser {
    NSURL *url = [NSURL URLWithString:@"https://www.google.com/accounts/ClientLogin"];
    NSString *params = [NSString stringWithFormat:@"Email=%@&Passwd=%@&source=Ushahidi&service=youtube", self.username, self.password];
    DLog(@"URL:%@ Params:%@", url, params);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (response != nil) {
        NSString *responseText = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        NSArray *lines = [responseText componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            if ([line hasPrefix:@"Auth="]) {
                self.authToken = [line stringByReplacingOccurrencesOfString:@"Auth=" withString:@""];
                DLog(@"%@", self.authToken);
                return YES;
            }
        }
        DLog(@"Response:%@", responseText);
    }
    else if (error) {
        [self.delegate performSelector:@selector(upload:finished:error:)
                           withObjects:self, self.map, error, nil];
    }
    return NO;
}

- (BOOL) prepareVideo {
    NSString *videoTitle = [NSString stringWithFormat:@"%@ %@", self.map.name, self.report.title];
    NSString *videoDescription = self.report.desc;
    NSString *videoCategory = @"Nonprofit";
    NSString *videoKeywords = [NSString stringWithFormat:@"Ushahidi"];
    NSString *xml = [NSString stringWithFormat:
                     @"<?xml version=\"1.0\"?>"
                     @"<entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\">"
                     @"<media:group>"
                     @"<media:title type=\"plain\">%@</media:title>"
                     @"<media:description type=\"plain\">%@</media:description>"
                     @"<media:category scheme=\"http://gdata.youtube.com/schemas/2007/categories.cat\">%@</media:category>"
                     @"<media:keywords>%@</media:keywords>"
                     @"</media:group>"
                     @"</entry>", videoTitle, videoDescription, videoCategory, videoKeywords];
    NSURL *url = [NSURL URLWithString:@"https://gdata.youtube.com/action/GetUploadToken"];
    DLog(@"URL:%@ XML:%@", url, xml);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"GoogleLogin auth=\"%@\"", self.authToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"2" forHTTPHeaderField:@"GData-Version"];
    [request setValue:[NSString stringWithFormat:@"key=%@", self.key] forHTTPHeaderField:@"X-GData-Key"];
    [request setValue:@"application/atom+xml; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%u", [xml length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *error = nil;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    if (response != nil) {
        NSString *responseText = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        if ([responseText rangeOfString:@"<response><url>"].location != NSNotFound) {
            self.uploadURL = [[[[responseText componentsSeparatedByString:@"<response><url>"] objectAtIndex:1] componentsSeparatedByString:@"</url><token>"] objectAtIndex:0];
            self.uploadToken = [[[[responseText componentsSeparatedByString:@"</url><token>"] objectAtIndex:1] componentsSeparatedByString:@"</token></response>"] objectAtIndex:0];
            DLog(@"URL:%@", self.uploadURL);
            DLog(@"Token:%@", self.uploadToken);
            return YES;
        }
        else if ([responseText rangeOfString:@"NoLinkedYouTubeAccount"].location != NSNotFound) {
            error = [NSError errorWithDomain:self.map.url
                                        code:NSURLErrorUserAuthenticationRequired
                                     message:NSLocalizedString(@"No YouTube Linked Account", nil)];
        }
        else {
            DLog(@"Response: %@", responseText);
            error = [NSError errorWithDomain:self.map.url
                                        code:NSURLErrorUserAuthenticationRequired
                                     message:NSLocalizedString(@"User Authentication Failed", nil)];
        }
    }
    if (error != nil) {
        [self.delegate performSelector:@selector(upload:finished:error:)
                           withObjects:self, self.map, error, nil];
    }
    return NO;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    NSDictionary *parameters = [request.URL parameterDictionary];
    if (parameters != nil && [parameters objectForKey:@"id"] != nil) {
        self.video.url = [NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",
                          [parameters objectForKey:@"id"]];
        [[Ushahidi sharedInstance] saveChanges];
        return nil;
    }
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@", connection.currentRequest.URL);
    if (self.video.url != nil) {
        DLog(@"%@", self.video.url);
        [self.delegate performSelector:@selector(upload:uploaded:)
                           withObjects:self, self.map, nil];
        [self.delegate performSelector:@selector(upload:finished:error:)
                           withObjects:self, self.map, nil, nil];
    }
    else {
        DLog(@"No Video URL");
    }
    [self finish];
}

- (void)dealloc {
    [_report release];
    [_video release];
    [_authToken release];
    [_uploadToken release];
    [_uploadURL release];
    [_key release];
    [super dealloc];
}

@end
