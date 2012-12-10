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

#import "USHDownloadPhoto.h"
#import "USHMap.h"
#import "USHReport.h"
#import "USHPhoto.h"
#import "USHDatabase.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "UIImage+USH.h"

@interface USHDownloadPhoto ()

@property (nonatomic, strong, readwrite) USHMap *map;
@property (nonatomic, strong, readwrite) USHReport *report;
@property (nonatomic, strong, readwrite) USHPhoto *photo;

@end

@implementation USHDownloadPhoto

@synthesize map = _map;
@synthesize report = _report;
@synthesize photo = _photo;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map
                 report:(USHReport*)report
                  photo:(USHPhoto*)photo {
    if ((self = [super initWithDelegate:delegate callback:callback url:photo.url])) {
        self.map = map;
        self.report = report;
        self.photo = photo;
    }
    return self;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    DLog(@"%@ Map:%@", self.class, self.map.name);
    self.photo.image = self.response;
    UIImage *original = [UIImage imageWithData:self.response];
    if (original != nil) {
        UIImage *thumbnail = [original thumbnailWithSize:CGSizeMake(100, 100)];
        self.photo.thumb = UIImageJPEGRepresentation(thumbnail, 1);
    }
    [[USHDatabase sharedInstance] saveChanges];
    [self.delegate performSelector:@selector(download:downloaded:)
                       withObjects:self, self.map, nil];
    [self.delegate performSelector:@selector(download:finished:error:)
                       withObjects:self, self.map, nil, nil];
    [self finish];
}

- (void)dealloc {
    [_map release];
    [_report release];
    [_photo release];
    [super dealloc];
}

@end
