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

#import "User.h"
#import "NSDictionary+Extension.h"

@implementation User

@synthesize identifier, name;

- (id)initWithIdentifier:(NSString *)theIdentifier name:(NSString *)theName {
	if (self = [super init]) {
		self.identifier = theIdentifier;
		self.name = theName;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		DLog(@"%@", dictionary);
		if (dictionary != nil) {
			self.identifier = [dictionary stringForKey:@"id"];
			self.name = [dictionary stringForKey:@"name"];
		}
	}
	return self;
}

- (BOOL)updateWithDictionary:(NSDictionary *)dictionary {
	DLog(@"%@", dictionary);
	NSString *nameString = [dictionary stringForKey:@"name"];
	if ([self.name isEqualToString:nameString] == NO) {
		self.name = nameString;
		return YES;
	}
	return NO;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.name = [decoder decodeObjectForKey:@"name"];
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	[name release];
    [super dealloc];
}

@end
