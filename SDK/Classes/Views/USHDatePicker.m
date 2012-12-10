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

#import "USHDatePicker.h"
#import "USHDevice.h"
#import "NSObject+USH.h"

@interface USHDatePicker ()

@property (nonatomic, retain) UIViewController<USHDatePickerDelegate> *delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) UIPopoverController *popoverController;

- (void)dateChanged:(id)sender;

@end

@implementation USHDatePicker

@synthesize date = _date;
@synthesize delegate = _delegate;
@synthesize indexPath = _indexPath;
@synthesize popoverController = _popoverController;

- (id) initForDelegate:(UIViewController<USHDatePickerDelegate>*)delegate; {
	if (self = [super init]) {
		self.delegate = delegate;
	}
    return self;
}

- (void) showWithDate:(NSDate *)date mode:(UIDatePickerMode)datePickerMode indexPath:(NSIndexPath *)indexPath forRect:(CGRect)rect {
	self.indexPath = indexPath;
	self.date = date != nil  && [date timeIntervalSince1970] > 0 ? date : [NSDate date];
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,0,320,160)];
	datePicker.datePickerMode = datePickerMode;
	[datePicker addTarget:self
				   action:@selector(dateChanged:)
		 forControlEvents:UIControlEventValueChanged];
	[datePicker setDate:self.date animated:NO];
	
	if ([USHDevice isIPad]) {
		UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
		viewController.view = datePicker;
		viewController.view.frame = CGRectMake(0,0,320,160);
		
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		[self.popoverController setPopoverContentSize:CGSizeMake(320, 160) animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:rect
		 										inView:self.delegate.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
	}
	else {
		UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
																  delegate:self
														 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
													destructiveButtonTitle:nil
														 otherButtonTitles:NSLocalizedString(@"Select", nil), NSLocalizedString(@"Clear", nil), nil] autorelease];    
		
		[actionSheet addSubview:datePicker];
		[actionSheet showInView:self.delegate.view];        
		
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
	[_delegate release];
	[_date release];
	[_popoverController release];
    [super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([titleAtIndex isEqualToString:NSLocalizedString(@"Select", nil)]) {
        [self.delegate performSelectorOnMainThread:@selector(datePickerReturned:indexPath:date:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.indexPath,  self.date, nil];
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"Clear", nil)]) {
		self.date = nil;
		[self.delegate performSelectorOnMainThread:@selector(datePickerReturned:indexPath:date:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.indexPath, nil, nil];
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"Cancel", nil)]) {
        [self.delegate performSelectorOnMainThread:@selector(datePickerCancelled:indexPath:) 
                                     waitUntilDone:YES 
                                       withObjects:self, self.indexPath, nil];
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
    [self.delegate performSelectorOnMainThread:@selector(datePickerReturned:indexPath:date:) 
                                 waitUntilDone:YES 
                                   withObjects:self, self.indexPath, self.date, nil];
}

@end
