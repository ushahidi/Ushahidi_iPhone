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

#import "viewIncident.h"
#import "MyAnnotation.h" 
#import "UshahidiProjAppDelegate.h"
#import "CustomCell.h"
#import "showIncidentDetails.h"

@implementation viewIncident

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewWillDisappear:(BOOL)animated
{
	[tb removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated
{
	tb = [[UIToolbar alloc] init];
	tb.barStyle = UIBarStyleDefault;
	[tb sizeToFit];
	CGRect rectArea = CGRectMake(0, 386, 320, 45);
	if([app.mapType isEqualToString:@"Google Standard"] )
		mk.mapType = MKMapTypeStandard;
	else if([app.mapType isEqualToString:@"Google Hybrid"] )
		mk.mapType = MKMapTypeHybrid;
	else if([app.mapType isEqualToString:@"Google Satelite"] )
		mk.mapType = MKMapTypeSatellite;
	else 
		mk.mapType = MKMapTypeStandard;
	//Reposition and resize the receiver
	[tb setFrame:rectArea];
	
	//Create a button
	infoButton = [[UIBarButtonItem alloc]
								   initWithImage:[UIImage imageNamed:@"location.png"]
								   style:UIBarButtonItemStyleBordered target:self
								   action:nil];
	button = [[UIButton alloc] init];
	button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(0, 0, 220, 30);
	[button addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
	[button setTitleColor:[UIColor blackColor] forState:normal];
	[button setTitle:@"All incident types" forState:normal];
	btn = [[UIBarButtonItem alloc] initWithCustomView:button];
	btn1 =   [[UIBarButtonItem alloc]
						  initWithImage:[UIImage imageNamed:@"sync.png"]
						  style:UIBarButtonItemStyleBordered target:self
						  action:nil];
	flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	if(seg.selectedSegmentIndex == 0)
	{
		tblView.hidden = FALSE;
		mk.hidden = TRUE;
		[tb setItems:[NSArray arrayWithObjects:flexible,btn,flexible,nil]];
	}
	else
	{
		tblView.hidden = TRUE;
		mk.hidden = FALSE;
		[tb setItems:[NSArray arrayWithObjects:infoButton,flexible,btn,flexible,btn1,nil]];
	}
	
	//Add the toolbar as a subview to the navigation controller.
	[self.navigationController.view addSubview:tb];
	arrData = [app getCategories];
	app.incidentArray = [app getAllIncidents];
	[app.incidentArray retain];
	[arrData retain];
	
	[self.view addSubview:mk];
	[self.view bringSubviewToFront:pickerView];
	[tblView reloadData];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	app = [[UIApplication sharedApplication] delegate];
	df = [[NSDateFormatter alloc] init];
	pickerView.delegate = self;
	pickerView.hidden = TRUE;
	seg = [[UISegmentedControl alloc] initWithItems:nil];
	other = FALSE;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	[seg insertSegmentWithTitle:@"Report List" atIndex:0 animated:NO];
	[seg insertSegmentWithTitle:@"Report Map" atIndex:1 animated:NO];
	self.navigationItem.titleView = seg;
	seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(changeSegment:) forControlEvents:UIControlEventValueChanged];
	
	arrData = [[NSMutableArray alloc] init];
	app.incidentArray = [[NSMutableArray alloc] init];
	tblView.delegate = self;
	tblView.dataSource = self;
	pickerView.delegate = self;
	mk = [[MKMapView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	mk.delegate = self;
	if([app.mapType isEqualToString:@"Google Standard"] )
		mk.mapType = MKMapTypeStandard;
	else if([app.mapType isEqualToString:@"Google Hybrid"] )
		mk.mapType = MKMapTypeHybrid;
	else if([app.mapType isEqualToString:@"Google Satelite"] )
			mk.mapType = MKMapTypeSatellite;
	mk.hidden = TRUE;
	[self.view bringSubviewToFront:pickerView];
	
	tb1 = [[UIToolbar alloc] init];
	tb1.barStyle = UIBarStyleDefault;
	[tb1 sizeToFit];
	CGRect rectArea = CGRectMake(0, 200, 320, 40);
	
	//Reposition and resize the receiver
	[tb1 setFrame:rectArea];
	
	//Create a button
	UIBarButtonItem *infoButton1 = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
	[tb1 setItems:[NSArray arrayWithObjects:infoButton1,nil]];
	//Add the toolbar as a subview to the navigation controller.
	[self.navigationController.view addSubview:tb1];
	[tb1 setHidden:TRUE];
	[super viewDidLoad];
}

-(void) btnPressed:(id)sender
{
	pickerView.hidden = FALSE;
	tb1.hidden = FALSE;
	[pickerView reloadAllComponents];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	if([arrData count] > 0)
	{
		return [arrData count]+1;
	}
	else
		return  0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	if([arrData count] > 0)
	{
		NSString *str;
		if(row >= [arrData count])
		{
			str = @"All incident types";
		}
		else
		{
			NSMutableDictionary *dict = [arrData objectAtIndex:row];
			NSMutableDictionary *dict1 = [dict objectForKey:@"category"];	
			str = [dict1 objectForKey:@"title"];
		}
		return str;
	}
	else
		return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component 
{
	if([arrData count] > 0)
	{
		NSString *str;
		if(row >= [arrData count])
		{
			str = @"All incident types";
			[button setTitle:[NSString stringWithFormat:@"%@",str] forState:normal];
			other = FALSE;
		}
		else
		{
			NSMutableDictionary *dict = [arrData objectAtIndex:row];
			NSMutableDictionary *dict1 = [dict objectForKey:@"category"];	
			str = [dict1 objectForKey:@"title"];
			[button setTitle:[NSString stringWithFormat:@"%@",str] forState:normal];
			catid = [[dict1 objectForKey:@"id"] intValue];
			other = TRUE;
		}
	}
}


-(void) done
{
	tb1.hidden = TRUE;
	if(other)
	{
		[pickerView setHidden:TRUE];
		app.arrCategory = [app getCategoriesByid:catid];
		[self changeSegment:nil];
	}
	else
	{
		[pickerView setHidden:TRUE];
	}
	[tblView reloadData];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	if(other)
	{
		return [app.arrCategory count];
	}
	else
	return [app.incidentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 115;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
	[tblView deselectRowAtIndexPath:indexPath animated:YES];
    CustomCell *cell = (CustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	[tblView deselectRowAtIndexPath:indexPath animated:YES];
	// Configure the cell.
	cell.incImage.hidden = FALSE;
	NSMutableDictionary *dict;
	if(other)
	{
		dict = [app.arrCategory objectAtIndex:indexPath.row];
	}
	else
	{
		dict = [app.incidentArray objectAtIndex:indexPath.row];
	}
	
	NSMutableDictionary *dict1 = [dict objectForKey:@"incident"];	
	NSString *str = [dict1 objectForKey:@"incidenttitle"];
	cell.incName.text = str;
	cell.locationName.text = [@"Location: " stringByAppendingString:[dict1 objectForKey:@"locationname"]];
	[df setDateFormat:@"yyyy-mm-dd hh:mm"];
	NSDate *t1 = [df dateFromString:[dict1 objectForKey:@"incidentdate"]];
	[df setDateFormat:@"MM/dd/YYYY hh:mm"];
	cell.date1.text = [@"Date: " stringByAppendingString:[df stringFromDate:t1]];
	NSString *ts = [dict1 objectForKey:@"incidentverified"];
	if([ts isEqualToString:@"1"])
	{
		cell.verified.text = @"Verified";
		[cell.verified setTextColor:[UIColor greenColor]];
	}
	else
	{
		cell.verified.text = @"Not Verified";
		[cell.verified setTextColor:[UIColor redColor]];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	showIncidentDetails *sh = [[showIncidentDetails alloc] initWithNibName:@"showIncidentDetails" bundle:nil];
	if(other)
	{
		sh.dict = [app.arrCategory objectAtIndex:indexPath.row];
	}
	else
	{
		sh.dict = [app.incidentArray objectAtIndex:indexPath.row];
	}
	[self.navigationController pushViewController:sh animated:YES];
}

-(void)changeSegment:(id)sender
{
	if(seg.selectedSegmentIndex == 0)
	{
		tblView.hidden = FALSE;
		mk.hidden = TRUE;
		[tb setItems:[NSArray arrayWithObjects:flexible,btn,flexible,nil]];
	}
	else
	{
		tblView.hidden = TRUE;
		mk.hidden = FALSE;
		[tb setItems:[NSArray arrayWithObjects:infoButton,flexible,btn,flexible,btn1,nil]];
		if(mk.annotations)
		{
			[mk removeAnnotations:mk.annotations];
		}
		
		if(other)
		{
			for(int i=0;i<[app.arrCategory count];i++)
			{
			NSMutableDictionary *dictionary = [app.arrCategory objectAtIndex:i];
			NSString *str = [dictionary objectForKey:@"coordinates"];
			NSArray *tmp = [str componentsSeparatedByString:@","];	
			float t1 = [[tmp objectAtIndex:1] floatValue];
			locate1[i].latitude= t1;
			float t2 = [[tmp objectAtIndex:0] floatValue];
			locate1[i].longitude = t2;
			region.center=locate1[i];
			region.span=span;
			//geoCoder=[[MKReverseGeocoder alloc] initWithCoordinate:locate1[i]];
//			geoCoder.delegate=self;
//			[geoCoder start];
				
				ann[i] = [[MyAnnotation alloc] init];
				ann[i].coordinate = region.center;
				 [mk addAnnotation:ann[i]];
			}
		}
		else
		{
			
		}
	}
}


- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	MKAnnotationView *a = [ [ MKAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    if ( a == nil )
        a = [ [ MKAnnotationView alloc ] initWithAnnotation:annotation reuseIdentifier: @"currentloc" ];
    a.image = [ UIImage imageNamed:@"pin.png" ];
    a.canShowCallout = YES;
    a.rightCalloutAccessoryView = [ UIButton buttonWithType:UIButtonTypeDetailDisclosure ];
    UIImageView *imgView = [ [ UIImageView alloc ] initWithImage:[ UIImage imageNamed:@"bus_stop_30x30.png" ] ];
    a.leftCalloutAccessoryView = imgView;
    return a;
	
}



//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
//{
//	NSLog(@"Reverse Geocoder Errored");
//}
//
//- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
//	NSLog(@"Placemark Found");
//	mPlacemark = placemark;
//	[mk addAnnotation:placemark];
//}

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
