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
#import "IndexedTableCell.h"

@protocol MapTableCellDelegate;

@interface MapTableCell : IndexedTableCell<MKMapViewDelegate> {

@public
	MKMapView *mapView;
	BOOL animatesDrop;
	BOOL showRightCallout;
	
@private
	id<MapTableCellDelegate> delegate;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, assign) BOOL showRightCallout;

- (id)initForDelegate:(id<MapTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setMapType:(MKMapType)mapType;
- (void) setScrollable:(BOOL)scrollable;
- (void) setZoomable:(BOOL)zoomable;

- (NSInteger) numberOfPins;
- (void) removeAllPins;
- (void) addPinWithTitle:(NSString *)title subtitle:(NSString *)subtitle latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void) resizeRegionToFitAllPins:(BOOL)animated;

@end

@protocol MapTableCellDelegate <NSObject>

@optional

- (void) mapTableCell:(MapTableCell *)mapTableCell pinSelectedAtIndex:(NSInteger)index;

@end