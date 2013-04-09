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

#import "USHUploadJSON.h"
#import "USHMap.h"
#import "Ushahidi.h"
#import "SBJson.h"
#import "NSError+USH.h"
#import "NSString+USH.h"
#import "NSObject+USH.h"
#import "NSData+USH.h"

@interface USHUploadJSON ()

@property (nonatomic, strong) NSString *api;

@end

@implementation USHUploadJSON

@synthesize api = _api;

- (id) initWithDelegate:(NSObject<USHUploadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap*)map
                    api:(NSString*)api {
    NSURL *url = [NSURL URLWithString:[map.url stringByAppendingPathComponent:api]];
    if ((self = [super initWithDelegate:delegate
                               callback:callback
                                    map:map
                                    url:url.absoluteString
                               username:map.username
                               password:map.password])) {
        self.api = api;
    }
    return self;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    NSString *string = [NSString utf8StringFromData:self.response];
    NSError *error = nil;
    if (string != nil && string.length > 0) {
        NSDictionary *json = [string JSONValue];
        DLog(@"JSON:%@", json);
        if (json != nil) {
            NSDictionary *payload = [json objectForKey:@"payload"];
            DLog(@"Payload:%@", payload);
            if (payload != nil) {
                NSString *success = [payload objectForKey:@"success"];
                DLog(@"Success:%@", success);
                if ([@"true" isEqualToString:success]) {
                    error = nil;
                    [self.delegate performSelector:@selector(upload:uploaded:)
                                       withObjects:self, self.map, nil];
                }
                else {
                    NSDictionary *reason = [json objectForKey:@"error"];
                    DLog(@"Error:%@", reason);
                    NSString *message = [reason objectForKey:@"message"];
                    error = [NSError errorWithDomain:self.map.url code:NSURLErrorUnknown message:message];
                }
            }
            else {
                error = [NSError errorWithDomain:self.map.url code:NSURLErrorCannotParseResponse message:NSLocalizedString(@"Bad Server Response", nil)];
            }
        }
        else {
            DLog(@"Response:%@", string);
            error = [NSError errorWithDomain:self.map.url code:NSURLErrorCannotParseResponse message:NSLocalizedString(@"Bad Server Response", nil)];
        }
    }
    else {
        DLog(@"Response:%@", string);
        error = [NSError errorWithDomain:self.map.url code:NSURLErrorBadServerResponse message:NSLocalizedString(@"Bad Server Response", nil)];
    }
    [self.delegate performSelector:@selector(upload:uploaded:)
                       withObjects:self, self.map, nil];
    [self.delegate performSelector:@selector(upload:finished:error:)
                       withObjects:self, self.map, error, nil];
    [self finish];
}

- (void)dealloc {
    [_api release];
    [super dealloc];
}

@end
