//
//  IncidentDescViewController.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 10/8/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "IncidentDescViewController.h"


@implementation IncidentDescViewController

@synthesize textView, roundedButton;

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

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Incident Description";
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	textView.text = @"Incident desc...";
	textView.backgroundColor = [UIColor whiteColor];
	
	roundedButton.enabled = NO;
	
	//add done bar button
    //UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing)];
    //self.navigationItem.rightBarButtonItem = doneButton;
	//[doneButton release];
	
}

- (void) doneEditing {
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)incidentDescription {
	return textView.text;
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
	[textView release];
	[roundedButton release];
    [super dealloc];
}


@end
