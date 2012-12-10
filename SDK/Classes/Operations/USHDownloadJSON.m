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

#import "USHDownloadJSON.h"
#import "Ushahidi.h"
#import "USHMap.h"
#import "NSURL+USH.h"
#import "NSError+USH.h"
#import "NSString+USH.h"
#import "NSObject+USH.h"
#import "NSData+USH.h"
#import "SBJson.h"

@interface USHDownloadJSON ()

@end

@implementation USHDownloadJSON

- (void) downloadedJSON:(NSDictionary*)json {
    DLog(@"%@ %@ JSON:%@", self.class, self.url, json);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@ %@", self.class, self.url);
    NSString *string = [NSString utf8StringFromData:self.response];
    NSError *error = nil;
    if (string != nil && string.length > 0) {
        NSDictionary *json = [string JSONValue];
        if (json != nil) {
            DLog(@"JSON:%@", json);
            [self downloadedJSON:json];
        }
        else {
            DLog(@"JSON NULL:%@", string);
            error = [NSError errorWithDomain:self.map.url code:NSURLErrorCannotParseResponse message:NSLocalizedString(@"API URL Invalid", nil)];
        }
    }
    else {
        DLog(@"Response NULL:%@", string);
        error = [NSError errorWithDomain:self.map.url code:NSURLErrorBadServerResponse message:NSLocalizedString(@"Bad Server Response", nil)];
    }
    [self.delegate performSelector:@selector(download:finished:error:)
                       withObjects:self, self.map, error, nil];
    [self finish];
}

@end
