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

#import "Media.h"
#import "NSDictionary+Extension.h"

@implementation Media

@synthesize identifier, title, url;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		self.identifier = [dictionary stringForKey:@"id"];
		self.title = [dictionary stringForKey:@"title"];
		self.url = [dictionary stringForKey:@"link"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.url forKey:@"url"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.title = [decoder decodeObjectForKey:@"title"];
		self.url = [decoder decodeObjectForKey:@"url"];
	}
	return self;
}

- (void)dealloc {
	[identifier release];
	[title release];
	[url release];
    [super dealloc];
}

@end
