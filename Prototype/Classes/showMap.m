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

#import "showMap.h"
#import "UIViewTouch.h"
#import <MapKit/MapKit.h>
#import "UshahidiProjAppDelegate.h"

@implementation showMap
@synthesize viewTouch;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   
	app = [[UIApplication sharedApplication] delegate];
	arrMapData = [[NSMutableArray alloc] init];
	viewTouch = [[UIViewTouch alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [viewTouch addSubview:app.mapView];
	[self.view addSubview:viewTouch];

	tb = [[UIToolbar alloc] init];
	tb.barStyle = UIBarStyleDefault;
	[tb sizeToFit];
	CGRect rectArea = CGRectMake(0, 386, 320, 45);
	
	//Reposition and resize the receiver
	[tb setFrame:rectArea];
	
	//Create a button
	
	find = [[UIBarButtonItem alloc]
				  initWithImage:[UIImage imageNamed:@"location.png"]
				  style:UIBarButtonItemStyleBordered target:self
				  action:@selector(findMe)];

	flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

	reset = [[UIBarButtonItem alloc]
			initWithImage:[UIImage imageNamed:@"sonar.png"]
			style:UIBarButtonItemStyleBordered target:self
			action:@selector(resetLocation)];
	
	UILabel *findLoc = [[UILabel alloc] init];
	findLoc.frame = CGRectMake(70, 8, 100, 100);
	[findLoc setBackgroundColor:[UIColor clearColor]];
	[findLoc setTextColor:[UIColor blackColor]];
	[findLoc setFont:[UIFont systemFontOfSize:14]];
	findLoc.text = @"Find Me";
	UIBarButtonItem *l1 = [[UIBarButtonItem alloc] initWithCustomView:findLoc];
	
	UILabel *resetLoc = [[UILabel alloc] init];
	resetLoc.frame = CGRectMake(70, 8, 100, 100);
	[resetLoc setBackgroundColor:[UIColor clearColor]];
	[resetLoc setTextColor:[UIColor blackColor]];
	[resetLoc setFont:[UIFont systemFontOfSize:14]];
	resetLoc.text = @"Reset Location";
	
	UIBarButtonItem *l2 = [[UIBarButtonItem alloc] initWithCustomView:resetLoc];
	[tb setItems:[NSArray arrayWithObjects:find,l1,reset,l2,nil]];
	[self.navigationController.view addSubview:tb];
	[super viewDidLoad];
}

-(void)resetLocation
{
	arrMapData = [app getMapCentre];	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];

 	dict = [arrMapData objectAtIndex:0];
	dict1 = [dict objectForKey:@"mapcenter"];
	app.lat = [dict1 objectForKey:@"latitude"];
	app.lng = [dict1 objectForKey:@"longitude"];
}
-(void)findMe
{
	[app showUser];
	app.tempLat = app.mapView.userLocation.location.coordinate.latitude;
	app.tempLng = app.mapView.userLocation.location.coordinate.longitude;
	app.lat = [NSString stringWithFormat:@"%f",app.tempLat]; 
	app.lng = [NSString stringWithFormat:@"%f",app.tempLng]; 
}

- (void)viewWillAppear:(BOOL)animated
{
	self.title = @"Location";
	self.navigationItem.hidesBackButton = TRUE;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done_Clicked)];
}

-(void)done_Clicked
{
	[self.navigationController popViewControllerAnimated:YES];
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
}

@end
