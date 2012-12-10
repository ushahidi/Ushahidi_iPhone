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

#import "USHDownloadCheckin.h"
#import "NSDictionary+USH.h"
#import "NSObject+USH.h"
#import "Ushahidi.h"
#import "USHDatabase.h"
#import "USHMap.h"
#import "USHCheckin.h"

@interface USHDownloadCheckin ()

@property (nonatomic, strong, readwrite) USHCheckin *checkin;
@property (nonatomic, strong, readwrite) USHUser *user;

@end

@implementation USHDownloadCheckin

@synthesize checkin = _checkin;
@synthesize user = _user;

- (id) initWithDelegate:(NSObject<USHDownloadDelegate>*)delegate
               callback:(NSObject<UshahidiDelegate>*)callback
                    map:(USHMap *)map {
    return [super initWithDelegate:delegate
                          callback:callback
                               map:map 
                               api:@"api/?task=checkin&action=get_ci&sort=desc&sqllimit=100"];
}

- (void) downloadedJSON:(NSDictionary*)json {
    NSDictionary *payload = [json objectForKey:@"payload"];
    NSArray *checkins = [payload objectForKey:@"checkins"];
    for (NSDictionary *checkin in checkins) {
        self.checkin = (USHCheckin*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"Checkin"
                                                                                     query:@"map.url = %@ && identifier = %@"
                                                                                    params:self.map.url, [checkin stringForKey:@"id"], nil];
        self.checkin.identifier = [checkin stringForKey:@"id"];
        self.checkin.message = [checkin stringForKey:@"msg"];
        self.checkin.date = [checkin dateForKey:@"date"];
        self.checkin.latitude = [checkin numberForKey:@"lat"];
        self.checkin.longitude = [checkin numberForKey:@"lon"];
        self.checkin.map = self.map;
        NSDictionary *user = [checkin objectForKey:@"user"];
        if (user != nil) {
            self.user = (USHUser*)[[USHDatabase sharedInstance] fetchOrInsertItemForName:@"User"
                                                                                   query:@"map.url = %@ && identifier = %@"
                                                                                  params:self.map.url, [user stringForKey:@"id"], nil];
            self.user.identifier = [user stringForKey:@"id"];
            self.user.name = [user stringForKey:@"name"];
            self.user.username = [user stringForKey:@"username"];
            self.user.color = [user stringForKey:@"color"];
            self.checkin.user = self.user;
        }
        NSArray *medias = [checkin objectForKey:@"media"];
        if (medias != nil && medias.count > 0) {
            NSDictionary *media = [medias objectAtIndex:0];
            if (self.checkin.image == nil) {
                NSError *error = nil;
                NSString *image = [media stringForKey:@"link"];
                self.checkin.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:image]
                                                      options:NSDataReadingUncached
                                                        error:&error];
                if (error) {
                    DLog(@"Image:%@ Error:%@", image, [error description]);
                }
                else {
                    DLog(@"Image:%@", image);
                }
            }
            if (self.checkin.thumb == nil) {
                NSError *error = nil;
                NSString *thumb = [media stringForKey:@"thumb"];
                self.checkin.thumb = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumb]
                                                      options:NSDataReadingUncached
                                                        error:&error];
                if (error) {
                    DLog(@"Thumb:%@ Error:%@", thumb, [error description]);
                }
                else {
                    DLog(@"Thumb:%@", thumb);
                }
            }
        }
        [[USHDatabase sharedInstance] saveChanges];
        [self.delegate performSelector:@selector(download:downloaded:)
                           withObjects:self, self.map, nil];
    }
}

- (void)dealloc {
    [_checkin release];
    [_user release];
    [super dealloc];
}

@end
