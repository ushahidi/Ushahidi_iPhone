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

#import "USHUpload.h"
#import "USHMap.h"
#import "Ushahidi.h"
#import "NSError+USH.h"
#import "NSString+USH.h"
#import "NSObject+USH.h"
#import "NSData+USH.h"

@interface USHUpload ()

@property (nonatomic, strong, readwrite) NSObject<USHUploadDelegate> *delegate;
@property (nonatomic, strong, readwrite) NSObject<UshahidiDelegate> *callback;
@property (nonatomic, strong, readwrite) USHMap *map;
@property (nonatomic, strong, readwrite) NSMutableData *response;
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *password;

@property (nonatomic, strong, readwrite) NSMutableDictionary *data;
@property (nonatomic, strong, readwrite) NSMutableDictionary *headers;
@property (nonatomic, strong, readwrite) NSMutableDictionary *types;
@property (nonatomic, strong, readwrite) NSMutableDictionary *files;

@end

@implementation USHUpload

@synthesize delegate = _delegate;
@synthesize callback = _callback;
@synthesize url = _url;
@synthesize map = _map;
@synthesize data = _data;
@synthesize types = _types;
@synthesize files = _files;
@synthesize headers = _headers;
@synthesize response = _response;
@synthesize username = _username;
@synthesize password = _password;

@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

- (id) initWithDelegate:(NSObject<USHUploadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
                    url:(NSString*)url
               username:(NSString*)username
               password:(NSString*)password {
    if ([super init]) {
        self.delegate = delegate;
        self.callback = callback;
        self.map = map;
        self.url = url;
        self.username = username;
        self.password = password;
        self.data = [NSMutableDictionary dictionary];
        self.headers = [NSMutableDictionary dictionary];
        self.types = [NSMutableDictionary dictionary];
        self.files = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    [_delegate release];
    [_callback release];
    [_map release];
    [_url release];
    [_response release];
    [_data release];
    [_types release];
    [_files release];
    [_headers release];
    [_username release];
    [_password release];
    [super dealloc];
}

- (void) setValue:(NSObject*)value forKey:(NSString*)key {
    [self setValue:value forKey:key type:nil file:nil];
}

- (void) setValue:(NSObject*)value forKey:(NSString*)key type:(NSString*)type {
    [self setValue:value forKey:key type:type file:nil];
}

- (void) setValue:(NSObject*)value forKey:(NSString*)key type:(NSString*)type file:(NSString*)file {
    if (key != nil && value != nil) {
        if ([value isKindOfClass:NSData.class]) {
            DLog(@"%@=NSData", key);
        }
        else {
            DLog(@"%@=%@", key, value);
        }
        [self.data setValue:value forKey:key];
    }
    if (key != nil && type != nil) {
        [self.types setValue:type forKey:key];
    }
    if (key != nil && file != nil) {
        [self.files setValue:file forKey:key];
    }
}

- (void) setHeader:(NSString*)value forKey:(NSString*)key {
    if (key != nil && value != nil) {
        [self.headers setValue:value forKey:key];
    }
}

- (BOOL) isMultiPartFormData {
    for (NSString *key in self.data.allKeys) {
        NSObject *value = [self.data objectForKey:key];
        if ([value isKindOfClass:NSData.class]) {
            return YES;
        }
        else if ([value isKindOfClass:UIImage.class]) {
            return YES;
        }
    }
    return NO;
}

- (void) prepare {
    //Child classes have option to implement custom functionality prior to NSMutableURLRequest
}

- (void) success {
    //Child can override
}

- (void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
        return;
    }
    DLog(@"%@ %@", self.class, self.url);
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.delegate performSelector:@selector(upload:started:)
                       withObjects:self, self.map, nil];
    [self prepare];
    DLog(@"POST:%@", self.url);
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    if ([NSString isNilOrEmpty:self.username] == NO &&
        [NSString isNilOrEmpty:self.password] == NO) {
        NSString *credentials = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
        NSData *encoded = [credentials dataUsingEncoding:NSASCIIStringEncoding];
        NSString *base64 = [encoded base64EncodingWithLineLength:80];
        NSString *authorization = [NSString stringWithFormat:@"Basic %@", base64];
        [request setValue:authorization forHTTPHeaderField:@"Authorization"];
    }
    if ([self isMultiPartFormData]) {
        DLog(@"isMultiPartFormData = YES");
        NSString *boundary = [[NSString stringWithUUID] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSMutableData *httpBody = [NSMutableData data];
        for (NSString *key in self.data.allKeys) {
            NSObject *value = [self.data objectForKey:key];
            [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            if ([value isKindOfClass:NSData.class]) {
                NSData *data = (NSData*)value;
                NSString *filename = nil;
                if ([self.files objectForKey:key] != nil) {
                    filename = [self.files objectForKey:key];
                }
                else {
                    filename = [key stringByReplacingOccurrencesOfString:@"[]" withString:@""];
                }
                NSString *contentDisposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename];
                [httpBody appendData:[contentDisposition dataUsingEncoding:NSUTF8StringEncoding]];
                if ([self.types objectForKey:key] != nil) {
                    NSString *contentType = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self.types objectForKey:key]];
                    [httpBody appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
                }
                else {
                    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                [httpBody appendData:data];
                [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
            else {
                NSString *string = (NSString *)value;
                [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                if ([self.types objectForKey:key] != nil) {
                    NSString *contentType = [NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", [self.types objectForKey:key]];
                    [httpBody appendData:[contentType dataUsingEncoding:NSUTF8StringEncoding]];
                }
                else {
                    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                [httpBody appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
                [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", httpBody.length] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:httpBody];
    }
    else {
        DLog(@"isMultiPartFormData = NO");
        NSMutableString *httpBody = [NSMutableString string];
        for (NSString *key in self.data.allKeys) {
            NSObject *value = [self.data objectForKey:key];
            if ([value isKindOfClass:NSString.class]) {
                if (httpBody.length > 0) {
                    [httpBody appendString:@"&"];
                }
                NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *encodedValue = [((NSString*)value) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [httpBody appendFormat:@"%@=%@", encodedKey, encodedValue];
            }
        }
        [request setValue:[NSString stringWithFormat:@"%d", httpBody.length] forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[httpBody dataUsingEncoding:NSUTF8StringEncoding]];
        DLog(@"POST:%@", httpBody);
    }
    for (NSString *key in self.headers.allKeys) {
        NSString *value = [self.headers objectForKey:key];
        [request setValue:value forHTTPHeaderField:key];
    }
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    [connection release];
}

- (void) finish {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    self.response = [NSMutableData data];
    [self.delegate performSelector:@selector(upload:connected:)
                       withObjects:self, self.map, nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {       
    [self.response appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    if ([challenge previousFailureCount] == 0) {
        DLog(@"Responded to authentication challenge");   
        if ([NSString isNilOrEmpty:self.username] == NO &&
            [NSString isNilOrEmpty:self.password] == NO) {
            NSURLCredential *credentials = [NSURLCredential credentialWithUser:self.username
                                                                      password:self.password
                                                                   persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:credentials forAuthenticationChallenge:challenge];
        }
        else {
            NSError *error = [NSError errorWithDomain:self.url
                                                 code:NSURLErrorUserAuthenticationRequired
                                              message:NSLocalizedString(@"User Authentication Required", nil)];
            [self.delegate performSelector:@selector(upload:finished:error:)
                               withObjects:self, self.map, error, nil];
            [self finish];
        } 
    }
    else {
        DLog(@"Previous authentication failure");
        [self.delegate performSelector:@selector(upload:finished:error:)
                           withObjects:self, self.map, challenge.error, nil];
        [self finish];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {   
    DLog(@"%@ Map:%@ Error:%@", self.class, self.map.name, [error description]);
    [self.delegate performSelector:@selector(upload:finished:error:)
                       withObjects:self, self.map, error, nil];
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    NSError *error = nil;
    if (self.response != nil && self.response.length > 0) {
        DLog(@"Response:%@", self.response);
    }
    else {
        error = [NSError errorWithDomain:self.map.url
                                    code:NSURLErrorBadServerResponse
                                 message:NSLocalizedString(@"Bad Server Response", nil)];
    }
    [self.delegate performSelector:@selector(upload:uploaded:)
                       withObjects:self, self.map, nil];
    [self.delegate performSelector:@selector(upload:finished:error:)
                       withObjects:self, self.map, error, nil];
    [self finish];
}

+ (BOOL) automaticallyNotifiesObserversForKey:(NSString*)key {
    return YES;
}

@end
