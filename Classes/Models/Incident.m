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
#import "NSString+Extension.h"

@implementation Incident

typedef enum {
	MediaTypeUnkown,
	MediaTypePhoto,
	MediaTypeVideo,
	MediaTypeSound,
	MediaTypeNews
} MediaType;

@synthesize identifier, title, description, date;
@synthesize map;
@synthesize active, verified, uploading;
@synthesize news, photos, sounds, videos, categories;
@synthesize location, latitude, longitude;
@synthesize errors;

- (id)initWithDefaultValues {
	if (self = [super init]) {
		self.news = [[NSMutableArray alloc] initWithCapacity:0];
		self.photos = [[NSMutableArray alloc] initWithCapacity:0];
		self.sounds = [[NSMutableArray alloc] initWithCapacity:0];
		self.videos = [[NSMutableArray alloc] initWithCapacity:0];
		self.categories = [[NSMutableArray alloc] initWithCapacity:0];
		self.date = [NSDate date];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary mediaDictionary:(NSDictionary *)media {
	if (self = [self initWithDefaultValues]) {
		if (dictionary != nil) {
			DLog(@"inspection: %@", dictionary);
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
	[encoder encodeObject:self.news forKey:@"news"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.categories forKey:@"categories"];
	[encoder encodeObject:self.location forKey:@"location"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
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
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.date = [decoder decodeObjectForKey:@"date"];
		self.active = [decoder decodeBoolForKey:@"active"];
		self.verified = [decoder decodeBoolForKey:@"verified"];
		self.location = [decoder decodeObjectForKey:@"location"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
		NSData *mapData = [decoder decodeObjectForKey:@"map"];
		if (mapData != nil) {
			self.map = [UIImage imageWithData:mapData];
		}
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
	return self.title != nil && [self.title anyWordHasPrefix:string];
}

- (NSString *) dateTimeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a, cccc, MMMM d, yyyy"] : nil;
}

- (NSString *) dateString {
	return self.date != nil ? [self.date dateToString:@"cccc, MMMM d, yyyy"] : nil;
}

- (NSString *) timeString {
	return self.date != nil ? [self.date dateToString:@"h:mm a"] : nil;
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
	return [self categoryNamesWithDefaultText:nil];
}

- (NSString *) categoryNamesWithDefaultText:(NSString *)defaultText {
	NSMutableString *categoryNames = [NSMutableString stringWithCapacity:0];
	for (Category *category in self.categories) {
		if ([categoryNames length] > 0) {
			[categoryNames appendFormat:@","];
		}
		[categoryNames appendFormat:@"%@", category.title];
	}
	return [categoryNames length] > 0 ? categoryNames : defaultText;;
}

- (Photo *) getFirstPhoto {
	for (Photo *photo in self.photos) {
		return photo;
	} 
	return nil;
}

- (void) removePhotoAtIndex:(NSInteger)index {
	[self.photos removeObjectAtIndex:index];
}

- (BOOL) hasRequiredValues {
	return  self.title != nil && self.title.length > 0 &&
			self.location != nil && self.location.length > 0 &&
			self.date != nil &&
			self.categories.count > 0;
}

- (NSComparisonResult)compareByTitle:(Incident *)incident {
	return [self.title localizedCaseInsensitiveCompare:incident.title];
}

- (NSComparisonResult)compareByDate:(Incident *)incident {
	return [incident.date compare:self.date];
}

- (NSComparisonResult)compareByVerified:(Incident *)incident {
	return incident.verified > self.verified;
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
	[errors release];
	[map release];
	[super dealloc];
}

@end
