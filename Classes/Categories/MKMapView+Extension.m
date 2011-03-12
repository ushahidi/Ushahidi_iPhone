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

#import "MKMapView+Extension.h"

@implementation MKMapView (Extension)

- (MapAnnotation *) addPinWithTitle:(NSString *)title 
						   subtitle:(NSString *)subtitle 
						   latitude:(NSString *)latitude 
						  longitude:(NSString *)longitude {
	return [self addPinWithTitle:title 
						subtitle:subtitle 
						latitude:latitude 
					   longitude:longitude 
						  object:nil
						pinColor:MKPinAnnotationColorRed];
}

- (MapAnnotation *) addPinWithTitle:(NSString *)title 
						   subtitle:(NSString *)subtitle 
						   latitude:(NSString *)latitude 
						  longitude:(NSString *)longitude
							 object:(NSObject *)object {
	return [self addPinWithTitle:title 
						subtitle:subtitle 
						latitude:latitude 
					   longitude:longitude 
						  object:object
						pinColor:MKPinAnnotationColorRed];
}

- (MapAnnotation *) addPinWithTitle:(NSString *)title 
						   subtitle:(NSString *)subtitle 
						   latitude:(NSString *)latitude 
						  longitude:(NSString *)longitude 
							 object:(NSObject *)object
						   pinColor:(MKPinAnnotationColor)pinColor {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = [latitude floatValue];
	coordinate.longitude = [longitude floatValue];
	MapAnnotation *mapAnnotation = [[MapAnnotation alloc] initWithTitle:title 
															   subtitle:subtitle 
															 coordinate:coordinate
															   pinColor:pinColor];
	[mapAnnotation setObject:object];
	[self addAnnotation:mapAnnotation];
	return [mapAnnotation autorelease];
}

- (void) removeAllPins {
	[self removeAnnotations:self.annotations];
}

- (void) centerAtCoordinate:(CLLocationCoordinate2D)coordinate withDelta:(CGFloat)delta {
	[self centerAtCoordinate:coordinate withDelta:delta animated:YES];
}

- (void) centerAtCoordinate:(CLLocationCoordinate2D)coordinate withDelta:(CGFloat)delta animated:(BOOL)animated {
	MKCoordinateSpan span;
	span.latitudeDelta = delta;
	span.longitudeDelta = delta;
	
	MKCoordinateRegion region;
	region.span = span;
	region.center = coordinate;
	
	[self setRegion:region animated:animated];
	[self regionThatFits:region];
}

- (void) resizeRegionToFitAllPins:(BOOL)includeUserLocation animated:(BOOL)animated {
	if ([self.annotations count] == 1) {
		NSObject<MKAnnotation> *annotation = [self.annotations objectAtIndex:0];
		BOOL isUserLocation = [annotation isKindOfClass:MKUserLocation.class];
		if ((includeUserLocation && isUserLocation) ||
			isUserLocation == NO) {
			CLLocationCoordinate2D coordinate;
			coordinate.latitude = annotation.coordinate.latitude;
			coordinate.longitude = annotation.coordinate.longitude;
			[self setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05f, 0.05f)) animated:animated];
		}
	}
	else if ([self.annotations count] > 1){
		CLLocationCoordinate2D topLeftCoordinate;
		topLeftCoordinate.latitude = -90;
		topLeftCoordinate.longitude = 180;
		
		CLLocationCoordinate2D bottomRightCoordinate;
		bottomRightCoordinate.latitude = 90;
		bottomRightCoordinate.longitude = -180;
		
		for (NSObject<MKAnnotation> *annotation in self.annotations) {
			BOOL isUserLocation = [annotation isKindOfClass:MKUserLocation.class];
			if ((includeUserLocation && isUserLocation) ||
				isUserLocation == NO) {
				topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude);
				topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude);
				bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude);
				bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude);
			}
		}
		
		MKCoordinateRegion region;
		region.center.latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5;
		region.center.longitude = topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5;
		region.span.latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.1; 
		region.span.longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1; 
		
		[self setRegion:[self regionThatFits:region] animated:animated];	
	}
}

- (UIGestureRecognizer *) addTapRecognizer:(id)target action:(SEL)action taps:(NSInteger)numberOfTaps {
//	UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
//	gestureRecognizer.minimumPressDuration = 2.0;
	
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	gestureRecognizer.numberOfTapsRequired = numberOfTaps;
	gestureRecognizer.numberOfTouchesRequired = 1;
	
	gestureRecognizer.cancelsTouchesInView = NO;
	gestureRecognizer.delaysTouchesBegan = NO;
	gestureRecognizer.delaysTouchesEnded = NO;
	
	[self addGestureRecognizer:gestureRecognizer];
	return [gestureRecognizer autorelease];
}

- (void) removeTapRecognizers {
	for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
		[self removeGestureRecognizer:gestureRecognizer];
	}
}

@end
