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

#import "USHLocationTableCell.h"
#import <Ushahidi/MKMapView+USH.h>
#import <Ushahidi/MKPinAnnotationView+USH.h>

@interface USHLocationTableCell ()

@end

@implementation USHLocationTableCell

@synthesize mapView = _mapView;

- (void) removeAllPins {
    [self.mapView removeAllPins];
}

- (void) addPinWithTitle:(NSString*)title subtitle:(NSString *)subtitle latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude {
    [self.mapView addPinWithTitle:title subtitle:subtitle latitude:[latitude stringValue] longitude:[longitude stringValue]];
}

- (void) showAllPins:(BOOL)animated {
    [self.mapView resizeRegionToFitAllPins:NO animated:animated];
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
	return [MKPinAnnotationView getPinForMap:map andAnnotation:annotation];
}

@end
