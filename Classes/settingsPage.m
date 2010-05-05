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

#import "settingsPage.h"
#import "UshahidiProjAppDelegate.h"

@implementation settingsPage
@synthesize selectedQ;
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
	pickerView.delegate = self;
	arr = [[NSMutableArray alloc] init];
	[arr addObject:@"100"];
	[arr addObject:@"250"];
	[arr addObject:@"500"];
	[arr addObject:@"1000"];
	[arr retain];
	
	if(selectedQ == 0)
	{
		seg.hidden = TRUE;
		pickerView.hidden = FALSE;
		self.title = @"Number of Reports";
 	}
	else
	{
		self.title = @"Select Map Type";
		seg.hidden = FALSE;
		pickerView.hidden = TRUE;
	}
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	if([app.mapType isEqualToString:@"Google Standard"] )
		seg.selectedSegmentIndex = 0;
	else if([app.mapType isEqualToString:@"Google Hybrid"] )
		seg.selectedSegmentIndex = 1;
	else if([app.mapType isEqualToString:@"Google Satelite"] )
		seg.selectedSegmentIndex = 2;
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(done_Clicked)];
}

-(IBAction)change_Segment:(id)sender
{
	if(seg.selectedSegmentIndex == 0)
	{
		app.mapType = @"Google Standard";
		[app.mapType retain];
	}
	else if(seg.selectedSegmentIndex == 1)
	{
		app.mapType = @"Google Hybrid";
		[app.mapType retain];
	}
	else if(seg.selectedSegmentIndex == 2)
	{
		app.mapType = @"Google Satellite";
		[app.mapType retain];
	}
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

#pragma mark PickerView Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	if([arr count] > 0)
		return [arr count];
	else
		return  0;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	if([arr count] > 0)
	{
		NSString *str = [arr objectAtIndex:row];
		
		return str;
	}
	return nil;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component 
{
	NSString *str = [arr objectAtIndex:row];
	app.reports = str;
	[app.reports retain];
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
