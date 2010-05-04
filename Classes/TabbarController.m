//
//  TabbarController.m
//  CrickMate
//
//  Created by iSoft Solutions on 12/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import "TabbarController.h"
#import "viewIncident.h"
#import "addIncident.h"
#import "settings.h"
#import "syncData.h"
 
@implementation TabbarController

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonSystemItemDone target:self action:nil];
	
	viewIncident *vin =[[viewIncident alloc] initWithNibName:@"viewIncident" bundle:nil];
	UINavigationController *nav1=[[UINavigationController alloc] initWithRootViewController:vin];
	vin.title = @"Reports";
	vin.tabBarItem.image = [UIImage imageNamed:@"incidents.png"];
	
	addIncident *ain =[[addIncident alloc] initWithNibName:@"addIncident" bundle:nil];
	UINavigationController *nav2=[[UINavigationController alloc] initWithRootViewController:ain];
	ain.tabBarItem.image = [UIImage imageNamed:@"comment.png"];
	ain.title = @"Add Report";
	
	settings *set =[[settings alloc] initWithNibName:@"settings" bundle:nil];
	UINavigationController *nav3=[[UINavigationController alloc] initWithRootViewController:set];
	set.tabBarItem.image = [UIImage imageNamed:@"settings.png"];
	set.title = @"Settings";
	
	syncData *sc =[[syncData alloc] initWithNibName:@"syncData" bundle:nil];
	UINavigationController *nav4=[[UINavigationController alloc] initWithRootViewController:sc];
	sc.title = @"Synchronize";
	sc.tabBarItem.image = [UIImage imageNamed:@"sync.png"];
	
	NSArray *controllers=[NSArray arrayWithObjects:nav1,nav2,nav3,nav4,nil];
	self.viewControllers = controllers;
//	[controllers release];
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
