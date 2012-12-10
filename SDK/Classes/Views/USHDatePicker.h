/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol USHDatePickerDelegate;

@interface USHDatePicker : NSObject<UIPickerViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate> 

@property (nonatomic, retain) NSDate *date;

- (id) initForDelegate:(UIViewController<USHDatePickerDelegate>*)delegate;
- (void) showWithDate:(NSDate *)date mode:(UIDatePickerMode)datePickerMode indexPath:(NSIndexPath *)indexPath forRect:(CGRect)rect;

@end

@protocol USHDatePickerDelegate <NSObject>

@optional

- (void) datePickerReturned:(USHDatePicker *)datePicker indexPath:(NSIndexPath *)indexPath date:(NSDate *)date;
- (void) datePickerCancelled:(USHDatePicker *)datePicker indexPath:(NSIndexPath *)indexPath;

@end
