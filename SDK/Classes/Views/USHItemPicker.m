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

#import "USHItemPicker.h"
#import "NSObject+USH.h"
#import "USHDevice.h"
#import "UIAlertView+USH.h"
#import "UIEvent+USH.h"

@interface USHItemPicker ()

@property (nonatomic, retain)  UIViewController<USHItemPickerDelegate> *controller;
@property (nonatomic, retain) UIPopoverController *popoverController;

@end

@implementation USHItemPicker

@synthesize controller = _controller;
@synthesize item = _item;
@synthesize items = _items;
@synthesize popoverController = _popoverController;
@synthesize tag = _tag;
@synthesize index = _index;

- (id) initWithController:(UIViewController<USHItemPickerDelegate> *)controller {
	if (self = [super init]) {
		self.controller = controller;
	}
    return self;
}

- (void) showWithItems:(NSArray *)items selected:(NSString *)item event:(UIEvent*)event tag:(NSInteger)tag {
	DLog(@"item:%@ tag:%d", item, tag);
	self.items = items;
	self.item = item;
	self.tag = tag;
	
	UIPickerView *pickerView = [[[UIPickerView alloc] init] autorelease];
	pickerView.delegate = self;
	pickerView.showsSelectionIndicator = YES;
	
	if (item != nil) {
		NSInteger index = 0;
		for (NSString *row in items) {
			if ([row isEqualToString:item]) {
				[pickerView selectRow:index inComponent:0 animated:NO];
				break;
			}
			index++;
		}
	}
	
    CGRect rect = [event getRectForView:self.controller.view];
    
	if ([USHDevice isIPad]) {
		UIViewController *viewController = [[[UIViewController alloc] init] autorelease];
		viewController.view = pickerView;
		viewController.view.frame = CGRectMake(0, 0, 320, 160);
		
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		[self.popoverController setPopoverContentSize:CGSizeMake(320, 160) animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:rect
												inView:self.controller.view 
							  permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
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
	[_item release];
	[_items release];
	[_controller release];
	[_popoverController release];
    [super dealloc];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
       if (self.controller != nil && [self.controller respondsToSelector:@selector(itemPickerCancelled:)]) {
           [self.controller itemPickerCancelled:self];
       }
	}
	else {
        if (self.controller != nil && [self.controller respondsToSelector:@selector(itemPickerReturned:item:index:)]) {
            [self.controller itemPickerReturned:self item:self.item index:self.index];
        }
	}
}

#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.index = row;
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
    if (self.controller != nil && [self.controller respondsToSelector:@selector(itemPickerReturned:item:index:)]) {
        [self.controller itemPickerReturned:self item:self.item index:self.index];
    }
}

@end
