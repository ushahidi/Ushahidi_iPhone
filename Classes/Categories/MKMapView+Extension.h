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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "MapAnnotation.h"

@interface MKMapView (Extension)

- (MapAnnotation *) addPinWithTitle:(NSString *)title 
						   subtitle:(NSString *)subtitle 
						   latitude:(NSString *)latitude 
						  longitude:(NSString *)longitude;

- (MapAnnotation *) addPinWithTitle:(NSString *)title 
						   subtitle:(NSString *)subtitle 
						   latitude:(NSString *)latitude 
						  longitude:(NSString *)longitude 
							 object:(NSObject *)object;

- (MapAnnotation *) addPinWithTitle:(NSString *)title 
						   subtitle:(NSString *)subtitle 
						   latitude:(NSString *)latitude 
						  longitude:(NSString *)longitude 
							 object:(NSObject *)object 
						   pinColor:(MKPinAnnotationColor)pinColor;

- (void) removeAllPins;
- (void) resizeRegionToFitAllPins:(BOOL)includeUserLocation animated:(BOOL)animated;
- (void) centerAtCoordinate:(CLLocationCoordinate2D)coordinate withDelta:(CGFloat)delta;
- (void) centerAtCoordinate:(CLLocationCoordinate2D)coordinate withDelta:(CGFloat)delta animated:(BOOL)animated;
- (UIGestureRecognizer *) addTapRecognizer:(id)target action:(SEL)action taps:(NSInteger)numberOfTaps;
- (void) removeTapRecognizers;

@end
