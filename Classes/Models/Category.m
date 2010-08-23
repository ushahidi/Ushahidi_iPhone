//
//  Category.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-23.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "Category.h"

@interface Category ()

// Internal private declarations go here

@end

@implementation Category

@synthesize title, description;

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.title forKey:@"title"];
	[encoder encodeObject:self.description forKey:@"description"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.title = [decoder decodeObjectForKey:@"title"];
		self.description = [decoder decodeObjectForKey:@"description"];
	}
	return self;
}

- (void)dealloc {
	[title release];
	[description release];
    [super dealloc];
}

@end
