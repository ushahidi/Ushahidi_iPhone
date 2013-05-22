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

#import "USHUploadReport.h"
#import "USHMap.h"
#import "USHReport.h"
#import "USHVideo.h"
#import "USHPhoto.h"
#import "USHNews.h"
#import "NSString+USH.h"
#import "Ushahidi.h"
#import "USHDatabase.h"

@interface USHUploadReport ()

@property (strong, nonatomic, readwrite) USHReport *report;

@end

@implementation USHUploadReport

@synthesize report = _report;

- (id) initWithDelegate:(NSObject<USHUploadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map
                 report:(USHReport*)report {
    if ((self = [super initWithDelegate:delegate
                               callback:callback
                                    map:map
                                    api:@"api?task=report"])) {
        self.report = report;
    }
    return self;
}

- (void) prepare {
    [self setValue:@"report" forKey:@"task"];
    [self setValue:@"json" forKey:@"resp"];
    [self setValue:self.report.title forKey:@"incident_title"];
    [self setValue:self.report.desc forKey:@"incident_description"];
    [self setValue:self.report.dateDayMonthYear forKey:@"incident_date"];
    [self setValue:self.report.date12Hour forKey:@"incident_hour"];
    [self setValue:self.report.dateMinute forKey:@"incident_minute"];
    [self setValue:self.report.dateAmPm forKey:@"incident_ampm"];
    [self setValue:[self.report categoryIDs:@","] forKey:@"incident_category"];
    [self setValue:[self.report.latitude stringValue] forKey:@"latitude"];
    [self setValue:[self.report.longitude stringValue] forKey:@"longitude"];
    [self setValue:self.report.location forKey:@"location_name"];
    //TODO multiple self.report
    if (self.report.photos.count > 0) {
        USHPhoto *photo = [self.report photoAtIndex:0];
        [self setValue:photo.image
                forKey:@"incident_photo[]"
                  type:@"image/jpeg"
                  file:@"incident_photo.jpg"];
    }
    //TODO multiple videos
    if (self.report.videos.count > 0) {
        USHVideo *video = [self.report videoAtIndex:0];
        if (video.url != nil) {
            [self setValue:video.url
                    forKey:@"incident_video[]"];
        }
    }
    //TODO multiple news
    if (self.report.news.count > 0) {
        USHNews *news = [self.report newsAtIndex:0];
        [self setValue:news.url forKey:@"incident_news"];
    }
    [self setValue:self.report.authorFirst forKey:@"person_first"];
    [self setValue:self.report.authorLast forKey:@"person_last"];
    [self setValue:self.report.authorEmail forKey:@"person_email"];
}

- (void) success {
    [super success];
    if (self.report.pending.boolValue) {
        self.report.pending = [NSNumber numberWithBool:NO];
        [[USHDatabase sharedInstance] saveChanges];
    }
    DLog(@"Pending %@", self.report.pending);
}

- (void)dealloc {
    [_report release];
    [super dealloc];
}

@end
