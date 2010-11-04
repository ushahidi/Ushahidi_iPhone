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
#import "MapAnnotation.h"

@implementation MKMapView (Extension)

- (void) addPinWithTitle:(NSString *)title subtitle:(NSString *)subtitle latitude:(NSString *)latitude longitude:(NSString *)longitude {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = [latitude floatValue];
	coordinate.longitude = [longitude floatValue];
	NSInteger index = [self.annotations count];
	MapAnnotation *mapAnnotation = [[MapAnnotation alloc] initWithTitle:title subtitle:subtitle coordinate:coordinate index:index];
	[self addAnnotation:mapAnnotation];
	[mapAnnotation release];
}

- (void) removeAllPins {
	[self removeAnnotations:self.annotations];
}

- (void) resizeRegionToFitAllPins {
	[self resizeRegionToFitAllPins:YES];
}

- (void) resizeRegionToFitAllPins:(BOOL)animated {
	if ([self.annotations count] == 1) {
		NSObject<MKAnnotation> *annotation = [self.annotations objectAtIndex:0];
		
		CLLocationCoordinate2D coordinate;
		coordinate.latitude = annotation.coordinate.latitude;
		coordinate.longitude = annotation.coordinate.longitude;
		
		[self setRegion:MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.05f, 0.05f)) animated:animated];	
	}
	else if ([self.annotations count] > 1){
		CLLocationCoordinate2D topLeftCoordinate;
		topLeftCoordinate.latitude = -90;
		topLeftCoordinate.longitude = 180;
		
		CLLocationCoordinate2D bottomRightCoordinate;
		bottomRightCoordinate.latitude = 90;
		bottomRightCoordinate.longitude = -180;
		
		for (NSObject<MKAnnotation> *annotation in self.annotations) {
			topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude);
			topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude);
			bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude);
			bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude);
		}
		
		MKCoordinateRegion region;
		region.center.latitude = topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5;
		region.center.longitude = topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.5;
		region.span.latitudeDelta = fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.1; 
		region.span.longitudeDelta = fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.1; 
		
		[self setRegion:[self regionThatFits:region] animated:animated];	
	}
	else {
		MKCoordinateRegion coordinate = self.region;
		coordinate.span.latitudeDelta = coordinate.span.latitudeDelta *10;
		coordinate.span.longitudeDelta = coordinate.span.longitudeDelta *10;
		[self setRegion:coordinate animated:YES];
	}
}

@end
