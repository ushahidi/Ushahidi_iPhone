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
#import "NSDate+Extension.h"
#import "NSDictionary+Extension.h"

@implementation Incident

@synthesize identifier, title, description, date, active, verified, news, photos, categories, location;
@synthesize locationID, locationName, locationLatitude, locationLongitude;

- (id)initWithDefaultValues {
	if (self = [super init]) {
		self.news = [[NSMutableArray alloc] initWithCapacity:0];
		self.photos = [[NSMutableArray alloc] initWithCapacity:0];
		self.categories = [[NSMutableArray alloc] initWithCapacity:0];
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary mediaDictionary:(NSDictionary *)media {
	if (self = [super init]) {
		if (dictionary != nil) {
			DLog(@"dictionary: %@", dictionary);
			self.identifier = [dictionary stringForKey:@"incidentid"];
			self.title = [dictionary stringForKey:@"incidenttitle"];
			self.description = [dictionary stringForKey:@"incidentdescription"];
			self.active = [dictionary boolForKey:@"incidentactive"];
			self.verified = [dictionary boolForKey:@"incidentverified"];
			NSString *dateString = [dictionary objectForKey:@"incidentdate"];
			if (dateString != nil) {
				self.date = [NSDate dateFromString:dateString];
			}
			self.locationID = [dictionary stringForKey:@"locationid"];
			self.locationName = [dictionary stringForKey:@"locationname"];
			self.locationLatitude = [dictionary stringForKey:@"locationlatitude"];
			self.locationLongitude = [dictionary stringForKey:@"locationlongitude"];
		}
		if (media != nil) {
			DLog(@"media: %@", media);
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
	[encoder encodeObject:self.location forKey:@"location"];
	[encoder encodeObject:self.news forKey:@"news"];
	[encoder encodeObject:self.photos forKey:@"photos"];
	[encoder encodeObject:self.categories forKey:@"categories"];
	
	[encoder encodeObject:self.locationID forKey:@"locationID"];
	[encoder encodeObject:self.locationName forKey:@"locationName"];
	[encoder encodeObject:self.locationLatitude forKey:@"locationLatitude"];
	[encoder encodeObject:self.locationLongitude forKey:@"locationLongitude"];
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
		
		self.news = [decoder decodeObjectForKey:@"news"];
		if (self.news == nil) self.news = [NSArray array];
		
		self.photos = [decoder decodeObjectForKey:@"photos"];
		if (self.photos == nil) self.photos = [NSArray array];
		
		self.categories = [decoder decodeObjectForKey:@"categories"];
		if (self.categories == nil) self.categories = [NSArray array];
		
		self.locationID = [decoder decodeObjectForKey:@"locationID"];
		self.locationName = [decoder decodeObjectForKey:@"locationName"];
		self.locationLatitude = [decoder decodeObjectForKey:@"locationLatitude"];
		self.locationLongitude = [decoder decodeObjectForKey:@"locationLongitude"];
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	NSString *lowercaseString = [string lowercaseString];
	return	(string == nil || [string length] == 0) ||
			[[self.title lowercaseString] rangeOfString:lowercaseString].location != NSNotFound ||
			[[self.description lowercaseString] rangeOfString:lowercaseString].location != NSNotFound;
}

- (NSString *) getDateString {
	return self.date != nil ? [self.date dateToString] : nil;
}

- (void) addPhoto:(Photo *)photo {
	NSMutableArray *mutablePhotos = [NSMutableArray arrayWithArray:self.photos];
	[mutablePhotos addObject:photo];
	self.photos = mutablePhotos;
}

- (void) addNews:(News *)theNews {
	NSMutableArray *mutableNews = [NSMutableArray arrayWithArray:self.news];
	[mutableNews addObject:theNews];
	self.news = mutableNews;
}

- (void) addCategory:(Category *)category {
	DLog(@"%@", category.title);
	NSMutableArray *mutableCategories = [NSMutableArray arrayWithArray:self.categories];
	[mutableCategories addObject:category];
	self.categories = mutableCategories;
}

- (void) removeCategory:(Category *)category {
	DLog(@"%@", category.title);
	if ([self.categories containsObject:category]) {
		NSMutableArray *mutableCategories = [NSMutableArray arrayWithArray:self.categories];
		[mutableCategories removeObject:category];
		self.categories = mutableCategories;	
	}
}

- (BOOL) hasCategory:(Category *)category {
	return [self.categories containsObject:category];
}

- (void)dealloc {
	[identifier release];
	[title release];
	[description release];
	[date release];
	[location release];
	[news release];
	[photos release];
	[categories release];
	[locationID release];
	[locationName release];
	[locationLatitude release];
	[locationLongitude release];
	[super dealloc];
}

@end
