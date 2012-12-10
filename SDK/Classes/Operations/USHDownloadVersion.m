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

#import "USHDownloadVersion.h"
#import "NSDictionary+USH.h"
#import "USHMap.h"
#import "Ushahidi.h"

@interface USHDownloadVersion ()

@end

@implementation USHDownloadVersion

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map {
    return [super initWithDelegate:delegate
                          callback:callback
                               map:map 
                               api:@"api?task=version&resp=json"];
}

- (void) downloadedJSON:(NSDictionary*)json {
    NSDictionary *payload = [json objectForKey:@"payload"];
    if ([payload boolForKey:@"checkins"]) {
        self.map.checkin = [NSNumber numberWithBool:YES];
    }
    else {
        self.map.checkin = [NSNumber numberWithBool:NO];
    }
    self.map.sms = [payload stringForKey:@"sms"];
    if ([@"<null>" isEqualToString:self.map.sms]) {
        self.map.sms = nil;
    }
    self.map.email = [payload stringForKey:@"email"];
    if ([@"<null>" isEqualToString:self.map.email]) {
        self.map.email = nil;
    }
    NSArray *items = [payload objectForKey:@"version"];
    if (items != nil) {
        NSDictionary *item = [items objectAtIndex:0];
        if (item != nil) {
            self.map.version = [item stringForKey:@"version"];
        }
    }
    NSArray *plugins = [payload objectForKey:@"plugins"];
    if (plugins != nil) {
        for (NSString *plugin in plugins) {
            DLog(@"Map:%@ Plugin:%@", self.map.name, plugin);
            if ([plugin isEqualToString:@"opengeosms"]) {
                self.map.opengeosms = [NSNumber numberWithBool:YES];
            }
        }
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
