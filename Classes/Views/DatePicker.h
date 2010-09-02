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

#import <UIKit/UIKit.h>

@protocol DatePickerDelegate;

@interface DatePicker : NSObject<UIPickerViewDelegate, UIActionSheetDelegate> {

@public 
	NSDate *date;

@private
	UIViewController *controller;
	id<DatePickerDelegate>	delegate;
	NSIndexPath *indexPath;
}

@property (nonatomic, retain) NSDate *date;

- (id) initWithDelegate:(id<DatePickerDelegate>)theDelegate forController:(UIViewController *)theController;
- (void) showWithDate:(NSDate *)date mode:(UIDatePickerMode)datePickerMode indexPath:(NSIndexPath *)indexPath;
@end

@protocol DatePickerDelegate <NSObject>

@optional

- (void) datePickerReturned:(DatePicker *)datePicker date:(NSDate *)date indexPath:(NSIndexPath *)indexPath;
- (void) datePickerCancelled:(DatePicker *)datePicker;

@end