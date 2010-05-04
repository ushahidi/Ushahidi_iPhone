//
//  dataCells.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 08/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward Class Declaration
@class UshahidiProjAppDelegate;

@interface dataCells : UIViewController <UITextFieldDelegate,UIPickerViewDelegate>
{
 	IBOutlet UITextField *txt;
	IBOutlet UIDatePicker *dtPicker;
	NSDateFormatter *df;
	NSString *DateStr;
	int selectedQ;
	NSArray *arrData;
	UshahidiProjAppDelegate *app;
 }
@property (nonatomic,readwrite) int selectedQ;
@end
