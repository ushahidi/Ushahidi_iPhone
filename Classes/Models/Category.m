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

#import "Category.h"
#import "UIColor+Extension.h"
#import "NSString+Extension.h"

@interface Category ()

// Internal private declarations go here

@end

@implementation Category

@synthesize identifier, title, description, color;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		//DLog(@"dictionary: %@", dictionary);
		if (dictionary != nil) {
			self.identifier = [dictionary objectForKey:@"id"];
			self.title = [dictionary objectForKey:@"title"];
			self.description = [dictionary objectForKey:@"description"];
			self.color = [UIColor colorWithHexString:[dictionary objectForKey:@"color"]];
		}
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:self.color forKey:@"color"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.color = [decoder decodeObjectForKey:@"color"];
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	return self.title != nil && [self.title anyWordHasPrefix:string];
}

- (NSComparisonResult)compareByTitle:(Category *)category {
	return [self.title localizedCaseInsensitiveCompare:category.title];
}

- (void)dealloc {
	[identifier release];
	[title release];
	[description release];
	[color release];
    [super dealloc];
}

@end
