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

#import "USHDownloadLocation.h"
#import "NSDictionary+USH.h"
#import "NSObject+USH.h"
#import "Ushahidi.h"
#import "USHDatabase.h"
#import "USHMap.h"
#import "USHLocation.h"

@interface USHDownloadLocation ()

@property (nonatomic, strong, readwrite) USHLocation *location;

@end

@implementation USHDownloadLocation

@synthesize location = _location;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map {
    return [super initWithDelegate:delegate
                          callback:callback
                               map:map 
                               api:@"api?task=locations&resp=json"];
}

- (void) downloadedJSON:(NSDictionary*)json {
    NSDictionary *payload = [json objectForKey:@"payload"];
    NSArray *locations = [payload objectForKey:@"locations"];
    for (NSDictionary *item in locations) {
        NSDictionary *location = [item objectForKey:@"location"];
        if (location != nil) {
            self.location = (USHLocation*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Location"
                                                                                           query:@"map.url = %@ && identifier = %@"
                                                                                          params:self.map.url, [location stringForKey:@"id"], nil];
            self.location.identifier = [location stringForKey:@"id"];
            self.location.name = [location stringForKey:@"name"];
            self.location.latitude = [location numberForKey:@"latitude"];
            self.location.longitude = [location numberForKey:@"longitude"];
            self.location.map = self.map;
            DLog(@"Map:%@ Location:%@", self.map.name, self.location.name);
            [[USHDatabase sharedInstance] saveChanges];
            [self.delegate performSelector:@selector(download:downloaded:)
                               withObjects:self, self.map, nil];
        }
    }
}

- (void)dealloc {
    [_location release];
    [super dealloc];
}

@end
