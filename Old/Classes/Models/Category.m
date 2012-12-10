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
#import "NSDictionary+Extension.h"

@implementation Category

@synthesize identifier, title, description, color, position;

- (id) initWithTitle:(NSString *)theTitle description:(NSString*)theDescription color:(UIColor*)theColor {
    if (self = [super init]) {
        self.title = theTitle;
        self.description = theDescription;
        self.color = theColor;
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		if (dictionary != nil) {
			self.identifier = [dictionary objectForKey:@"id"];
			self.title = [dictionary objectForKey:@"title"];
			self.description = [dictionary objectForKey:@"description"];
			self.color = [UIColor colorFromHexString:[dictionary objectForKey:@"color"]];
			if ([dictionary objectForKey:@"position"] != nil) {
				self.position = [dictionary intForKey:@"position"];
			}
			else {
				self.position = -1;
			}
		}
	}
	return self;
}

- (BOOL) updateWithDictionary:(NSDictionary *)dictionary {
	BOOL hasChanges = NO;
	NSString *newTitle = [dictionary objectForKey:@"title"];
	if ([self.title isEqualToString:newTitle] == NO) {
		self.title = newTitle;
		hasChanges = YES;
	}
	NSString *newDecription = [dictionary objectForKey:@"description"];
	if ([self.description isEqualToString:newDecription] == NO) {
		self.description = newDecription;
		hasChanges = YES;
	}
	UIColor *newColor = [UIColor colorFromHexString:[dictionary objectForKey:@"color"]];
	if ([self.color isEqualToColor:newColor] == NO) {
		self.color = newColor;
		hasChanges = YES;
	}
	return hasChanges;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.identifier forKey:@"identifier"];
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.description forKey:@"description"];
	[encoder encodeObject:self.color forKey:@"color"];
	[encoder encodeInt:self.position forKey:@"position"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.identifier = [decoder decodeObjectForKey:@"identifier"];
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
		self.color = [decoder decodeObjectForKey:@"color"];
		self.position = [decoder decodeIntForKey:@"position"];
	}
	return self;
}

- (BOOL) matchesString:(NSString *)string {
	return self.title != nil && [self.title anyWordHasPrefix:string];
}

- (NSComparisonResult)compare:(Category *)category {
	if (self.position > -1) {
		if (self.position < category.position) return NSOrderedAscending;
		else if (self.position > category.position) return NSOrderedDescending;
		else return NSOrderedSame;
	}
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
