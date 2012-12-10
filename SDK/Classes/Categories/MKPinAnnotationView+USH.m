/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "MKPinAnnotationView+USH.h"
#import "USHMapAnnotation.h"

@implementation MKPinAnnotationView (USH)

+ (MKPinAnnotationView *) getPinForMap:(MKMapView *)mapView andAnnotation:(id <MKAnnotation>)annotation {
	NSString *const identifer = @"MKPinAnnotationView";
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifer];
	if (annotationView == nil) {
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifer] autorelease];
	}
	annotationView.animatesDrop = NO;
	annotationView.canShowCallout = YES;
	if ([annotation class] == MKUserLocation.class) {
		annotationView.pinColor = MKPinAnnotationColorGreen;
	}
	else {
		if ([annotation isKindOfClass:[USHMapAnnotation class]]) {
			USHMapAnnotation *mapAnnotation = (USHMapAnnotation *)annotation;
			annotationView.pinColor = mapAnnotation.pinColor;
		}
		else {
			annotationView.pinColor = MKPinAnnotationColorRed;
		}
	}
	return annotationView;
}

@end
