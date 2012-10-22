//
//  IncidentCustomField.h
//  Ushahidi_iOS
//
//  Created by Bhadrik Patel on 9/15/12.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IncidentCustomField : NSObject{
    

@public
    NSInteger fieldID;
    NSInteger fieldType;
    NSArray * defaultValues;
    NSString * fieldName;
    NSString * fieldResponse;
    BOOL isRequired;
    
}

@property(nonatomic,assign) NSInteger fieldID;
@property(nonatomic,assign) NSInteger fieldType;
@property(nonatomic,retain) NSArray * defaultValues;
@property(nonatomic,retain) NSString * fieldName;
@property(nonatomic,retain) NSString * fieldResponse;
@property(nonatomic,assign) BOOL isRequired;



- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
