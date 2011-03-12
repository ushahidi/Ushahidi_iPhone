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
#import "MapAnnotation.h"

@protocol MapTableCellDelegate;

@interface MapTableCell : IndexedTableCell<MKMapViewDelegate> {

@public
	MKMapView *mapView;
	BOOL animatesDrop;
	BOOL canShowCallout;
	BOOL showRightCallout;
	BOOL draggable;
	NSString *location;
	
@private
	id<MapTableCellDelegate> delegate;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, assign) BOOL animatesDrop;
@property (nonatomic, assign) BOOL showRightCallout;
@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) BOOL canShowCallout;
@property (nonatomic, retain) NSString *location;

- (id) initForDelegate:(id<MapTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setMapType:(MKMapType)mapType;
- (void) setScrollable:(BOOL)scrollable;
- (void) setZoomable:(BOOL)zoomable;
- (void) setTappable:(BOOL)tappable;

- (NSInteger) numberOfPins;
- (void) removeAllPins;
- (MapAnnotation *) addPinWithTitle:(NSString *)title subtitle:(NSString *)subtitle latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void) resizeRegionToFitAllPins:(BOOL)animated;
- (void) showUserLocation:(BOOL)show;
- (BOOL) hasUserLocation;
- (NSString *) userLatitude;
- (NSString *) userLongitude;
- (void) selectAnnotation:(MapAnnotation *)annotation animated:(BOOL)animated;

@end

@protocol MapTableCellDelegate <NSObject>

@optional

- (void) mapTableCellSelected:(MapTableCell *)mapTableCell indexPath:(NSIndexPath *)indexPath;
- (void) mapTableCellLocated:(MapTableCell *)mapTableCell latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void) mapTableCellDragged:(MapTableCell *)mapTableCell latitude:(NSString *)latitude longitude:(NSString *)longitude;
- (void) mapTableCellTapped:(MapTableCell *)mapTableCell latitude:(NSString *)latitude longitude:(NSString *)longitude;

@end