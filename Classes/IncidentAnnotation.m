//
//  IncidentAnnotation.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "IncidentAnnotation.h"
#import "UshahidiAppDelegate.h"

@implementation IncidentAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

@end
