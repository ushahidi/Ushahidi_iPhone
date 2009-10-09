//
//  ReportViewController.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/23/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "ReportViewController.h"


@implementation ReportViewController

@synthesize incidentAPI, titleTextView, descView, description, categoryView, datePiker, locView, saveButton, doneButton;

@synthesize incident_title;

@synthesize incident_description;

@synthesize incident_date;

@synthesize incident_hour;

@synthesize incident_minute;

@synthesize incident_ampm;

@synthesize incident_category;

@synthesize latitude;

@synthesize longitude; 

@synthesize location_name;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

    self.incidentAPI = [[API alloc] init];
	
	self.title = @"New Report";
	
	self.tableView = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
	
	self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
	
	self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postIncident)];
    self.navigationItem.rightBarButtonItem = saveButton;
	
	description = [[NSString alloc] initWithString:@""];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	//self.navigationItem.rightBarButtonItem = doneButton;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self doneEditing];
	return YES;
}

- (void) doneEditing {
	//self.navigationItem.rightBarButtonItem = saveButton;
	[self.titleTextView resignFirstResponder];
}

- (void) postIncident {
	//TODO: Validation
	
	//create a dictionary
	NSMutableDictionary *props = [NSMutableDictionary dictionaryWithCapacity:0];
	
	//incident_title
	self.incident_title = self.titleTextView.text;
	[props setObject:self.incident_title forKey:@"incident_title"];
	
	//incident_description
	[props setObject:self.incident_description forKey:@"incident_description"];
	
	//incident_date - mm/dd/yyyy
	[props setObject:self.incident_date forKey:@"incident_date"];
	
	//incident_hour
	[props setObject:self.incident_hour forKey:@"incident_hour"];
	
	//incident_minute
	[props setObject:self.incident_minute forKey:@"incident_minute"];
	
	//incident_ampm
	[props setObject:self.incident_ampm forKey:@"incident_ampm"];
	
	//incident_category
	[props setObject:self.incident_category forKey:@"incident_category"];
	
	//latitude
	[props setObject:[NSString stringWithFormat:@"%f", self.latitude] forKey:@"latitude"];
	
	//longitude 
	[props setObject:[NSString stringWithFormat:@"%f", self.longitude] forKey:@"longitude"];
	
	//location_name
	[props setObject:self.location_name forKey:@"location_name"];
	
	//API post
	NSString *msg;
	UIAlertView *notifyAlert;
	if([self.incidentAPI postIncidentWithDictionary:props]) {
		msg = @"Report Success";
		
		notifyAlert = [[UIAlertView alloc] 
					   initWithTitle: @"Notification" message:msg
										  delegate:self
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
		
		[notifyAlert show];
		
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
	else {
		msg = @"Report Failed";
		notifyAlert = [[UIAlertView alloc] 
					   initWithTitle: @"Notification" message:msg
					   delegate:self
					   cancelButtonTitle:@"Ok"
					   otherButtonTitles:nil];
		
		[notifyAlert show];
	}
	
	//n
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[alertView release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
			break;
		case 1:
			return 1;
			break;
		case 2:
			return 3;
			break;
		case 3:
			return 1;
			break;
		case 4:
			return 1;
			break;
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Incident info";
			break;
		case 1:
			return @"Location info";
			break;
		case 2:
			return @"Photos";
			break;
		case 3:
			return @"News Link";
			break;
		case 4:
			return @"Video Link";
			break;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"%d:%d", [indexPath indexAtPosition:0], [indexPath indexAtPosition:1]];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.accessoryType = UITableViewCellAccessoryNone;
					cell.textLabel.text = @"Title";
					if(self.titleTextView == nil) {
						self.titleTextView = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 180, 30)];
						self.titleTextView.text = @"(title)";
						self.titleTextView.delegate = self;
						self.titleTextView.returnKeyType = UIReturnKeyDone;
						[cell addSubview:self.titleTextView];
					}
					break;
				case 1:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.textLabel.text = @"Description";
					if(self.descView != nil) {
						self.incident_description = self.descView.textView.text;
						cell.detailTextLabel.text = self.incident_description;
					}
					else {
						self.incident_description = @"";
						cell.detailTextLabel.text = self.incident_description;
					}
					
					break;
				case 2:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.textLabel.text = @"Category";
					if(self.categoryView != nil) {
						cell.detailTextLabel.text = self.categoryView.currentCategory;
						self.incident_category = self.categoryView.currentCategoryID;
					}
					else {
						self.incident_category = 0;
						cell.detailTextLabel.text = @"";
					}
					break;
				case 3:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.textLabel.text = @"Date";
					NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
					NSDate *date = [NSDate date];
					
					if(self.datePiker != nil) {
						
						date = self.datePiker.date;

					}
					
					/*
					 NSString *incident_date; //mm/dd/yyyy
					 
					 NSString *incident_hour;
					 
					 NSString *incident_minute;
					 
					 NSString *incident_ampm;
					 */
					[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
					[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
					NSString *formattedDateString = [dateFormatter stringFromDate:date];
					cell.detailTextLabel.text = formattedDateString;
					
					[dateFormatter setDateFormat:@"MM/dd/yyyy"];
					formattedDateString = [dateFormatter stringFromDate:date];
					self.incident_date = formattedDateString;
					
					//"%Y-%m-%d %H:%M:%S %z"];
					[dateFormatter setDateFormat:@"H"];
					formattedDateString = [dateFormatter stringFromDate:date];
					self.incident_hour = formattedDateString;
					
					[dateFormatter setDateFormat:@"M"];
					formattedDateString = [dateFormatter stringFromDate:date];
					self.incident_minute = formattedDateString;
					
					if([self.incident_hour intValue] >= 12)
						self.incident_ampm = @"PM";
					else
						self.incident_ampm = @"AM";
					
					break;
				default:
					break;
			}
			break;
		case 1:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.textLabel.text = @"Lat/Long";
					//cell.detailTextLabel.text = @"34.768, 26.678";
					if(self.locView != nil) {
						self.latitude = self.locView.addAnnotation.coordinate.latitude;
						self.longitude = self.locView.addAnnotation.coordinate.longitude;
						self.location_name = self.locView.loc_name;
						NSString *coord = [NSString stringWithFormat:@"%f, %f", self.locView.addAnnotation.coordinate.latitude, self.locView.addAnnotation.coordinate.longitude];
						cell.detailTextLabel.text = coord;
					}
					else {
						self.latitude = 0.0;
						self.longitude = 0.0;
						self.location_name = @"";
						cell.detailTextLabel.text = @"";
					}
					
					break;
			}
			break;
		case 2:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.imageView.image = [UIImage imageNamed:@"ushahidiicon.png"];
					cell.textLabel.text = @"Photo description";
					break;
				case 1:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.imageView.image = [UIImage imageNamed:@"ushahidiicon.png"];
					cell.textLabel.text = @"Photo description";
					break;
				case 2:
					cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
					cell.imageView.image = [UIImage imageNamed:@"ushahidiicon.png"];
					cell.textLabel.text = @"Photo description";
					break;
			}
			break;
		case 3:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = @"Link:";
					cell.detailTextLabel.text = @"http://...";
					break;
			}
			break;
		case 4:
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					cell.textLabel.text = @"Link:";
					cell.detailTextLabel.text = @"http://...";
					break;
			}
			break;
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	switch ([indexPath indexAtPosition:0]) {
		case 0:
			switch ([indexPath indexAtPosition:1]) {
				case 1: //description
					if(self.descView == nil) {
						IncidentDescViewController *view = [[IncidentDescViewController alloc] initWithNibName:@"IncidentDescView" bundle:[NSBundle mainBundle]];
						self.descView = view;
						[view release];
					}
					
					[self.navigationController pushViewController:self.descView animated:YES];
					
					break;
				case 2: //category
					if(self.categoryView == nil) {
						CategorySelectTableViewController *view = [[CategorySelectTableViewController alloc] init];
						self.categoryView = view;
						[view release];
					}
					
					[self.navigationController pushViewController:self.categoryView animated:YES];
					
					break;
				case 3: //date
					if(self.datePiker == nil) {
						DatePickerViewController *view = [[DatePickerViewController alloc] init];
						self.datePiker = view;
						[view release];
					}
					
					[self.navigationController pushViewController:self.datePiker animated:YES];
					
					break;
			}
			break;
			
		case 1: //location
			switch ([indexPath indexAtPosition:1]) {
				case 0:
					if(self.locView == nil) {
						LocationPickerViewController *view = [[LocationPickerViewController alloc] init];
						self.locView = view;
						[view release];
					}
					
					[self.navigationController pushViewController:self.locView animated:YES];
					
					break;
			}
			break;
			
		default:
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[saveButton release];
	[doneButton release];
	[incidentAPI release];
	[descView release];
	[categoryView release];
	[datePiker release];
	[locView release];
	[titleTextView release];
	[description release];
    [super dealloc];
}


@end

