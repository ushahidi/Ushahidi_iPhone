//
//  RootViewController.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/19/09.
//  Copyright African Pixel 2009. All rights reserved.
//

#import "RootViewController.h"
#import <QuartzCore/CAAnimation.h>


@implementation RootViewController

//@synthesize fetchedResultsController, managedObjectContext;
@synthesize segmentedControl, mapView, tableView;
@synthesize settingsButton, categoriesButton, refreshButton, aboutButton;
@synthesize delegate, incidents;
@synthesize detailView;

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
	segmentedControl.selectedSegmentIndex = 0;
	if([CategoriesViewController categoryChanged] == YES)
	{
		self.incidents = [NSArray arrayWithArray:[CategoriesViewController filteredIncidents]];
		[tableView reloadData];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.delegate = [[UIApplication sharedApplication] delegate];

	// Set up the edit and add buttons.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl insertSegmentWithTitle:@"Incident List" atIndex:0 animated:NO];
	[segmentedControl insertSegmentWithTitle:@"Incident Map" atIndex:1 animated:NO];
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];
	
	/*
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Handle the error...
	}
	*/
	incidents = [[NSMutableArray alloc] initWithArray:[self.delegate.instanceAPI allIncidents]];
}

- (void)refreshData {
	self.incidents = [self.delegate.instanceAPI allIncidents];
}

- (void)refreshIncidents:(id)sender {
	[self refreshData];
	[self.tableView reloadData];
}

- (void)controlPressed:(id)sender {
	@try {
		int selectedIndex = [segmentedControl selectedSegmentIndex];
		switch (selectedIndex) {
			case 0:
				//[self.navigationController popToRootViewControllerAnimated:NO];
				break;
				
			case 1:
				if(self.mapView == nil) {
					IncidentMapViewController *view = [[IncidentMapViewController alloc] initWithNibName:@"IncidentMapView" bundle:[NSBundle mainBundle]];
					self.mapView = view;
					[view release];
				}
				[self.navigationController pushViewController:mapView animated:NO];
				
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


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return [[fetchedResultsController sections] count];
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    //return [sectionInfo numberOfObjects];
	return [incidents count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"%d", [indexPath row]];
	
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.editing = NO;
	}
	
	@try {
		
		// Configure the cell
		
		//NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
		//cell.textLabel.text = [[managedObject valueForKey:@"timeStamp"] description];
		//NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[incidents objectAtIndex:[indexPath row]]];
		//NSMutableDictionary *incident = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"incident"]];
		
		//NSMutableDictionary *dict = [incidents objectAtIndex:[indexPath row]];
		//NSMutableDictionary *incident = [dict objectForKey:@"incident"];
		
		
		cell.imageView.image = [UIImage imageNamed:@"ushahidiicon.png"];
		//cell.textLabel.text = [incident objectForKey:@"incidenttitle"];
		//cell.detailTextLabel.text = [incident objectForKey:@"incidentdescription"];
		
		NSString *t = [NSString stringWithString:[[[self.incidents objectAtIndex:[indexPath row]] objectForKey:@"incident"] objectForKey:@"incidenttitle"]];
		cell.textLabel.text = t;
		cell.detailTextLabel.text = [[[self.incidents objectAtIndex:[indexPath row]] objectForKey:@"incident"] objectForKey:@"incidentdescription"];
		
		//[dict release];
		//[incident release];
		
		
	}
	@catch (NSException * e) {
		NSLog([e reason]);
	}
	
	return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[incidents objectAtIndex:[indexPath row]]];
	NSMutableDictionary *incident = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"incident"]];
	
	if(self.detailView == nil) {
		IncidentDetailViewController *view = [[IncidentDetailViewController alloc] initWithNibName:@"IncidentDetailView" bundle:[NSBundle mainBundle]];
		self.detailView = view;
		[view release];
	}
	
	self.detailView.incident = [NSMutableDictionary dictionaryWithDictionary:incident];
	
	self.detailView.title = [incident objectForKey:@"incidenttitle"];
	self.detailView.incidentLocation.text = [incident objectForKey:@"locationname"];
	self.detailView.incidentDate.text = @""; //[incident objectForKey:@"incidentdate"];
	self.detailView.incidentSummary.text = [incident objectForKey:@"incidentdescription"];
	
	[self.navigationController pushViewController:detailView animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }  
	*/
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}


/*
// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView reloadData];
}
*/

/*
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    
	//Set up the fetched results controller.
	
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    
*/

- (void)dealloc {
	//[fetchedResultsController release];
	//[managedObjectContext release];
	[segmentedControl release];
	[tableView release];
	[mapView release];
	[settingsButton release];
	[refreshButton release];
	[aboutButton release];
	[categoriesButton release];
	[delegate release];
	[incidents release];
	[detailView release];
    [super dealloc];
}


@end

