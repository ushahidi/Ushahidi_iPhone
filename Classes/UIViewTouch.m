
// Import All the Necessary Files and Folders


#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "showMap.h"
#import "UIViewTouch.h"
#import "UshahidiProjAppDelegate.h" 
#import "MyAnnotation.h"

@implementation UIViewTouch
@synthesize viewTouched;

//The basic idea here is to intercept the view which is sent back as the firstresponder in hitTest.
//We keep it preciously in the property viewTouched and we return our view as the firstresponder.
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
 
	NSLog(@"Hit Test");

	// Touch Event goes here
    viewTouched = [super hitTest:point withEvent:event];
	app = [[UIApplication sharedApplication] delegate];
	
	// Put Annotation
	NSArray *existingpoints = app.mapView.annotations;
	if([existingpoints count] > 0)
		[app.mapView removeAnnotations:existingpoints];
	  [app.mapView setShowsUserLocation:NO];
	// Annotation Location 
	CLLocationCoordinate2D loc = [app.mapView convertPoint:point toCoordinateFromView:self];
	//MKPlacemark *pl=[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil];
	NSLog(@"%f,%f",loc.latitude,loc.longitude);
	
	//Latitude and Longitude from the Location
	app.lat = [NSString stringWithFormat:@"%f",loc.latitude];
	app.lng = [NSString stringWithFormat:@"%f",loc.longitude];
    MyAnnotation *ann = [[MyAnnotation alloc] init];
	ann.coordinate = loc;
	[app.mapView addAnnotation:ann];
	
	// Add Annotation on Specific Location
	//[app.mapView addAnnotation:pl];
	return self;
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{

	MKAnnotationView *a = [ [ MKAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    if ( a == nil )
        a = [ [ MKAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier: @"currentloc" ];
    //a.image = [ UIImage imageNamed:@"myAnnotation.png" ];
    a.canShowCallout = YES;
    a.rightCalloutAccessoryView = [ UIButton buttonWithType:UIButtonTypeDetailDisclosure ];
    UIImageView *imgView = [ [ UIImageView alloc ] initWithImage:[ UIImage imageNamed:@"bus_stop_30x30.png" ] ];
    a.leftCalloutAccessoryView = imgView;
    return a;
}


//Then, when an event is fired, we log this one and then send it back to the viewTouched we kept here
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Began");
    [viewTouched touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Moved");
    [viewTouched touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Ended");
    [viewTouched touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Cancelled");
}

@end