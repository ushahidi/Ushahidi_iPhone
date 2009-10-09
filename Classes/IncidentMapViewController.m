//
//  IncidentMapViewController.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "IncidentMapViewController.h"
#import "RootViewController.h"
#import "IncidentAnnotation.h"

 
@implementation IncidentMapViewController

@synthesize segmentedControl, mapView;
@synthesize settingsButton, categoriesButton, aboutButton;
@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)showCategoryView:(id)sender {
	[self.delegate showCategories];
}

- (void)showAboutView:(id)sender {
	[self.delegate showAbout];
}

- (void)showSettingsView:(id)sender {
	[self.delegate showSettings];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
	segmentedControl.selectedSegmentIndex = 1;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationItem setHidesBackButton:YES];
	
	delegate = [[UIApplication sharedApplication] delegate];
	
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl insertSegmentWithTitle:@"Incident List" atIndex:0 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"Incident Map" atIndex:1 animated:NO];
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];

	mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 374)];
	mapView.mapType = MKMapTypeStandard;
	mapView.delegate = self;
	[self.view addSubview:mapView];
	
	CLLocationCoordinate2D workingCoordinate;
	
	workingCoordinate.latitude = 40.763856;
	workingCoordinate.longitude = -73.973034;
	IncidentAnnotation *annotation = [[IncidentAnnotation alloc] initWithCoordinate:workingCoordinate];
	annotation.title = @"test";
	annotation.subtitle = @"just trying out";
	[mapView addAnnotation:annotation];
	
	//[mapView setCenterCoordinate:workingCoordinate animated:YES];
}

- (void)controlPressed:(id)sender {
	@try {
		int selectedIndex = [segmentedControl selectedSegmentIndex];
		switch (selectedIndex) {
			case 0:
				[self.navigationController popToRootViewControllerAnimated:NO];
				//((RootViewController *)[self.navigationController topViewController]).segmentedControl.selectedSegmentIndex = 0;
			case 1:
				//
				break;
				
			default:
				break;
		}
	}
	@catch (NSException * e) {
		NSLog([e reason]);
	}
}

- (void)insertNewObject {
	/*
	 // Create a new instance of the entity managed by the fetched results controller.
	 NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
	 NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
	 NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
	 
	 // If appropriate, configure the new managed object.
	 [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
	 
	 // Save the context.
	 NSError *error;
	 if (![context save:&error]) {
	 // Handle the error...
	 }
	 
	 [self.tableView reloadData];
	 */
	[self.delegate showReport];
}

- (MKPinAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKPinAnnotationView *annotationView = nil;
	
	// determine the type of annotation, and produce the correct type of annotation view for it.
	IncidentAnnotation* myAnnotation = (IncidentAnnotation *)annotation;
	
	NSString* identifier = @"Incident";
	MKPinAnnotationView *newAnnotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	
	if(nil == newAnnotationView)
	{
		newAnnotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:identifier] autorelease];
	}
	
	annotationView = newAnnotationView;
	
	[annotationView setEnabled:YES];
	[annotationView setCanShowCallout:YES];
	
	return annotationView;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[segmentedControl release];
	[mapView release];
	[settingsButton release];
	[aboutButton release];
	[categoriesButton release];
	[delegate release];
}


@end
