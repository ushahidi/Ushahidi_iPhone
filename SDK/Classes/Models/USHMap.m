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

#import "USHMap.h"
#import "USHCategory.h"
#import "USHCheckin.h"
#import "USHLocation.h"
#import "USHReport.h"
#import "USHComment.h"
#import "USHUser.h"
#import "NSString+USH.h"
#import "NSSet+USH.h"
#import "NSArray+USH.h"

@implementation USHMap

@dynamic added;
@dynamic discovered;
@dynamic desc;
@dynamic name;
@dynamic synced;
@dynamic syncing;
@dynamic url;
@dynamic version;
@dynamic categories;
@dynamic reports;
@dynamic users;
@dynamic checkins;
@dynamic locations;
@dynamic username;
@dynamic password;
@dynamic error;
@dynamic opengeosms;
@dynamic checkin;
@dynamic email;
@dynamic sms;

- (NSArray*)reportsWithCategory:(USHCategory*)category {
    return [self reportsWithCategory:category text:nil sort:USHSortByDate ascending:NO];
}

- (NSArray*)reportsWithCategory:(USHCategory*)category text:(NSString*)text {
    return [self reportsWithCategory:category text:nil sort:USHSortByDate ascending:NO];
}

- (NSArray*) reportsWithCategory:(USHCategory*)category text:(NSString*)text sort:(USHSort)sort {
    return [self reportsWithCategory:category text:nil sort:sort ascending:NO];
}

- (NSArray*) reportsWithCategory:(USHCategory*)category text:(NSString*)text sort:(USHSort)sort ascending:(BOOL)ascending {
    NSMutableArray *filtered = [NSMutableArray array];
    NSString *sortedBy = sort == USHSortByDate ? @"date" : @"title";
    for (USHReport *report in [self.reports sortedBy:sortedBy ascending:ascending]) {
        BOOL hasCategory = NO;
        if (category != nil) {
            for (USHCategory *reportCategory in report.categories) {
                if (reportCategory == category) {
                    hasCategory = YES;
                }
            }
        }
        else {
            hasCategory = YES;
        }
        BOOL hasText = NO;
        if (text != nil) {
            if ([report.title anyWordHasPrefix:text]) {
                hasText = YES;
            }
            if ([report.desc anyWordHasPrefix:text]) {
                hasText = YES;
            }
        }
        else {
            hasText = YES;
        }
        if (hasText && hasCategory && report.pending.boolValue == NO) {
            [filtered addObject:report];
        }
    }
    return filtered;
}

- (NSArray*)checkinsForUser:(USHUser*)user text:(NSString*)text {
    NSMutableArray *filtered = [NSMutableArray array];
    for (USHCheckin *checkin in [self.checkins sortedBy:@"date" ascending:NO]) {
        BOOL isUser = NO;
        if (user == nil) {
            isUser = YES;
        }
        else if ([checkin.user.identifier isEqualToString:user.identifier]) {
            isUser = YES;
        }
        BOOL hasText = NO;
        if (text == nil) {
            hasText = YES;
        }
        else if ([checkin.message anyWordHasPrefix:text]) {
            hasText = YES;
        }
        if (hasText && isUser) {
            [filtered addObject:checkin];
        }
    }
    return filtered;
}

- (NSArray *) reportsPending {
    NSMutableArray *pending = [NSMutableArray array];
    for (USHReport *report in [self.reports sortedBy:@"date" ascending:NO]) {
        if (report.pending != nil && [report.pending boolValue]) {
            [pending addObject:report];
        }
    }
    return pending;
}

- (NSArray *) commentsPending {
    NSMutableArray *pending = [NSMutableArray array];
    for (USHReport *report in self.reports) {
        for (USHComment *comment in report.comments) {
            if (comment.pending != nil && [comment.pending boolValue]) {
                [pending addObject:comment];
            }
        }
    }
    return pending;
}

- (NSArray *) checkinsPending {
    //TODO improve performance
    NSMutableArray *pending = [NSMutableArray array];
    for (USHCheckin *checkin in self.checkins) {
        if (checkin.pending != nil && [checkin.pending boolValue]) {
            [pending addObject:checkin];
        }
    }
    return pending;
}

- (NSArray *) reportsSortedBy:(NSString*)sort ascending:(BOOL)ascending {
    return [self.reports sortedBy:sort ascending:ascending];
}

- (NSArray *) reportsSortedByDate {
    return [self.reports sortedBy:@"date" ascending:NO];
}

- (NSArray *) reportsSortedByTitle {
    return [self.reports sortedBy:@"title" ascending:YES];
}

- (NSArray *) categoriesSortedBy:(NSString*)sort ascending:(BOOL)ascending {
    return [self.categories sortedBy:sort ascending:ascending];
}

- (NSArray *) categoriesSortedByPosition {
    return [self.categories sortedBy:@"position" andBy:@"title" ascending:YES];
}


@end
