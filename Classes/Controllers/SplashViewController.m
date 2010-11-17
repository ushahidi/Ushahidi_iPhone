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

#import "SplashViewController.h"
#import "DeploymentsViewController.h"
#import "IncidentsViewController.h"
#import "Settings.h"

@interface SplashViewController ()

- (void) pushNextViewController;

@end

@implementation SplashViewController

@synthesize deploymentsViewController, incidentsViewController;

#pragma mark -
#pragma mark private

- (void) pushNextViewController {
	NSString *lastDeployment = [[Settings sharedSettings] lastDeployment];
	if (lastDeployment != nil) {
		Deployment *deployment = [[Ushahidi sharedUshahidi] getDeploymentWithUrl:lastDeployment];
		[[Ushahidi sharedUshahidi] setDeployment:deployment];
		self.incidentsViewController.deployment = deployment;
		[self.navigationController pushViewController:self.deploymentsViewController animated:NO];
		[self.navigationController pushViewController:self.incidentsViewController animated:YES];
	}
	else {
		[self.navigationController pushViewController:self.deploymentsViewController animated:YES];
	}	
}

#pragma mark -
#pragma mark UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self performSelector:@selector(pushNextViewController) withObject:nil afterDelay:0.3];
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
	[deploymentsViewController release];
    [super dealloc];
}

@end
