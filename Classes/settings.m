//
//  settings.m
//  UshahidiProj
//
//  Created by iSoft Solutions on 23/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import "settings.h"
#import "CustomCell.h"
#import "UshahidiProjAppDelegate.h"
#import "settingsPage.h"
#import "infoScreen.h"

@implementation settings

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/
-(void)save_Clicked:(id)sender
{
	app.fname = fname1.text;
	[app.fname retain];
	app.lname = lname1.text;
	[app.lname retain];
	app.urlString = url1.text;
	[app.urlString retain];
	app.emailStr = email1.text;
	[app.emailStr retain];
	
	NSUserDefaults *st = [NSUserDefaults standardUserDefaults];
	if(st)
	{
		[st setObject:app.reports forKey:@"reports"];
		[st setObject:app.mapType forKey:@"maptype"];
		[st setObject:app.urlString forKey:@"urlString"];
		[st setObject:app.fname forKey:@"fname"];
		[st setObject:app.lname forKey:@"lname"];
		[st setObject:app.emailStr forKey:@"email"];
		[st synchronize];
	}
	
}

-(void)about_Clicked:(id)sender
{
	infoScreen *info = [[infoScreen alloc] initWithNibName:@"infoScreen" bundle:nil];
	[self.navigationController pushViewController:info animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save_Clicked:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"About Us" style:UIBarButtonItemStylePlain target:self action:@selector(about_Clicked:)];

	[tblView reloadData];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   
	app = [[UIApplication sharedApplication] delegate];
	tblView.delegate = self;
	tblView.dataSource = self;
	data = [[NSMutableArray alloc] init];
	[data addObject:@"Ushahidi URL"];
	[data addObject:@"First Name"];
	[data addObject:@"Last Name"];
	[data addObject:@"Email"];
	data1  = [[NSMutableArray alloc] init];
	[data1 addObject:@"Show"];
	[data1 addObject:@"Map Type"];
	
	[super viewDidLoad];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return TRUE;
}


#pragma mark Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0)
	return 4;
	else
		return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    CustomCell *cell = (CustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.lbl_Title.hidden = FALSE;
	tblView.tableFooterView = v1;
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.txt.delegate = self;
	if(indexPath.section == 1)
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.lbl_Title.text = [data1 objectAtIndex:indexPath.row];
		cell.lbl_setting.hidden = FALSE;
		if(indexPath.row == 0)
		{
			cell.lbl_setting.text  = [NSString stringWithFormat:@"%@ Recent Reports",app.reports];	
		}
		else if(indexPath.row == 1)
		{
			cell.lbl_setting.text  = app.mapType;
		}
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.lbl_Title.text = [data objectAtIndex:indexPath.row];
		if(indexPath.row == 0)
		{
			url1 = cell.txt;
			cell.txt.tag = 0;
			[cell.txt setPlaceholder:@"example:ushahidi.com"];
			cell.txt.text = app.urlString;
		}
		else if(indexPath.row == 1)
		{
			fname1 = cell.txt;
			cell.txt.tag = 1;
			[cell.txt setPlaceholder:@"Optional"];
			if([app.fname length] > 0)
			cell.txt.text = app.fname;
		}
		else if(indexPath.row == 2)
		{
			lname1 = cell.txt;
			cell.txt.tag = 1;
			[cell.txt setPlaceholder:@"Optional"];
			if([app.lname length] > 0)
			cell.txt.text = app.lname;
		}
		else if(indexPath.row == 3)
		{
			email1 = cell.txt;
			cell.txt.tag = 1;
			[cell.txt setPlaceholder:@"Optional"];
			if([app.emailStr length] > 0)
			cell.txt.text = app.emailStr;
		}
		cell.txt.hidden = FALSE;
	}
	
	// Configure the cell.
	    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 1)
	{
		settingsPage *sp = [[settingsPage alloc] initWithNibName:@"settingsPage" bundle:nil];
		sp.selectedQ = indexPath.row;
		[self.navigationController pushViewController:sp animated:YES];
	}
}


-(IBAction)clear_Clicked:(id)sender
{
	app.fname = @"";
	app.lname = @"";
	app.emailStr = @"";
	app.reports = @"100";
	app.mapType = @"Google Stardard";
	app.urlString = @"demo.ushahidi.com";
	[tblView reloadData];
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
