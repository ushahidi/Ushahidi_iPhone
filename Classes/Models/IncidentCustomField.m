//
//  IncidentCustomField.m
//  Ushahidi_iOS
//
//  Created by Bhadrik Patel on 9/15/12.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import "IncidentCustomField.h"
#import "NSDictionary+Extension.h"
#import "NSString+Extension.h"
#import "NSDate+Extension.h"

@implementation IncidentCustomField
@synthesize fieldID,fieldType;
@synthesize fieldName,defaultValues;
@synthesize isRequired;
@synthesize fieldResponse;


- (id)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		DLog(@"dictionary: %@", dictionary);
		if (dictionary != nil) {
			self.fieldID = [[dictionary objectForKey:@"id"] intValue];
			self.fieldType = [[dictionary objectForKey:@"type"]intValue];
			self.fieldName = [[NSString alloc] initWithString:[dictionary stringForKey:@"name"]];
            if([dictionary objectForKey:@"default"] != nil){
                NSString *tmpDefault = [dictionary stringForKey:@"default"];
                self.defaultValues = [tmpDefault componentsSeparatedByString:@","];
            }else {
                self.defaultValues = [[NSArray alloc] init];
            }
			NSInteger requiredInt = [[dictionary objectForKey:@"required"]intValue];
            if(requiredInt == 0){
                self.isRequired = NO;
            }else {
                self.isRequired = YES ;
            }
		}
	}
	return self;
}
@end
