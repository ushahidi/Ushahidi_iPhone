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

#import "Instance.h"

@interface Instance ()

@end

@implementation Instance

@synthesize name, url, logo;

- (id)initWithName:(NSString *)theName url:(NSString *)theUrl logo:(UIImage *)theLogo {
	if (self = [super init]){
		self.name = theName;
		self.url = theUrl;
		self.logo = theLogo;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.url forKey:@"url"];
	if (self.logo != nil) {
		[encoder encodeObject:UIImagePNGRepresentation(self.logo) forKey:@"logo"];
	} 
	else {
		[encoder encodeObject:nil forKey:@"logo"];
	}
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.name = [decoder decodeObjectForKey:@"name"];
		self.url = [decoder decodeObjectForKey:@"url"];
		NSData *data = [decoder decodeObjectForKey:@"logo"];
		if (data != nil) {
			self.logo = [UIImage imageWithData:data];
		}
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	NSString *lowercaseString = [string lowercaseString];
	return	(string == nil || [string length] == 0) ||
			[[self.name lowercaseString] hasPrefix:lowercaseString] ||
			[[self.url lowercaseString] hasPrefix:lowercaseString];
}

- (void)dealloc {
	[name release];
	[url release];
	[logo release];
    [super dealloc];
}

@end
