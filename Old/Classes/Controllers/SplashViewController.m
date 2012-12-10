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
#import "Device.h"

@implementation SplashViewController

@synthesize shouldDismissOnAppear;

- (void) dismissSplashViewController {
    DLog(@"");
    [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:0.1];  
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;  
    if (self.shouldDismissOnAppear) {
        [self dismissSplashViewController];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
