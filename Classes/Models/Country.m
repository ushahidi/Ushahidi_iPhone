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

@synthesize name, iso, capital;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.iso forKey:@"iso"];
	[encoder encodeObject:self.iso forKey:@"capital"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.name = [decoder decodeObjectForKey:@"name"];
		self.iso = [decoder decodeObjectForKey:@"iso"];
		self.iso = [decoder decodeObjectForKey:@"capital"];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[iso release];
	[capital release];
    [super dealloc];
}

@end
