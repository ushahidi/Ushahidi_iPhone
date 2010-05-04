//
//  settingsPage.h
//  UshahidiProj
//
//  Created by HardikMaheta on 05/04/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UshahidiProjAppDelegate;
@interface settingsPage : UIViewController<UIPickerViewDelegate> {

	IBOutlet UIPickerView *pickerView;
	IBOutlet UISegmentedControl *seg;
	NSMutableArray *arr;
	int selectedQ;
	UshahidiProjAppDelegate *app;
}
@property (nonatomic,readwrite) int selectedQ;

-(IBAction)change_Segment:(id)sender;
@end
