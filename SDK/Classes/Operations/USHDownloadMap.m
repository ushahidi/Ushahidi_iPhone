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

#import "USHDownloadMap.h"
#import "USHMap.h"
#import "USHReport.h"
#import "USHDatabase.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "NSError+USH.h"
#import "UIImage+USH.h"

@interface USHDownloadMap ()

@property (nonatomic, strong, readwrite) USHMap *map;
@property (nonatomic, strong, readwrite) USHReport *report;

@end

@implementation USHDownloadMap

@synthesize map = _map;
@synthesize report = _report;

NSInteger const kGoogleOverCapacitySize = 100;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map
                 report:(USHReport*)report {
    NSMutableString *url = [NSMutableString stringWithString:@"http://maps.google.com/maps/api/staticmap"];
    [url appendFormat:@"?center=%@,%@", report.latitude, report.longitude];
	[url appendFormat:@"&markers=%@,%@", report.latitude, report.longitude];
	[url appendFormat:@"&size=%dx%d", 320, 320];
	[url appendFormat:@"&zoom=%d", 14];
	[url appendFormat:@"&sensor=false"];
    if ((self = [super initWithDelegate:delegate callback:callback url:url])) {
        self.map = map;
        self.report = report;
    }
    return self;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    UIImage *image = [UIImage imageWithData:self.response];
    NSError *error = nil;
    if (image.size.width == kGoogleOverCapacitySize && image.size.height == kGoogleOverCapacitySize) {
        error = [NSError errorWithDomain:self.map.url code:0 message:NSLocalizedString(@"Over request capacity limit", nil)];
    }
    else {
        self.report.snapshot = self.response;
        [[USHDatabase sharedInstance] saveChanges];
        [self.delegate performSelector:@selector(download:downloaded:)
                           withObjects:self, self.map, nil];
    }
    [self.delegate performSelector:@selector(download:finished:error:)
                       withObjects:self, self.map, error, nil];
    [self finish];
}

- (void)dealloc {
    [_map release];
    [_report release];
    [super dealloc];
}

@end
