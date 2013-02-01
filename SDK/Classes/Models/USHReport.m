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

#import "USHReport.h"
#import "USHCategory.h"
#import "USHComment.h"
#import "USHMap.h"
#import "USHNews.h"
#import "USHPhoto.h"
#import "USHSound.h"
#import "USHVideo.h"
#import "NSSet+USH.h"
#import "NSArray+USH.h"

@implementation USHReport

@dynamic viewed;
@dynamic date;
@dynamic desc;
@dynamic identifier;
@dynamic latitude;
@dynamic location;
@dynamic longitude;
@dynamic snapshot;
@dynamic title;
@dynamic pending;
@dynamic verified;
@dynamic categories;
@dynamic comments;
@dynamic map;
@dynamic news;
@dynamic photos;
@dynamic sounds;
@dynamic videos;
@dynamic url;
@dynamic starred;

@dynamic authorFirst;
@dynamic authorLast;
@dynamic authorEmail;

- (NSString *) dateFormatted:(NSString*)format {
    if (self.date != nil) {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:format];
        return [formatter stringFromDate:self.date];
	}
    return nil;
}

- (NSString *) categoryTitles:(NSString*)separator {
    NSMutableString *result = [NSMutableString string];
    if (self.categories.count > 0) {
        for (USHCategory *category in [self.categories sortedBy:@"position" ascending:YES]) {
            if (category != nil && category.title != nil) {
                if (result.length > 0) {
                    [result appendString:separator];
                }
                [result appendString:category.title];   
            }
        }   
    }
    return result;
}

- (NSString*) categoryIDs:(NSString*)separator {
    NSMutableString *result = [NSMutableString string];
    if (self.categories.count > 0) {
        for (USHCategory *category in [self.categories sortedBy:@"position" ascending:YES]) {
            if (category != nil && category.identifier != nil) {
                if (result.length > 0) {
                    [result appendString:separator];
                }
                [result appendString:category.identifier];   
            }
        }
    }
    return result;
}

- (BOOL) containsCategory:(USHCategory*)category {
    for (USHCategory *cat in self.categories) {
        if (cat.identifier == category.identifier &&
            [cat.title isEqualToString:category.title]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *) commentsSortedBy:(NSString*)sort ascending:(BOOL)ascending {
    return [self.comments sortedBy:sort ascending:ascending];
}

- (NSArray *) commentsSortedByDate {
    return [self.comments sortedBy:@"date" ascending:YES];
}

- (NSString *) dateTimeString {
    return [self dateFormatted:@"h:mm a, ccc, MMM d, yyyy"];
}

- (NSString *) dateString {
    return [self dateFormatted:@"cccc, MMMM d, yyyy"];
}

- (NSString *) timeString {
    return [self dateFormatted:@"h:mm a"];
}

- (NSString *) dateDayMonthYear {
    return [self dateFormatted:@"MM/dd/yyyy"];
}

- (NSString *) date12Hour {
    if (self.date != nil) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:kCFCalendarUnitHour fromDate:self.date];
        NSInteger hour = [components hour] > 12 ? [components hour] - 12 : [components hour];
        return [NSString stringWithFormat:@"%d", hour];
    }
    return nil;
}

- (NSString *) date24Hour {
    return [self dateFormatted:@"HH"];
}

- (NSString *) dateMinute {
    return [self dateFormatted:@"mm"];
}

- (NSString *) dateAmPm {
	if (self.date != nil) {
		NSCalendar *calendar = [NSCalendar currentCalendar];
		NSDateComponents *components = [calendar components:kCFCalendarUnitHour fromDate:self.date];
		return [components hour] >= 12 ? @"pm" : @"am";
	}
	return nil;
}

- (USHVideo *) videoAtIndex:(NSInteger)index {
    return (USHVideo*)[self.videos objectAtIndex:index];
}

- (USHNews *) newsAtIndex:(NSInteger)index {
    return (USHNews*)[self.news objectAtIndex:index];
}

- (USHPhoto *) photoAtIndex:(NSInteger)index {
    return (USHPhoto*)[self.photos objectAtIndex:index];
}

@end
