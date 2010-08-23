//
//  SplashViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InstancesViewController;

@interface SplashViewController : UIViewController {
	
@public
	IBOutlet InstancesViewController *instancesViewController;
}

@property(nonatomic, retain) InstancesViewController *instancesViewController;

@end
