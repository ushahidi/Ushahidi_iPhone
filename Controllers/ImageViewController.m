    //
//  ImageViewController.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-11.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "ImageViewController.h"

@implementation ImageViewController

@synthesize imageView, image;

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.imageView.image = self.image;
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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
	[imageView release];
	[super dealloc];
}

@end
