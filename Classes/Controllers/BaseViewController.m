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

@property(nonatomic, retain) LoadingViewController *loadingView;
@property(nonatomic, retain) InputView *inputView;
@property(nonatomic, retain) AlertView *alertView;

@end

@implementation BaseViewController

@synthesize loadingView, inputView, alertView;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.loadingView = [[LoadingViewController alloc] initWithController:self];
	self.alertView = [[AlertView alloc] initWithController:self];
	self.inputView = [[InputView alloc] initWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[loadingView release];
	[inputView release];
	[alertView release];
    [super dealloc];
}

@end
