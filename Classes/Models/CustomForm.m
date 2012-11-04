//
//  CustomForm.m
//  Ushahidi_iOS
//
//  Created by orta therox on 22/06/2012.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import "CustomForm.h"

@implementation CustomForm

@synthesize name, value;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
        self.name = [dictionary objectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.name = [decoder decodeObjectForKey:@"name"];
	}
	return self;
}

@end
