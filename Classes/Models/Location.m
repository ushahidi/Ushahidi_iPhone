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

#import "Location.h"
#import "NSString+Extension.h"

@implementation Location

@synthesize identifier, name, countryID, latitude, longitude;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		//DLog(@"dictionary: %@", dictionary);
		if (dictionary != nil) {
			self.identifier = [dictionary objectForKey:@"id"];
			self.name = [dictionary objectForKey:@"name"];
			self.countryID = [dictionary objectForKey:@"country_id"];
			if ([@"<null>" isEqualToString:self.countryID]) {
				self.countryID = nil;
			}
			self.latitude = [dictionary objectForKey:@"latitude"];
			self.longitude = [dictionary objectForKey:@"longitude"];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.countryID forKey:@"countryID"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.countryID = [decoder decodeObjectForKey:@"countryID"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	return self.name != nil && [self.name anyWordHasPrefix:string];
}

- (NSComparisonResult)compareByName:(Location *)location {
	return [self.name localizedCaseInsensitiveCompare:location.name];
}

- (void)dealloc {
	[identifier release];
	[name release];
	[countryID release];
	[latitude release];
	[longitude release];
    [super dealloc];
}

@end
