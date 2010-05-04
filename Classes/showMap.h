//
//  showMap.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 03/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIViewTouch;
@class UshahidiProjAppDelegate;

@interface showMap : UIViewController {

	UIViewTouch *viewTouch;
	UshahidiProjAppDelegate *app;
	UIToolbar *tb;
	UIBarButtonItem *find,*reset,*flexible;
	NSArray *arrMapData;
 	
}
@property (nonatomic, retain) UIViewTouch *viewTouch;


@end
