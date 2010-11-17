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

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

typedef enum {
	NavBarPrevious,
	NavBarNext
} NavBar;

@synthesize imageView, image, images, nextPrevious;

- (IBAction) nextPrevious:(id)sender {
	NSInteger index = [self.images indexOfObject:self.image];
	if (self.nextPrevious.selectedSegmentIndex == NavBarNext) {
		DLog(@"Next Image");
		self.image = [self.images objectAtIndex:index + 1];
		self.imageView.image = [self.images objectAtIndex:index + 1];
	}
	else if (self.nextPrevious.selectedSegmentIndex == NavBarPrevious) {
		DLog(@"Previous Image");
		self.image = [self.images objectAtIndex:index - 1];
		self.imageView.image = [self.images objectAtIndex:index - 1];
	}
	NSInteger newIndex = [self.images indexOfObject:self.image];
	self.title = [NSString stringWithFormat:@"%d / %d", newIndex + 1, [self.images count]];
	[self.nextPrevious setEnabled:(newIndex > 0) forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:(newIndex + 1 < [self.images count]) forSegmentAtIndex:NavBarNext];
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.imageView.image = self.image;
	NSInteger index = [self.images indexOfObject:self.image];
	if (index != NSNotFound) {
		self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.images count]];
		[self.nextPrevious setEnabled:index > 0 forSegmentAtIndex:NavBarPrevious];
		[self.nextPrevious setEnabled:index + 1 < [self.images count] forSegmentAtIndex:NavBarNext];	
	}
	else {
		self.title = @"1 / 1";
		[self.nextPrevious setEnabled:NO forSegmentAtIndex:NavBarPrevious];
		[self.nextPrevious setEnabled:NO forSegmentAtIndex:NavBarNext];
	}
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
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[imageView release];
	[image release];
	[images	release];
	[nextPrevious release];
	[super dealloc];
}

@end
