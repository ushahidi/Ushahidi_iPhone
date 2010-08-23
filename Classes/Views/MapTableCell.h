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

@protocol MapTableCellDelegate;

@interface MapTableCell : UITableViewCell<MKMapViewDelegate> {

@public
	NSIndexPath	*indexPath;
	MKMapView *mapView;
	
@private
	id<MapTableCellDelegate> delegate;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) MKMapView *mapView;

- (id)initWithDelegate:(id<MapTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setMapType:(MKMapType)mapType;
- (void) setScrollable:(BOOL)scrollable;
- (void) setZoomable:(BOOL)zoomable;

@end

@protocol MapTableCellDelegate <NSObject>

@optional

@end