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

#import "MapTableCell.h"
#import "MapAnnotation.h"
#import "MKMapView+Extension.h"

@interface MapTableCell ()

@property (nonatomic, assign) id<MapTableCellDelegate> delegate;

- (void) annotationClicked:(UIButton *)button;

@end

@implementation MapTableCell

@synthesize delegate, indexPath, mapView, animatesDrop;

#pragma mark -
#pragma mark Public

- (void) setMapType:(MKMapType)mapType {
	self.mapView.mapType = mapType;
}

- (void) setScrollable:(BOOL)scrollable {
	self.mapView.scrollEnabled = scrollable;
}

- (void) setZoomable:(BOOL)zoomable {
	self.mapView.zoomEnabled = zoomable;
}

- (void) removeAllPins {
	[self.mapView removeAllPins];
}

- (void) addPinWithTitle:(NSString *)title latitude:(NSString *)latitude longitude:(NSString *)longitude {
	[self.mapView addPinWithTitle:title latitude:latitude longitude:longitude];
}

- (void) resizeRegionToFitAllPins:(BOOL)animated {
	[self.mapView resizeRegionToFitAllPins:animated];
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

- (MKAnnotationView *) mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MKPinAnnotationView"] autorelease];
	annotationView.animatesDrop = self.animatesDrop;
	annotationView.canShowCallout = YES;
	
	UIButton *annotationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[annotationButton addTarget:self action:@selector(annotationClicked:) forControlEvents:UIControlEventTouchUpInside];
	annotationView.rightCalloutAccessoryView = annotationButton;
	
	return annotationView;
}

- (void) annotationClicked:(UIButton *)button {
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[[button superview] superview];
	MapAnnotation *mapAnnotation = (MapAnnotation *)annotationView.annotation;
	DLog(@"title:%@ latitude:%f longitude:%f", mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude);
	SEL selector = @selector(mapTableCell:pinSelectedAtIndex:);
	if (self.delegate != nil && [self.delegate respondsToSelector:selector]) {
		[self.delegate mapTableCell:self pinSelectedAtIndex:mapAnnotation.index];
	}
	else {
		DLog(@"delegate %@ does not respond to selector", self.delegate);
	}
}

@end
