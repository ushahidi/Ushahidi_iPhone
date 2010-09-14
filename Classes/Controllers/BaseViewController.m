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

#import "BaseViewController.h"
#import "LoadingViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

@synthesize loadingView, inputView, alertView, willBePushed, wasPushed;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.loadingView = [[LoadingViewController alloc] initWithController:self];
	self.alertView = [[AlertView alloc] initWithController:self];
	self.inputView = [[InputView alloc] initWithDelegate:self];
}

- (void)dealloc {
	[loadingView release];
	[inputView release];
	[alertView release];
    [super dealloc];
}

- (void)viewWillBePushed {
	DLog(@"nib: %@", self.nibName);
	self.willBePushed = YES;
}

- (void)viewWasPushed {
	DLog(@"nib: %@", self.nibName);
	self.wasPushed = YES;
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.willBePushed = NO;
	self.wasPushed = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	DLog(@"%@", self.nibName);
}

- (void)viewDidUnload {
    [super viewDidUnload];
	DLog(@"%@", self.nibName);
}

@end
