    //
//  SplashViewController.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SplashViewController.h"
#import "InstancesViewController.h"

@interface SplashViewController ()

- (void) pushInstanceViewController;

@end

@implementation SplashViewController

@synthesize instancesViewController;

#pragma mark -
#pragma mark private

- (void) pushInstanceViewController {
	[self.navigationController pushViewController:self.instancesViewController animated:YES];
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self performSelector:@selector(pushInstanceViewController) withObject:nil afterDelay:0.5];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	if (self.navigationController.modalViewController == nil) {
		[self.navigationController setNavigationBarHidden:NO animated:animated];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[instancesViewController release];
    [super dealloc];
}

@end
