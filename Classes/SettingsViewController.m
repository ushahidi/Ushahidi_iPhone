//
//  SettingsViewController.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/21/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	
	if(self != nil) {
		self.title = @"Settings";
	}
	
	return self;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Settings";
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideView)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSettings)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
}

- (void)hideView {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)saveSettings {
	//
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
			break;
		case 1:
			return 2;
			break;
		case 2:
			return 2;
			break;
		case 3:
			return 1;
			break;
	}
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Instance Settings";
			break;
		case 1:
			return @"Refresh Settings";
			break;
		case 2:
			return @"Location Settings";
			break;
		case 3:
			return @"Map Settings";
			break;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = [NSString stringWithFormat:@"$d:%d", [indexPath indexAtPosition:0], [indexPath indexAtPosition:1]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		switch ([indexPath indexAtPosition:0]) {
			case 0:
				switch ([indexPath indexAtPosition:1]) {
					case 0:
						instanceSettingControl = [[UILabel alloc] initWithFrame:CGRectMake(150, 12, 125, 20)];
						instanceSettingControl.textColor = [UIColor grayColor];
						instanceSettingControl.text = @"http://..";
						[cell addSubview:instanceSettingControl];
						cell.textLabel.text = @"Instance";
						break;
				}
				break;
			case 1:
				switch ([indexPath indexAtPosition:1]) {
					case 0:
						autoRefreshControl = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 0, 0)];
						autoRefreshControl.on = NO;
						[cell addSubview:autoRefreshControl];
						cell.textLabel.text = @"Auto-refresh";
						break;
					case 1:
						autoRefreshIntervalControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(170, 5, 125, 35)];
						[autoRefreshIntervalControl insertSegmentWithTitle:@"15" atIndex:0 animated:NO];
						[autoRefreshIntervalControl insertSegmentWithTitle:@"30" atIndex:1 animated:NO];
						[autoRefreshIntervalControl insertSegmentWithTitle:@"45" atIndex:2 animated:NO];
						[autoRefreshIntervalControl insertSegmentWithTitle:@"60" atIndex:3 animated:NO];
						autoRefreshIntervalControl.segmentedControlStyle = UISegmentedControlStyleBar;
						[cell addSubview:autoRefreshIntervalControl];
						cell.textLabel.text = @"Interval";
						break;
				}
				break;
			case 2:
				switch ([indexPath indexAtPosition:1]) {
					case 0:
						defaultLocationControl = [[UILabel alloc] initWithFrame:CGRectMake(150, 12, 125, 20)];
						defaultLocationControl.text = @"Default location...";		
						defaultLocationControl.textColor = [UIColor grayColor];
						[cell addSubview:defaultLocationControl];
						cell.textLabel.text = @"Default Loc.";
						break;
					case 1:
						autoLocateControl = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 0, 0)];
						autoLocateControl.on = YES;
						[cell addSubview:autoLocateControl];
						cell.textLabel.text = @"Auto-locate";
						break;
				}
				break;
			case 3:
				switch ([indexPath indexAtPosition:1]) {
					case 0:
						mapStyleControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(140, 5, 150, 35)];
						[mapStyleControl insertSegmentWithTitle:@"Map" atIndex:0 animated:NO];
						[mapStyleControl insertSegmentWithTitle:@"Satellite" atIndex:1 animated:NO];
						[mapStyleControl insertSegmentWithTitle:@"Hybrid" atIndex:2 animated:NO];
						mapStyleControl.segmentedControlStyle = UISegmentedControlStyleBar;
						[cell addSubview:mapStyleControl];
						cell.textLabel.text = @"Map Style";
						break;
				}
				break;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 

}


- (void)dealloc {
	[instanceSettingControl release];
	[autoRefreshControl release];
	[autoRefreshIntervalControl release];
	[defaultLocationControl release];
	[autoLocateControl release];
	[mapStyleControl release];
    [super dealloc];
}


@end
