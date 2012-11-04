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

@synthesize identifier, name, latitude, longitude;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		//DLog(@"dictionary: %@", dictionary);
		if (dictionary != nil) {
			self.identifier = [dictionary stringForKey:@"id"];
			self.name = [dictionary objectForKey:@"name"];
			self.latitude = [dictionary objectForKey:@"latitude"];
			self.longitude = [dictionary objectForKey:@"longitude"];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.latitude forKey:@"latitude"];
	[encoder encodeObject:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.latitude = [decoder decodeObjectForKey:@"latitude"];
		self.longitude = [decoder decodeObjectForKey:@"longitude"];
	}
	return self;
}

- (NSString *) coordinates {
	return [NSString stringWithFormat:@"%@, %@", self.latitude, self.longitude];
}

- (BOOL) matchesString:(NSString *)string {
	return self.name != nil && [self.name anyWordHasPrefix:string];
}

- (NSComparisonResult)compareByName:(Location *)location {
	return [self.name localizedCaseInsensitiveCompare:location.name];
}

- (BOOL) equals:(NSString *)theName latitude:(NSString *)theLatitude longitude:(NSString *)theLongitude {
	return [self.name isEqualToString:theName] &&
			[self.latitude isEqualToString:theLatitude] &&
			[self.longitude isEqualToString:theLongitude];
}

- (void)dealloc {
	[identifier release];
	[name release];
	[latitude release];
	[longitude release];
    [super dealloc];
}

@end
