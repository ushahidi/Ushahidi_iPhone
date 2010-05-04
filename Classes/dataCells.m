//
//  dataCells.m
//  UshahidiProj
//
//  Created by iSoft Solutions on 08/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import "dataCells.h"
#import "UshahidiProjAppDelegate.h"

@implementation dataCells
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

-(void)done_Clicked
{
	app.dt = txt.text;
	[app.dt retain];
	
	[self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
	self.navigationItem.hidesBackButton = TRUE;
	txt.delegate = self;
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done_Clicked)];
	self.navigationItem.rightBarButtonItem = done;
	self.title = @"Select Date";
	
	df = [[NSDateFormatter alloc] init];
	[df setDateFormat:@"EEE, MMM dd, yyyy hh:mm aa"];	
	app = [[UIApplication sharedApplication] delegate];
	arrData = [[NSMutableArray alloc] init];
	arrData = [app getCategories];
	[arrData retain];
	dtPicker.date = [NSDate date];
	DateStr = [NSString stringWithFormat:@"%@",
			   [df stringFromDate:dtPicker.date]];
	txt.text = DateStr;
	[dtPicker addTarget:self
	               action:@selector(changeDateInLabel:)
	     forControlEvents:UIControlEventValueChanged];
	[super viewDidLoad];
}

// Change Date as According to DatePicker Date
- (void)changeDateInLabel:(id)sender{
	
	DateStr = [NSString stringWithFormat:@"%@",
			   [df stringFromDate:dtPicker.date]];
	[DateStr retain];
	txt.text = DateStr;
}

#pragma mark PickerView Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	if([arrData count] > 0)
		return [arrData count];
	else
		return  0;
}

#pragma mark Memory textField Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return FALSE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	
	return FALSE;
}



#pragma mark Memory Management
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
