//
//  MapTableCell.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

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