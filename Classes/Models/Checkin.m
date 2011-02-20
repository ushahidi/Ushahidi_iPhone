/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
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

#import "Checkin.h"
#import "NSDictionary+Extension.h"
#import "NSString+Extension.h"
#import "NSDate+Extension.h"
#import "Photo.h"

@implementation Checkin

@synthesize identifier, message, date, user, latitude, longitude, location, photos;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		//DLog(@"dictionary: %@", dictionary);
		if (dictionary != nil) {
			self.identifier = [dictionary stringForKey:@"id"];
			self.message = [dictionary stringForKey:@"msg"];
			self.latitude = [dictionary stringForKey:@"lat"];
			self.longitude = [dictionary stringForKey:@"lon"];
			self.user = [dictionary stringForKey:@"user"];
			self.date = [dictionary dateForKey:@"date"];
			self.photos = [NSMutableArray arrayWithCapacity:0];
			NSArray *media = [dictionary objectForKey:@"media"];
			if (media != nil && [media isKindOfClass:[NSArray class]]) {
				for (NSDictionary *item in media) {
					Photo *photo = [[Photo alloc] initWithDictionary:item];
					[self.photos addObject:photo];
					[photo release];
				}
			}
		}
	}
	return self;
}

- (id)initWithMessage:(NSString *)theMessage latitude:(NSString *)theLatitude longitude:(NSString *)theLongitude photo:(Photo *)thePhoto {
	if (self = [super init]) {
		self.message = theMessage;
		self.latitude = theLatitude;
		self.longitude = theLongitude;
		self.date = [NSDate date];
		self.photos = [NSMutableArray arrayWithCapacity:0];
		if (thePhoto != nil) {
			[self.photos addObject:thePhoto];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.message forKey:@"message"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
	[encoder encodeObject:self.date forKey:@"date"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.user forKey:@"user"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.message = [decoder decodeObjectForKey:@"message"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
		self.date = [decoder decodeObjectForKey:@"date"];
		self.user = [decoder decodeObjectForKey:@"user"];
		self.photos = [decoder decodeObjectForKey:@"photos"];
		if (self.photos == nil) self.photos = [NSMutableArray array];
	}
	return self;
}

- (NSString *) dateTimeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a, ccc, MMM d, yyyy"] : nil;
}

- (NSString *) dateString {
	return self.date != nil ? [self.date dateToString:@"cccc, MMMM d, yyyy"] : nil;
}

- (NSString *) timeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a"] : nil;
}

- (void)dealloc {
	[identifier release];
	[message release];
	[latitude release];
	[longitude release];
	[location release];
	[photos release];
	[date release];
	[user release];
    [super dealloc];
}

@end
