//
//  IncidentAnnotation.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface IncidentAnnotation : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D) c;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
