//
//  TableViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	
@public
	UITableView *tableView;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;

@end
