//
//  DatePickerViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 10/8/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatePickerViewController : UIViewController {
	UIDatePicker *datePicker;
	NSDate *date;
}
- (void)dateChanged:(id)sender;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *date;
@end
