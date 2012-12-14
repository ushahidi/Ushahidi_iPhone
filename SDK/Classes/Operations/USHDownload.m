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

#import "USHDownload.h"
#import "Ushahidi.h"
#import "USHMap.h"
#import "NSURL+USH.h"
#import "NSError+USH.h"
#import "NSString+USH.h"
#import "NSObject+USH.h"
#import "NSData+USH.h"
#import "SBJson.h"

@interface USHDownload ()

@property (nonatomic, strong, readwrite) NSObject<USHDownloadDelegate> *delegate;
@property (nonatomic, strong, readwrite) NSObject<UshahidiDelegate> *callback;
@property (nonatomic, strong, readwrite) USHMap *map;

@property (nonatomic, strong, readwrite) NSMutableData *response;
@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong, readwrite) NSURL *domain;

@property (nonatomic, strong) NSString *api;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation USHDownload

@synthesize delegate = _delegate;
@synthesize callback = _callback;
@synthesize api = _api;
@synthesize map = _map;
@synthesize response = _response;
@synthesize url = _url;
@synthesize domain = _domain;
@synthesize username = _username;
@synthesize password = _password;

@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
                    api:(NSString*)api {
    if ((self = [super init])) {
        self.delegate = delegate;
        self.callback = callback;
        self.map = map;
        self.api = api;
        self.url = [NSURL URLWithString:api relativeToURL:[NSURL URLWithString:map.url]];
        self.domain = [self.url domainURL];
        self.username = map.username;
        self.password = map.password;
        DLog(@"Domain:%@ URL:%@ ", self.domain, self.url);
    }
    return self;
}

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    url:(NSString*)url {
    if ([super init]) {
        self.delegate = delegate;
        self.callback = callback;
        self.url = [NSURL URLWithString:url];
        self.domain = [self.url domainURL];
        DLog(@"Domain:%@ URL:%@ ", self.domain, self.url);
    }
    return self;
}

- (void)dealloc {
    DLog(@"%@ %@", self.class, self.url);
    [_delegate release];
    [_callback release];
    [_api release];
    [_map release];
    [_url release];
    [_domain release];
    [_response release];
    [_username release];
    [_password release];
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
    DLog(@"%@ %@", self.class, self.url);
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.delegate performSelectorOnMainThread:@selector(download:started:)
                                 waitUntilDone:YES  
                                   withObjects:self, self.map, nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:120.0];
    if ([NSString isNilOrEmpty:self.username] == NO &&
        [NSString isNilOrEmpty:self.password] == NO) {
        NSString *credentials = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
        NSData *encoded = [credentials dataUsingEncoding:NSASCIIStringEncoding];
        NSString *base64 = [encoded base64EncodingWithLineLength:80];
        NSString *authorization = [NSString stringWithFormat:@"Basic %@", base64];
        [request setValue:authorization forHTTPHeaderField:@"Authorization"];   
    }
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [connection start];
    [connection release];
}

- (void) finish {
    DLog(@"%@ %@", self.class, self.url);
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
} 

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    DLog(@"%@ %@", self.class, self.url);
    if ([challenge previousFailureCount] == 0) {
        if ([NSString isNilOrEmpty:self.username] == NO &&
            [NSString isNilOrEmpty:self.password] == NO) {
            NSURLCredential *credentials = [NSURLCredential credentialWithUser:self.username
                                                                      password:self.password
                                                                   persistence:NSURLCredentialPersistenceForSession];
            [[challenge sender] useCredential:credentials forAuthenticationChallenge:challenge];
        }
        else {
            NSError *error = [NSError errorWithDomain:self.map.url
                                                 code:NSURLErrorUserAuthenticationRequired
                                              message:NSLocalizedString(@"User Authentication Required", nil)];
            [self.delegate performSelector:@selector(download:finished:error:)
                               withObjects:self, self.map, error, nil];
            [self finish];
        }   
    }
    else {
        DLog(@"Previous authentication failure");
        [self.delegate performSelector:@selector(download:finished:error:)
                           withObjects:self, self.map, challenge.error, nil];
        [self finish];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    DLog(@"%@ %@", self.class, self.url);
    self.response = [NSMutableData data];
    [self.delegate performSelector:@selector(download:connected:)
                       withObjects:self, self.map, nil];
 
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {       
    [self.response appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {   
    DLog(@"%@ %@ Error:%@", self.class, self.url, [error description]);
    [self.delegate performSelector:@selector(download:finished:error:)
                       withObjects:self, self.map, error, nil];
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@ %@", self.class, self.url);
    [self.delegate performSelector:@selector(download:finished:error:)
                       withObjects:self, self.map, nil, nil];
    [self finish];
}

@end
