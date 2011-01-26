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

#import "ItemPicker.h"
#import "NSObject+Extension.h"
#import "Device.h"

@interface ItemPicker ()

@property (nonatomic, retain) IBOutlet UIViewController *controller;
@property (nonatomic, assign) id<ItemPickerDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *popoverController;

@end

@implementation ItemPicker

@synthesize delegate, controller, item, items, popoverController;

- (id) initWithDelegate:(id<ItemPickerDelegate>)theDelegate forController:(UIViewController *)theController {
	if (self = [super init]) {
		self.delegate = theDelegate;
		self.controller = theController;
	}
    return self;
}

- (void) showWithItems:(NSArray *)theItems withSelected:(NSString *)theItem forRect:(CGRect)rect {
	self.items = theItems;
	self.item = theItem;
	
	UIPickerView *pickerView = [[[UIPickerView alloc] init] autorelease];
	pickerView.delegate = self;
	pickerView.showsSelectionIndicator = YES;
	
	if (theItem != nil) {
		NSInteger index = 0;
		for (NSString *row in theItems) {
			if ([row isEqualToString:theItem]) {
				[pickerView selectRow:index inComponent:0 animated:NO];
				break;
			}
			index++;
		}
	}
	
	if ([Device isIPad]) {
		UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
		viewController.view = pickerView;
		viewController.view.frame = CGRectMake(0,0,320,160);
		
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		[self.popoverController setPopoverContentSize:CGSizeMake(320, 160) animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:rect
												inView:self.controller.view 
							  permittedArrowDirections:UIPopoverArrowDirectionDown 
											  animated:YES];
	}
	else {
		UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
																  delegate:self
														 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
													destructiveButtonTitle:nil
														 otherButtonTitles:NSLocalizedString(@"Select", nil), nil] autorelease];    
		
		[actionSheet addSubview:pickerView];
		[actionSheet showInView:self.controller.view];
		
		CGRect actionSheetRect = actionSheet.frame;
		actionSheetRect.origin.y -= pickerView.frame.size.height;
		actionSheetRect.size.height += pickerView.frame.size.height;
		actionSheet.frame = actionSheetRect;
		
		CGRect pickerViewRect = pickerView.frame;
		pickerViewRect.origin.y = 150;
		pickerView.frame = pickerViewRect;
	}
}

- (void)dealloc {
	delegate = nil;
	[item release];
	[items release];
	[controller release];
	[popoverController release];
    [super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		[self dispatchSelector:@selector(itemPickerCancelled:) 
						target:self.delegate 
					   objects:self, nil];
	}
	else {
		[self dispatchSelector:@selector(itemPickerReturned:item:) 
						target:self.delegate 
					   objects:self, self.item, nil];	
	}
}

#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	self.item = [self.items objectAtIndex:row];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return self.items != nil ? [self.items objectAtIndex:row] : nil;
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return self.items != nil ? [self.items count] : 0;
}

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	DLog(@"");
	[self dispatchSelector:@selector(itemPickerReturned:item:) 
					target:self.delegate 
				   objects:self, self.item, nil];
}

@end
