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

#import "USHDownloadReport.h"
#import "NSDictionary+USH.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "USHMap.h"
#import "Ushahidi.h"
#import "USHDatabase.h"
#import "USHMap.h"
#import "USHReport.h"
#import "USHCategory.h"

@interface USHDownloadReport ()

@property (nonatomic, strong, readwrite) USHReport *report;

- (void) parseMedia:(NSDictionary*)media;
   
@end

@implementation USHDownloadReport

typedef enum {
    MediaTypeUnknown,
    MediaTypePhoto,
    MediaTypeVideo,
    MediaTypeSound,
    MediaTypeNews
} MediaType;

@synthesize report = _report;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map
                  limit:(NSInteger)limit {
    NSString *api = limit > 0
        ? [NSString stringWithFormat:@"api?task=incidents&by=all&resp=json&comments=1&limit=%d", limit]
        : @"api?task=incidents&by=all&resp=json&comments=1";
    return [super initWithDelegate:delegate
                          callback:callback
                               map:map 
                               api:api];
}

- (void) downloadedJSON:(NSDictionary*)json {
    NSDictionary *payload = [json objectForKey:@"payload"];
    NSArray *incidents = [payload objectForKey:@"incidents"];
    for (NSDictionary *item in incidents) {
        NSDictionary *incident = [item objectForKey:@"incident"];
        if (incident != nil) {
            self.report = (USHReport*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Report"
                                                                                       query:@"map.url = %@ && identifier = %@"
                                                                                      params:self.map.url, [incident stringForKey:@"incidentid"], nil];
            self.report.identifier = [incident stringForKey:@"incidentid"];
            self.report.url = [self.map.url urlStringByAppendingFormat:@"/reports/view/%@", [incident stringForKey:@"incidentid"], nil];
            self.report.title = [incident stringForKey:@"incidenttitle"];
            self.report.desc = [incident stringForKey:@"incidentdescription"];
            self.report.latitude = [NSNumber numberWithDouble:[incident doubleForKey:@"locationlatitude"]];
            self.report.longitude = [NSNumber numberWithDouble:[incident doubleForKey:@"locationlongitude"]];
            self.report.verified = [NSNumber numberWithDouble:[incident boolForKey:@"incidentverified"]];
            self.report.location = [incident stringForKey:@"locationname"];
            self.report.date = [incident dateForKey:@"incidentdate"];
            self.report.map = self.map;
        }
        NSArray *categories = [item objectForKey:@"categories"];
        if (categories != nil) {
            for (NSDictionary *dictionary in categories) {
                NSDictionary *cat = [dictionary objectForKey:@"category"]; 
                if (cat != nil) {
                    USHCategory *category = (USHCategory*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Category"
                                                                                                      query:@"map.url = %@ && identifier = %@"
                                                                                                     params:self.map.url, [cat stringForKey:@"id"], nil];
                    category.identifier = [cat stringForKey:@"id"];
                    category.title = [cat stringForKey:@"title"];
                    category.map = self.map;
                    [self.report addCategoriesObject:category];
                }
            }
        }

        NSObject *medias = [item objectForKey:@"media"];
        if (medias != nil && [medias isKindOfClass:NSDictionary.class]) {
            NSDictionary *media = (NSDictionary*)medias;
            [self parseMedia:media];
        }
        else if (medias != nil && [medias isKindOfClass:NSArray.class]){
            for (NSDictionary *media in medias) {
                [self parseMedia:media];
            }
        }
        else {
            DLog("Unknown Media Type %@", medias.class);
        }
        NSArray *comments = [item objectForKey:@"comments"];
        if (comments != nil) {
            for (NSDictionary *item in comments) {
                NSDictionary *dictionary = [item objectForKey:@"comment"];
                DLog(@"Comment:%@", dictionary);
                NSString *identifier = [dictionary stringForKey:@"id"];
                NSDate *date = [dictionary dateForKey:@"comment_date"];
                NSString *author = [dictionary stringForKey:@"comment_author"];
                NSString *description = [dictionary stringForKey:@"comment_description"];
                NSString *email = [dictionary stringForKey:@"comment_email"];
                USHComment *comment = (USHComment*)[[USHDatabase sharedInstance] fetchItemForName:@"Comment"
                                                                                            query:@"report.identifier = %@ && identifier = %@"
                                                                                           params:self.report.identifier, identifier, nil];
                if (comment == nil) {
                    comment = (USHComment*)[[USHDatabase sharedInstance] fetchItemForName:@"Comment"
                                                                                    query:@"report.identifier = %@ && text ==[c] %@ && email ==[c] %@"
                                                                                   params:self.report.identifier, description, email, nil];

                }
                if (comment == nil) {
                    comment = (USHComment*)[[USHDatabase sharedInstance] insertItemWithName:@"Comment"];
                }
                comment.identifier = identifier;
                comment.date = date;
                comment.text = description;
                comment.author = author;
                comment.email = email;
                comment.report = self.report;
            }
        }
        [[USHDatabase sharedInstance] saveChanges];
        [self.delegate performSelector:@selector(download:downloaded:)
                           withObjects:self, self.map, nil];
    }
}

- (void) parseMedia:(NSDictionary*)media {
    DLog(@"%@", media);
    if (media != nil) {
        NSString *identifier = [media stringForKey:@"id"];
        NSInteger type = [media intForKey:@"type"];
        NSString *link = [media stringForKey:@"link"];
        if (type == MediaTypePhoto) {
            USHPhoto *photo = (USHPhoto*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Photo"
                                                                                          query:@"report.identifier = %@ && identifier = %@"
                                                                                         params:self.report.identifier, identifier, nil];
            photo.identifier = identifier;
            NSString *link_url = [media stringForKey:@"link_url"];
            if ([NSString isNilOrEmpty:link_url]) {
                link_url = [self.map.url stringByAppendingPathComponent:@"/media/uploads/"];
                link_url = [link_url stringByAppendingPathComponent:link];
            }
            photo.url = link_url;
            photo.report = self.report;
        }
        else if (type == MediaTypeNews) {
            USHNews *news = (USHNews*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"News"
                                                                                       query:@"report.identifier = %@ && identifier = %@"
                                                                                      params:self.report.identifier, identifier, nil];
            news.identifier = identifier;
            news.url = link;
            news.report = self.report;
        }
        else if (type == MediaTypeVideo) {
            USHVideo *video = (USHVideo*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Video"
                                                                                          query:@"report.identifier = %@ && identifier = %@"
                                                                                         params:self.report.identifier, identifier, nil];
            video.identifier = identifier;
            video.url = link;
            video.report = self.report;
        }
        else if (type == MediaTypeSound) {
            USHSound *sound = (USHSound*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Sound"
                                                                                          query:@"report.identifier = %@ && identifier = %@"
                                                                                         params:self.report.identifier, identifier, nil];
            sound.identifier = identifier;
            sound.url = link;
            sound.report = self.report;
        }
    }
}

- (void)dealloc {
    [_report release];
    [super dealloc];
}

@end
