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

#import "Country.h"

@implementation Country

@synthesize identifier, name, iso, capital;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		DLog(@"dictionary: %@", dictionary);
		if (dictionary != nil) {
			self.identifier = [dictionary objectForKey:@"id"];
			self.name = [dictionary objectForKey:@"name"];
			self.iso = [dictionary objectForKey:@"iso"];
			self.capital =  [dictionary objectForKey:@"capital"];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.iso forKey:@"iso"];
	[encoder encodeObject:self.iso forKey:@"capital"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.iso = [decoder decodeObjectForKey:@"iso"];
		self.iso = [decoder decodeObjectForKey:@"capital"];
	}
	return self;
}

- (NSComparisonResult)compareByName:(Country *)country {
	return [self.name localizedCaseInsensitiveCompare:country.name];
}

- (void)dealloc {
	[identifier release];
	[name release];
	[iso release];
	[capital release];
    [super dealloc];
}

@end
