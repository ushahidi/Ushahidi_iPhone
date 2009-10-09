//
//  CategoriesViewController.m
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/20/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import "CategoriesViewController.h"


@implementation CategoriesViewController

@synthesize categoryPicker;
@synthesize selectedCategory;
//@synthesize delegate;
@synthesize instanceAPI;
@synthesize categories;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		instanceAPI = [[API alloc] init];
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

+ (BOOL)categoryChanged {
	return catChanged;
}

+ (NSArray *)filteredIncidents {
	return incidents;
}

- (void)viewWillAppear:(BOOL)animated {
	catChanged = NO;
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:YES];
}*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Categories";
	
	categoryPicker.delegate = self;
	categoryPicker.dataSource = self;
	
	selectedCategory.enabled = NO;
	
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideView)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(filterIncidents)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
	
	//
	//self.delegate = [[UIApplication sharedApplication] delegate];
	//[self.delegate getCategories];
	categories = [[NSArray alloc] initWithArray:[instanceAPI categoryNames]];
	
	catChanged = NO;
}

- (void) hideView {
	catChanged = NO;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)filterIncidents {
	incidents = [[NSArray alloc] initWithArray:[instanceAPI incidentsByCategoryId:selectedCatgoryID]];
	catChanged = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [categories count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[categories objectAtIndex:row]];
	NSMutableDictionary *category = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"category"]];
	
	selectedCategory.text = [category objectForKey:@"title"];
	selectedCatgoryID = [[category objectForKey:@"id"] intValue];
	
	catChanged = YES;
	
	[dict release];
	[category release];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[categories objectAtIndex:row]];
	NSMutableDictionary *category = [[NSMutableDictionary alloc] initWithDictionary:[dict objectForKey:@"category"]];
	
	NSString *catName = [category objectForKey:@"title"];
	
	[dict release];
	[category release];
	
	return catName;
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
    [selectedCategory release];
	[categoryPicker release];
	//[delegate release];
	[instanceAPI release];
	[categories release];
	[super dealloc];
}


@end
