//
//  Category.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-23.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject {

@public
	NSString *title;
	NSString *description;
	
@private
	//private members, if needed, go here
}

@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *description;

@end
