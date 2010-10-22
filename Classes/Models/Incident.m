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

#import "Incident.h"
#import "Location.h"
#import "Photo.h"
#import "Category.h"
#import "News.h"
#import "Sound.h"
#import "Video.h"
#import "NSDate+Extension.h"
#import "NSDictionary+Extension.h"

@implementation Incident

typedef enum {
	MediaTypeUnkown,
	MediaTypePhoto,
	MediaTypeVideo,
	MediaTypeSound,
	MediaTypeNews
} MediaType;

@synthesize identifier, title, description, date, active, verified, pending, news, photos, sounds, videos, categories, location, latitude, longitude;

- (id)initWithDefaultValues {
	if (self = [super init]) {
		self.news = [[NSMutableArray alloc] initWithCapacity:0];
		self.photos = [[NSMutableArray alloc] initWithCapacity:0];
		self.sounds = [[NSMutableArray alloc] initWithCapacity:0];
		self.videos = [[NSMutableArray alloc] initWithCapacity:0];
		self.categories = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary mediaDictionary:(NSDictionary *)media {
	if (self = [self initWithDefaultValues]) {
		if (dictionary != nil) {
			//DLog(@"dictionary: %@", dictionary);
			self.identifier = [dictionary stringForKey:@"incidentid"];
			self.title = [dictionary stringForKey:@"incidenttitle"];
			self.description = [dictionary stringForKey:@"incidentdescription"];
			self.active = [dictionary boolForKey:@"incidentactive"];
			self.verified = [dictionary boolForKey:@"incidentverified"];
			NSString *dateString = [dictionary objectForKey:@"incidentdate"];
			if (dateString != nil) {
				self.date = [NSDate dateFromString:dateString];
			}
			self.location = [dictionary stringForKey:@"locationname"];
			self.latitude = [dictionary stringForKey:@"locationlatitude"];
			self.longitude = [dictionary stringForKey:@"locationlongitude"];
		}
		if (media != nil) {
			DLog(@"media: %@", media);
			for (NSDictionary *mediaDictionary in media) {
				NSInteger mediatype = [mediaDictionary intForKey:@"mediatype"];
				if (mediatype == MediaTypePhoto) {
					[self addPhoto:[[Photo alloc] initWithDictionary:mediaDictionary]];
				}
				else if (mediatype == MediaTypeVideo) {
					[self addVideo:[[Video alloc] initWithDictionary:mediaDictionary]];
				}
				else if (mediatype == MediaTypeSound) {
					[self addSound:[[Sound alloc] initWithDictionary:mediaDictionary]];
				}
				else if (mediatype == MediaTypeNews) {
					[self addNews:[[News alloc] initWithDictionary:mediaDictionary]];
				}	
			}
			
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:self.date forKey:@"date"];
	[encoder encodeBool:self.active forKey:@"active"];
	[encoder encodeBool:self.verified forKey:@"verified"];
	[encoder encodeBool:self.pending forKey:@"pending"];
	[encoder encodeObject:self.news forKey:@"news"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.categories forKey:@"categories"];
	[encoder encodeObject:self.location forKey:@"location"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.date = [decoder decodeObjectForKey:@"date"];
		self.active = [decoder decodeBoolForKey:@"active"];
		self.verified = [decoder decodeBoolForKey:@"verified"];
		self.pending = [decoder decodeBoolForKey:@"pending"];
		self.location = [decoder decodeObjectForKey:@"location"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
		
		self.news = [decoder decodeObjectForKey:@"news"];
		if (self.news == nil) self.news = [NSArray array];
		
		self.photos = [decoder decodeObjectForKey:@"photos"];
		if (self.photos == nil) self.photos = [NSArray array];
		
		self.categories = [decoder decodeObjectForKey:@"categories"];
		if (self.categories == nil) self.categories = [NSArray array];
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	NSString *lowercaseString = [string lowercaseString];
	return	(string == nil || [string length] == 0) ||
			[[self.title lowercaseString] hasPrefix:lowercaseString];
}

- (NSString *) dateString {
	return self.date != nil ? [self.date dateToString:@"cccc, MMMM d, yyyy"] : nil;
}

- (NSString *) dateDayMonthYear {
	return self.date != nil ? [self.date dateToString:@"MM/dd/yyyy"] : nil;
}

- (NSString *) dateHour {
	return self.date != nil ? [self.date dateToString:@"HH"] : nil;
}

- (NSString *) dateMinute {
	return self.date != nil ? [self.date dateToString:@"mm"] : nil;
}

- (NSString *) dateAmPm {
	return self.date != nil ? [[self.date dateToString:@"a"] lowercaseString] : nil;
}

- (void) addPhoto:(Photo *)photo {
	[self.photos addObject:photo];
}

- (void) addNews:(News *)theNews {
	[self.news addObject:theNews];
}

- (void) addSound:(Sound *)sound {
	[self.sounds addObject:sound];
}

- (void) addVideo:(Video *)video {
	[self.videos addObject:video];
}

- (void) addCategory:(Category *)category {
	DLog(@"%@", category.title);
	[self.categories addObject:category];
}

- (void) removeCategory:(Category *)category {
	DLog(@"%@", category.title);
	if ([self.categories containsObject:category]) {
		[self.categories removeObject:category];
	}
}

- (BOOL) hasCategory:(Category *)category {
	return [self.categories containsObject:category];
}

- (NSString *) categoryNames {
	NSMutableString *categoryNames = [NSMutableString stringWithCapacity:0];
	for (Category *category in self.categories) {
		if ([categoryNames length] > 0) {
			[categoryNames appendFormat:@","];
		}
		[categoryNames appendFormat:@"%@", category.title];
	}
	return categoryNames;
}

- (Photo *) getFirstPhoto; {
	for (Photo *photo in self.photos) {
		return photo;
	} 
	return nil;
}

- (void)dealloc {
	[identifier release];
	[title release];
	[description release];
	[date release];
	[location release];
	[latitude release];
	[longitude release];
	[news release];
	[photos release];
	[sounds release];
	[videos release];
	[categories release];
	[super dealloc];
}

@end
