//
//  MapTableCell.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "MapTableCell.h"

@interface MapTableCell ()

@property (nonatomic, assign) id<MapTableCellDelegate> delegate;

@end

@implementation MapTableCell

@synthesize delegate, indexPath, mapView;

- (void) setMapType:(MKMapType)mapType {
	self.mapView.mapType = mapType;
}

- (void) setScrollable:(BOOL)scrollable {
	self.mapView.scrollEnabled = scrollable;
}

- (void) setZoomable:(BOOL)zoomable {
	self.mapView.zoomEnabled = zoomable;
}

#pragma mark -
#pragma mark UITableViewCell

- (id)initWithDelegate:(id<MapTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.mapView = [[MKMapView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.mapView.delegate = self;
		self.mapView.mapType = MKMapTypeStandard;
		self.mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self.contentView addSubview:self.mapView];
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[indexPath release];
	[mapView release];
    [super dealloc];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)mapViewWillStartLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	DLog(@"");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)theMapView withError:(NSError *)error {
	DLog(@"error: %@", [error localizedDescription]);
}

@end
