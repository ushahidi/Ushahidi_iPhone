//
//  CustomForm.m
//  Ushahidi_iOS
//
//  Created by orta therox on 22/06/2012.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import "CustomForm.h"
#import "NSDictionary+Extension.h"

@implementation CustomForm

@synthesize name, value, formId;

- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
        if ([dictionary objectForKey:@"field_name"]) {
            //it is attached to an incident
            self.name = [[dictionary stringForKey:@"field_name"] retain];
            if ([[dictionary stringForKey:@"field_response"] length] > 0) {
                self.value = [[dictionary stringForKey:@"field_response"] retain];
            } else {
                self.value = @"";
            }
            self.formId = [dictionary intForKey:@"field_id"];
        } else {
            //it was retrieved from the customfields api call
            self.name = [[dictionary stringForKey:@"name"] retain];
            self.value = @"";
            self.formId = [dictionary intForKey:@"id"];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CustomForm *copy = [[CustomForm alloc] init];
    copy.name = [self.name copy];
    copy.value = @"";
    copy.formId = self.formId;
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.value forKey:@"value"];
    [encoder encodeInt:self.formId forKey:@"formId"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]){
		self.name   = [decoder decodeObjectForKey:@"name"];
        self.value  = [decoder decodeObjectForKey:@"value"];
        self.formId = [decoder decodeIntForKey:@"formId"];
	}
	return self;
}

@end
