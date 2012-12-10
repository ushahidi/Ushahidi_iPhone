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

@synthesize identifier, message, date, latitude, longitude, location, photos, user, name, email, firstName, lastName, mobile;
@synthesize map;

- (id)initWithDefaultValues {
	if (self = [super init]) {
		self.identifier = [NSString getUUID];
		self.date = [NSDate date];
		self.photos = [NSMutableArray arrayWithCapacity:0];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		DLog(@"dictionary: %@", dictionary);
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

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.message forKey:@"message"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
	[encoder encodeObject:self.date forKey:@"date"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.user forKey:@"user"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.email forKey:@"email"];
	[encoder encodeObject:self.firstName forKey:@"firstName"];
	[encoder encodeObject:self.lastName forKey:@"lastName"];
	[encoder encodeObject:self.mobile forKey:@"mobile"];
	if (self.map != nil) {
		[encoder encodeObject:UIImagePNGRepresentation(self.map) forKey:@"map"];
	} 
	else {
		[encoder encodeObject:nil forKey:@"map"];
	}
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.message = [decoder decodeObjectForKey:@"message"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
		self.date = [decoder decodeObjectForKey:@"date"];
		self.user = [decoder decodeObjectForKey:@"user"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.email = [decoder decodeObjectForKey:@"email"];
		self.firstName = [decoder decodeObjectForKey:@"firstName"];
		self.lastName = [decoder decodeObjectForKey:@"lastName"];
		self.mobile = [decoder decodeObjectForKey:@"mobile"];
		self.photos = [decoder decodeObjectForKey:@"photos"];
		if (self.photos == nil) self.photos = [NSMutableArray array];
		NSData *mapData = [decoder decodeObjectForKey:@"map"];
		if (mapData != nil) {
			self.map = [UIImage imageWithData:mapData];
		}
	}
	return self;
}

- (NSString *) longDateTimeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a, MMMM d, yyyy" fromTimeZone:@"UTC"] : nil;
}

- (NSString *) shortDateTimeString {
	return self.date != nil ? [[self.date dateToString:@"h:mma d/MM/yy" fromTimeZone:@"UTC"] lowercaseString] : nil;
}

- (NSString *) shortDateString {
	return self.date != nil ? [self.date dateToString:@"d/MM/yyyy" fromTimeZone:@"UTC"] : nil;
}

- (NSString *) dateTimeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a, cccc MMMM d, yyyy" fromTimeZone:@"UTC"] : nil;
}

- (NSString *) dateString {
	return self.date != nil ? [self.date dateToString:@"cccc, MMMM d, yyyy" fromTimeZone:@"UTC"] : nil;
}

- (NSString *) timeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a" fromTimeZone:@"UTC"] : nil;
}

- (NSString *) coordinates {
	return [NSString stringWithFormat:@"%@, %@", self.latitude, self.longitude];
}

- (BOOL) hasPhotos {
	return self.photos != nil && [self.photos count] > 0;
}

- (BOOL) hasMap {
	return self.map != nil;
}

- (BOOL) hasName {
	return [NSString isNilOrEmpty:self.name] == NO;
}

- (BOOL) hasDate {
	return self.date != nil;
}

- (BOOL) hasMessage {
	return [NSString isNilOrEmpty:self.message] == NO;
}

- (BOOL) hasLocation {
	return [NSString isNilOrEmpty:self.latitude] == NO && [NSString isNilOrEmpty:self.longitude] == NO;
}

- (Photo *) firstPhoto {
	return [self.photos count] > 0 ? [self.photos objectAtIndex:0] : nil;
}

- (NSArray *) photoImages {
	NSMutableArray *images = [NSMutableArray arrayWithCapacity:[self.photos count]];
	for (Photo *photo in self.photos) {
		[images addObject:photo.image];
	}
	return images;
}

- (void) addPhoto:(Photo *)photo {
	[self.photos addObject:photo];
}

- (void) removePhotos {
	[self.photos removeAllObjects];
}

- (UIImage *) getFirstPhotoThumbnail {
	for (Photo *photo in self.photos) {
		if (photo.thumbnail != nil) {
			return photo.thumbnail;
		}
		if (photo.image != nil) {
			return photo.image;
		}
	} 
	return nil;
}

- (NSComparisonResult)compareByDate:(Checkin *)checkin {
	return [checkin.date compare:self.date];
}

- (NSComparisonResult)compareByName:(Checkin *)checkin {
	return [self.name compare:checkin.name];
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
	[name release];
	[email release];
	[firstName release];
	[lastName release];
	[mobile release];
	[map release];
    [super dealloc];
}

@end
