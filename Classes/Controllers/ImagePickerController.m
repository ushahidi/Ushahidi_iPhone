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
#import "UIImage+Resize.h"
#import "NSObject+Extension.h"

@interface ImagePickerController ()

@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGRect rect;

- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void) resizeImageInBackground:(UIImage *)image;

@end

@implementation ImagePickerController

@synthesize viewController, popoverController, delegate, width, rect;

- (id)initWithController:(UIViewController *)controller {
    if ((self = [super init])) {
		self.viewController = controller;
	}
    return self;
}

- (void) showImagePickerForDelegate:(id<ImagePickerDelegate>)theDelegate width:(CGFloat)theWidth forRect:(CGRect)theRect {
	self.delegate = theDelegate;
	self.width = theWidth;
	self.rect = theRect;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"Take Photo", nil), 
																		  NSLocalizedString(@"From Library", nil), nil];
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
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		[self.popoverController setPopoverContentSize:imagePicker.view.frame.size animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:self.rect
		 										inView:self.viewController.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
	}
	else {
		[viewController presentModalViewController:imagePicker animated:YES];
	}
	[imagePicker release];
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
	[self dispatchSelector:@selector(imagePickerDidSelect:) target:delegate objects:self, nil];
	[self performSelectorInBackground:@selector(resizeImageInBackground:) withObject:image];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	DLog(@"info: %@", info);
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self dispatchSelector:@selector(imagePickerDidSelect:) target:delegate objects:self, nil];
	[self performSelectorInBackground:@selector(resizeImageInBackground:) withObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	DLog(@"");
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self dispatchSelector:@selector(imagePickerDidCancel:) target:delegate objects:self, nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
	if ([titleAtIndex isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"From Library", nil)]) {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark -
#pragma mark UIImage+Resize

- (void) resizeImageInBackground:(UIImage *)originalImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    DLog(@"resizeImageInBackground");
	@try {
		if (self.width > 0) {
			CGSize size = CGSizeMake(self.width, self.width * originalImage.size.height / originalImage.size.width);
			DLog(@"Original: %f,%f Resized: %f,%f", originalImage.size.width, originalImage.size.height, size.width, size.height);
			UIImage *resizedImage = [originalImage resizedImage:size interpolationQuality:kCGInterpolationHigh];
			if (resizedImage != nil) {
				[self dispatchSelector:@selector(imagePickerDidFinish:image:) 
								target:self.delegate
							   objects:self, resizedImage, nil];
			}
			else {
				[self dispatchSelector:@selector(imagePickerDidFinish:image:) 
								target:self.delegate 
							   objects:self, originalImage, nil];
			}
		}
		else {
			[self dispatchSelector:@selector(imagePickerDidFinish:image:)
							target:self.delegate 
						   objects:self, originalImage, nil];
		}
	}
	@catch (NSException *e) {
		DLog(@"NSException: %@", e);
		[self dispatchSelector:@selector(imagePickerDidFinish:image:) 
						target:self.delegate 
					   objects:self, originalImage, nil];
	}
	[pool release];
}

@end
