//
//  CustomForm.h
//  Ushahidi_iOS
//
//  Created by orta therox on 22/06/2012.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomForm : NSObject<NSCoding>

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (retain, nonatomic) NSString* name;
@property (retain, nonatomic) NSString* value;

@end
