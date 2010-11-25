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
#import "Device.h"
#import "NSObject+Extension.h"

@interface DatePicker ()

@property (nonatomic, retain) IBOutlet UIViewController *controller;
@property (nonatomic, assign) id<DatePickerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)dateChanged:(id)sender;

@end

@implementation DatePicker

@synthesize delegate, controller, date, indexPath, popoverController;

- (id) initForDelegate:(id<DatePickerDelegate>)theDelegate forController:(UIViewController *)theController {
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.controller = theController;
	}
    return self;
}

- (void) showWithDate:(NSDate *)theDate mode:(UIDatePickerMode)datePickerMode indexPath:(NSIndexPath *)theIndexPath forRect:(CGRect)rect {
	self.indexPath = theIndexPath;
	self.date = theDate != nil  && [theDate timeIntervalSince1970] > 0 ? theDate : [NSDate date];
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,0,320,160)];
	datePicker.datePickerMode = datePickerMode;
	[datePicker addTarget:self
				   action:@selector(dateChanged:)
		 forControlEvents:UIControlEventValueChanged];
	
	[datePicker setDate:self.date animated:NO];
	
	if ([Device isIPad]) {
		UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
		viewController.view = datePicker;
		viewController.view.frame = CGRectMake(0,0,320,160);
		
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		[self.popoverController setPopoverContentSize:CGSizeMake(320, 160) animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:rect
		 										inView:self.controller.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
	}
	else {
		UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
																  delegate:self
														 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
													destructiveButtonTitle:nil
														 otherButtonTitles:NSLocalizedString(@"Select", @"Select"), 
																		   NSLocalizedString(@"Clear", @"Clear"), nil] autorelease];    
		
		[actionSheet addSubview:datePicker];
		[actionSheet showInView:self.controller.view];        
		
		CGRect actionSheetRect = actionSheet.frame;
		actionSheetRect.origin.y -= datePicker.frame.size.height;
		actionSheetRect.size.height += datePicker.frame.size.height;
		actionSheet.frame = actionSheetRect;
		
		CGRect datePickerRect = datePicker.frame;
		datePickerRect.origin.y = 207;
		datePicker.frame = datePickerRect;
	}
}

- (void)dealloc {
	delegate = nil;
	[date release];
	[controller release];
	[popoverController release];
    [super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([titleAtIndex isEqualToString:NSLocalizedString(@"Select", @"Select")]) {
		[self dispatchSelector:@selector(datePickerReturned:date:indexPath:) 
						target:delegate objects:self, self.date, self.indexPath, nil];
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"Clear", @"Clear")]) {
		self.date = nil;
		SEL selector = @selector(datePickerReturned:date:indexPath:);
		if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
			[self.delegate datePickerReturned:self date:nil indexPath:self.indexPath];
		}
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"Cancel", @"Cancel")]) {
		[self dispatchSelector:@selector(datePickerCancelled:) 
						target:delegate objects:self, nil];
	}
}

#pragma mark UIPickerViewDelegate

- (void)dateChanged:(id)sender {
	UIDatePicker *datePicker = (UIDatePicker *)sender;
	DLog(@"date: %@", datePicker.date);
	self.date = datePicker.date;
}

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	DLog(@"");
	[self dispatchSelector:@selector(datePickerReturned:date:indexPath:) 
					target:delegate objects:self, self.date, self.indexPath, nil];
}

@end
