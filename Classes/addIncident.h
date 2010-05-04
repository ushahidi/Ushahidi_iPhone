//
//  addIncident.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 23/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
// Forward Class Declararion
@class UshahidiProjAppDelegate;
@interface addIncident : UIViewController <UITextViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{

	IBOutlet UITextView *tv;
	IBOutlet UITableView *tblView;
	IBOutlet UIView *v1;
	NSMutableArray *arr;
	NSDateFormatter *df;
	NSString *dateStr;
	UITextField *textTitle;
	UshahidiProjAppDelegate *app;
} 


@end
