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
#import "NSObject+Extension.h"

@interface MapTableCell ()

@property (nonatomic, assign) id<MapTableCellDelegate> delegate;

- (void) annotationClicked:(UIButton *)button;
- (void) doubleTapped:(id)sender;

@end

@implementation MapTableCell

@synthesize delegate, mapView, animatesDrop, draggable, showRightCallout, canShowCallout, location;

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

- (NSInteger) numberOfPins {
	return [[self.mapView annotations] count];
}

- (void) removeAllPins {
	[self.mapView removeAllPins];
}

- (MapAnnotation *) addPinWithTitle:(NSString *)title subtitle:(NSString *)subtitle latitude:(NSString *)latitude longitude:(NSString *)longitude {
	return [self.mapView addPinWithTitle:title subtitle:subtitle latitude:latitude longitude:longitude];
}

- (void) selectAnnotation:(MapAnnotation *)annotation animated:(BOOL)animated {
	for (id<MKAnnotation> currentAnnotation in self.mapView.annotations) {       
		if ([currentAnnotation isEqual:annotation]) {
			[self.mapView selectAnnotation:currentAnnotation animated:animated];
			break;
		}
	}
}

- (void) resizeRegionToFitAllPins:(BOOL)animated {
	[self.mapView resizeRegionToFitAllPins:NO animated:animated];
}

- (void) showUserLocation:(BOOL)show {
	self.mapView.showsUserLocation = show;
}

- (BOOL) hasUserLocation {
	return self.mapView.userLocation != nil;
}

- (NSString *) userLatitude {
	return self.mapView.userLocation != nil ? [NSString stringWithFormat:@"%f", self.mapView.userLocation.coordinate.latitude] : nil;
}

- (NSString *) userLongitude {
	return self.mapView.userLocation != nil ? [NSString stringWithFormat:@"%f", self.mapView.userLocation.coordinate.longitude] : nil;
}

- (void) setTappable:(BOOL)tappable {
	if (tappable) {
		[self.mapView removeTapRecognizers];
		[self.mapView addTapRecognizer:self action:@selector(doubleTapped:) taps:2];
	}
	else {
		[self.mapView removeTapRecognizers];
	}
}

- (void) doubleTapped:(id)sender {
	UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer *)sender;
	if (tapGesture.state == UIGestureRecognizerStateEnded) {
		CGPoint point = [tapGesture locationInView:self.mapView];
		CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
		DLog(@"Latitude:%f, Longitude:%f", coordinate.latitude, coordinate.longitude);
		NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
		NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
		if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(mapTableCellTapped:latitude:longitude:)]) {
			[self.delegate mapTableCellTapped:self latitude:latitude longitude:longitude];
		}
		//TODO fix bug in dispatchSelector not sending actual MapTableCell
		//	[self dispatchSelector:@selector(mapTableCellTapped:latitude:longitude:) 
		//					target:self.delegate 
		//				   objects:self, latitude, longitude, nil];	
	}
}

#pragma mark -
#pragma mark UITableViewCell

- (id)initForDelegate:(id<MapTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
		self.mapView = [[MKMapView alloc] initWithFrame:CGRectInset(self.contentView.frame, 10, 10)];
		self.mapView.delegate = self;
		self.mapView.mapType = MKMapTypeStandard;
		self.mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self.contentView addSubview:self.mapView];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[mapView release];
	[location release];
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
	annotationView.canShowCallout = self.canShowCallout;
	annotationView.draggable = self.draggable;
	annotationView.multipleTouchEnabled = NO;
	if ([annotation class] == MKUserLocation.class) {
		annotationView.pinColor = MKPinAnnotationColorGreen;
	}
	else {
		annotationView.pinColor = MKPinAnnotationColorRed;
		if (self.showRightCallout) {
			UIButton *annotationButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[annotationButton addTarget:self action:@selector(annotationClicked:) forControlEvents:UIControlEventTouchUpInside];
			annotationView.rightCalloutAccessoryView = annotationButton;	
		}
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (newState == MKAnnotationViewDragStateEnding) {
		[self dispatchSelector:@selector(mapTableCellDragged:latitude:longitude:) 
						target:self.delegate 
					   objects:self, [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.latitude], 
		 [NSString stringWithFormat:@"%f", annotationView.annotation.coordinate.longitude], nil];	
	}
}

- (void) annotationClicked:(UIButton *)button {
	[self dispatchSelector:@selector(mapTableCellSelected:indexPath:) 
					target:self.delegate 
				   objects:self, indexPath, nil];
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	[self.mapView resizeRegionToFitAllPins:YES animated:YES];
	[self dispatchSelector:@selector(mapTableCellLocated:latitude:longitude:) 
					target:self.delegate 
				   objects:self, [NSString stringWithFormat:@"%f", userLocation.coordinate.latitude], 
								 [NSString stringWithFormat:@"%f", userLocation.coordinate.longitude], nil];
}


- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
	DLog(@"");
	return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
	DLog(@"");
	return NO;
}

@end
