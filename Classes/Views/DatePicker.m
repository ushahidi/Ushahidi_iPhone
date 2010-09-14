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

#import "DatePicker.h"

#define kActionCancel @"Cancel"
#define kActionSelect @"Select"

@interface DatePicker ()

@property (nonatomic, retain) IBOutlet UIViewController *controller;
@property (nonatomic, assign) id<DatePickerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (void)dateChanged:(id)sender;

@end


@implementation DatePicker

@synthesize delegate, controller, date, indexPath;

- (id) initWithDelegate:(id<DatePickerDelegate>)theDelegate forController:(UIViewController *)theController {
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.controller = theController;
	}
    return self;
}

- (void) showWithDate:(NSDate *)theDate mode:(UIDatePickerMode)datePickerMode indexPath:(NSIndexPath *)theIndexPath {
	self.indexPath = theIndexPath;
	self.date = theDate != nil  && [theDate timeIntervalSince1970] > 0 ? theDate : [NSDate date];
	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self
													cancelButtonTitle:kActionCancel
											   destructiveButtonTitle:nil
													otherButtonTitles:kActionSelect, nil] autorelease];    
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.datePickerMode = datePickerMode;
	[datePicker addTarget:self
	               action:@selector(dateChanged:)
	     forControlEvents:UIControlEventValueChanged];
	
	[datePicker setDate:self.date animated:NO];
	
	[actionSheet addSubview:datePicker];
	[actionSheet showInView:self.controller.view];        
	
	CGRect actionSheetRect = actionSheet.frame;
	actionSheetRect.origin.y -= datePicker.frame.size.height;
	actionSheetRect.size.height += datePicker.frame.size.height;
	actionSheet.frame = actionSheetRect;
	
	CGRect datePickerRect = datePicker.frame;
	datePickerRect.origin.y = 150;
	datePicker.frame = datePickerRect;
	
	[datePicker release];
}

- (void)dealloc {
	delegate = nil;
	[date release];
	[controller release];
    [super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([titleAtIndex isEqualToString:kActionSelect]) {
		SEL selector = @selector(datePickerReturned:date:indexPath:);
		if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
			[self.delegate datePickerReturned:self date:self.date indexPath:self.indexPath];
		}
	}
	else if ([titleAtIndex isEqualToString:kActionCancel]) {
		SEL selector = @selector(datePickerCancelled:);
		if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
			[self.delegate datePickerCancelled:self];
		}
	}
}

#pragma mark UIPickerViewDelegate

- (void)dateChanged:(id)sender {
	UIDatePicker *datePicker = (UIDatePicker *)sender;
	DLog(@"date: %@", datePicker.date);
	self.date = datePicker.date;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	DLog(@"row: %@", [pickerView selectedRowInComponent:component]);
}

@end
