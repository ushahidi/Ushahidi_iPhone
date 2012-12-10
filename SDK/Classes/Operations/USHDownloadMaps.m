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

#import "USHDownloadMaps.h"
#import "NSDictionary+USH.h"
#import "NSObject+USH.h"
#import "Ushahidi.h"
#import "USHDatabase.h"
#import "USHMap.h"

@interface USHDownloadMaps ()

@property (nonatomic, strong, readwrite) USHMap *map;

@end

@implementation USHDownloadMaps

@synthesize map = _map;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    url:(NSString *)url {
    return [super initWithDelegate:delegate callback:callback url:url];
}

- (void) downloadedJSON:(NSDictionary*)json {
    for (NSString *identifier in [json allKeys]) {
        NSDictionary *map = [json objectForKey:identifier];
        if (map != nil) {
            self.map = (USHMap*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Map"
                                                                                 query:@"url = %@ && added = nil"
                                                                                params:[map objectForKey:@"url"], nil];
            self.map.url = [map objectForKey:@"url"];
            self.map.name = [map objectForKey:@"name"];
            self.map.desc = [map objectForKey:@"description"];
            self.map.discovered = [map dateForKey:@"discovery_date"];
            [self.delegate performSelectorOnMainThread:@selector(download:downloaded:)
                                         waitUntilDone:YES
                                           withObjects:self, self.map, nil];
        }
    }
}

- (void)dealloc {
    [_map release];
    [super dealloc];
}

@end
