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

#import "ImagePickerController.h"
#import "Device.h"

#define kCancel @"Cancel"
#define kTakePhoto @"Take Photo"
#define kFromLibrary @"From Library"

@interface ImagePickerController ()

- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void) notifyDelegateWithImage:(UIImage *)image;

@end

@implementation ImagePickerController

@synthesize viewController, popoverController, delegate;

- (id)initWithController:(UIViewController *)controller {
    if ((self = [super init])) {
		self.viewController = controller;
	}
    return self;
}

- (void) showImagePickerWithDelegate:(id<ImagePickerDelegate>)theDelegate {
	self.delegate = theDelegate;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:kCancel
												   destructiveButtonTitle:nil
														otherButtonTitles:kTakePhoto, kFromLibrary, nil];
		[actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
		[actionSheet showInView:self.viewController.view];
		[actionSheet release];
	}
	else {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

- (void)dealloc {
	delegate = nil;
	[viewController release];
	[popoverController release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark Internal

- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	DLog(@"showImagePicker:%d", sourceType);
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = sourceType;
	if ([Device isIPad]) {
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		self.popoverController = popover;
		[popover release];
		popover.delegate = self;
		[popover presentPopoverFromRect:self.viewController.view.frame inView:self.viewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	else {
		[viewController presentModalViewController:imagePicker animated:YES];
	}
	[imagePicker release];
}

- (void) notifyDelegateWithImage:(UIImage *)image {
	SEL selector = @selector(imagePicker:selectedImage:);
	if (delegate != NULL && [delegate respondsToSelector:selector]) {
		[delegate imagePicker:self selectedImage:image];
	}
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	DLog(@"editingInfo: %@", editingInfo);
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self notifyDelegateWithImage:image];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	DLog(@"info: %@", info);
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self notifyDelegateWithImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	DLog(@"");
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
	if ([titleAtIndex isEqualToString:kTakePhoto]) {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([titleAtIndex isEqualToString:kFromLibrary]) {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

@end
