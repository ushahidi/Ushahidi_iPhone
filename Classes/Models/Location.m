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

@implementation Location

@synthesize name, countryID, latitude, longitude;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.countryID forKey:@"countryID"];
	[encoder encodeInt:self.latitude forKey:@"latitude"];
	[encoder encodeInt:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.name = [decoder decodeObjectForKey:@"name"];
		self.countryID = [decoder decodeObjectForKey:@"countryID"];
		self.latitude = [decoder decodeIntForKey:@"latitude"];
		self.longitude = [decoder decodeIntForKey:@"longitude"];
	}
	return self;
}

- (void)dealloc {
	[name release];
	[countryID release];
    [super dealloc];
}

@end
