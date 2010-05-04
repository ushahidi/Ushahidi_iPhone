//
//  settings.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 23/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UshahidiProjAppDelegate;
@interface settings : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {

	UshahidiProjAppDelegate *app;
	IBOutlet UITableView *tblView;
	NSMutableArray *data,*data1;
	UITextField *url1,*fname1,*lname1,*email1;
	IBOutlet UIView *v1;
	
}
-(IBAction)clear_Clicked:(id)sender;
@end
