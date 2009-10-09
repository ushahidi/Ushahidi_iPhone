//
//  SettingsViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/21/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingsViewController : UITableViewController {
	//Instance
	UILabel *instanceSettingControl;
	
	//Refresh
	UISwitch *autoRefreshControl;
	UISegmentedControl *autoRefreshIntervalControl;
	
	//Location
	UILabel *defaultLocationControl;
	UISwitch *autoLocateControl;
	
	//Map
	UISegmentedControl *mapStyleControl;
}

@end
