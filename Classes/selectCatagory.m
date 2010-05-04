//
//  selectCatagory.m
//  UshahidiProj
//
//  Created by iSoft Solutions on 27/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import "selectCatagory.h"
#import "UshahidiProjAppDelegate.h"
#import "API.h"
@implementation selectCatagory
@synthesize selectedArray;

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
	app.cat = @"";
	tblView.delegate = self;
	tblView.dataSource = self;
	selectedImage = [[UIImage alloc]init];
	unselectedImage = [[UIImage alloc]init];
	selectedImage = [UIImage imageNamed:@"selected.png"];
	unselectedImage = [UIImage imageNamed:@"unselected.png"];
	arrData = [[NSMutableArray alloc] init];
	arrData = [app getCategories];
	[arrData retain];
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.hidesBackButton = TRUE;
	[self populateSelectedArray];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doSelect)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}
// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [arrData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
	static NSString *EditCellIdentifier = @"EditCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EditCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:EditCellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UILabel *label = [[UILabel alloc] initWithFrame:kLabelRect];
		label.tag = kCellLabelTag;
		[cell.contentView addSubview:label];
		[label setFont:[UIFont boldSystemFontOfSize:13]];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor blackColor]];
		[label release];
	
		UIImageView *imageView = [[UIImageView alloc] initWithImage:unselectedImage];
		imageView.frame = CGRectMake(5.0, 18.0, 23.0, 23.0);
		[cell.contentView addSubview:imageView];
		imageView.tag = kCellImageViewTag;
		[imageView release];
	}
	
	NSMutableDictionary *dict = [arrData objectAtIndex:indexPath.row];
	NSMutableDictionary *dict1 = [dict objectForKey:@"category"];
	UILabel *label = (UILabel *)[cell.contentView viewWithTag:kCellLabelTag];
	label.text = [dict1 objectForKey:@"title"];
	label.opaque = NO;
	[label setBackgroundColor:[UIColor clearColor]];
	[label setTextColor:[UIColor blackColor]];
	
	UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
	NSNumber *selected = [selectedArray objectAtIndex:[indexPath row]];
	imageView.image = ([selected boolValue]) ? selectedImage : unselectedImage;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
		BOOL selected = [[selectedArray objectAtIndex:[indexPath row]] boolValue];
		[selectedArray replaceObjectAtIndex:[indexPath row] withObject:[NSNumber numberWithBool:!selected]];
		[tblView reloadData];
}

-(IBAction)doSelect
{
	NSMutableArray *rowsToBeSelected = [[NSMutableArray alloc] init];
	NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
	int index = 0;
	for (NSNumber *rowSelected in selectedArray)
	{
		if ([rowSelected boolValue])
		{
			[rowsToBeSelected addObject:[arrData objectAtIndex:index]];
			NSUInteger pathSource[2] = {0, index};
			NSIndexPath *path = [NSIndexPath indexPathWithIndexes:pathSource length:2];
			[indexPaths addObject:path];
		}		
		index++;
	}
	
	for(int i=0;i<[rowsToBeSelected count];i++)
	{
		NSMutableDictionary *dict = [rowsToBeSelected objectAtIndex:i];
		NSMutableDictionary *dict1 = [dict objectForKey:@"category"];

		NSString *result = [app.cat stringByAppendingString:[dict1 objectForKey:@"id"]];
		NSString *str1 = @",";
		if(i==[rowsToBeSelected count]-1)
		{
			app.cat = result;	
		}
		else
		{
			app.cat = [result stringByAppendingString:str1];
		}
	}
	
	[indexPaths release];
	[rowsToBeSelected release];
	[self.navigationController popViewControllerAnimated:YES];
	[self populateSelectedArray];
	[tblView reloadData];
}

- (void)populateSelectedArray
{
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[arrData count]];
	for (int i=0; i < [arrData count]; i++)
		[array addObject:[NSNumber numberWithBool:NO]];
	self.selectedArray = array;
	[array release];
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
