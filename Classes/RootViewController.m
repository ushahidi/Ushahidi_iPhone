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

#import "RootViewController.h"
#import "TabbarController.h"

@implementation RootViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	[self.view addSubview:v1];
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(move) userInfo:nil repeats:NO];	
}

// Move the Splash Screen.

-(void) move
{
	[v1 removeFromSuperview];
}

// Methods Implementation goes here.

-(IBAction) add_Incident:(id)sender
{
	TabbarController *tabbar=[[TabbarController alloc] init];
	[self.navigationController pushViewController:tabbar animated:YES];
	tabbar.selectedIndex = 1;
}

-(IBAction) view_Incident:(id)sender
{
	TabbarController *tabbar=[[TabbarController alloc] init];
	[self.navigationController pushViewController:tabbar animated:YES];
}

-(IBAction)settings_Clicked:(id)sender
{
	TabbarController *tabbar=[[TabbarController alloc] init];
	[self.navigationController pushViewController:tabbar animated:YES];
	tabbar.selectedIndex = 2;
}


// Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end

