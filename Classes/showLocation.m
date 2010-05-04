//
//  showLocation.m
//  UshahidiProj
//
//  Created by iSoft Solutions on 31/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import "showLocation.h"

@implementation showLocation
@synthesize dictForLocation;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
	
	mk = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	mk.delegate = self;
	mk.mapType = MKMapTypeStandard;
	[super viewDidLoad];
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)viewWillAppear:(BOOL)animated
{
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	
	locate = mk.userLocation.coordinate;
	NSMutableDictionary *dicttemp = [dictForLocation objectForKey:@"incident"];	
	float lat = [[dicttemp objectForKey:@"locationlatitude"] floatValue];
	locate.latitude= lat;
	
	float lng = [[dicttemp objectForKey:@"locationlongitude"] floatValue];
	locate.longitude= lng;
	
	region.span=span;
	region.center=locate;
	
	/*Geocoder Stuff*/
	geoCoder=[[MKReverseGeocoder alloc] initWithCoordinate:locate];
	geoCoder.delegate=self;
	[geoCoder start];
	
	[mk setRegion:region animated:TRUE];
	[mk regionThatFits:region];
	[self.view addSubview:mk];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	NSLog(@"Reverse Geocoder Errored");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
	NSLog(@"Placemark Found");
	mPlacemark = placemark;
	[mk addAnnotation:placemark];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.animatesDrop=TRUE;
	return annView;
}

-(IBAction)back_Clicked
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
