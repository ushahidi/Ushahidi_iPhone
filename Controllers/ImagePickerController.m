    //
//  ImagePickerController.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "ImagePickerController.h"
#import "Device.h"

#define kCancel @"Cancel"
#define kTakePhoto @"Take Photo"
#define kFromLibrary @"From Library"

@interface ImagePickerController (Internal)

- (void) showImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end

@implementation ImagePickerController

@synthesize viewController, popoverController;

- (id)initWithController:(UIViewController *)controller {
    if ((self = [super init])) {
		self.viewController = controller;
	}
    return self;
}

- (void) showImagePicker {
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
		[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

- (void)dealloc {
	[viewController release];
	[popoverController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Internal

- (void) showImagePicker:(UIImagePickerControllerSourceType)sourceType {
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

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	DLog(@"");
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	DLog(@"");
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
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
		[self showImagePicker:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([titleAtIndex isEqualToString:kFromLibrary]) {
		[self showImagePicker:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

@end
