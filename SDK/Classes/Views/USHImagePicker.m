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

#import "USHImagePicker.h"
#import "USHDevice.h"
#import "UIImage+USH.h"
#import "NSObject+USH.h"

@interface USHImagePicker ()

@property(nonatomic, retain) UIPopoverController *popoverController;
@property(nonatomic, assign) UIViewController<USHImagePickerDelegate> *viewController;

@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGRect rect;
@property(nonatomic, assign) BOOL resize;

@property(nonatomic, retain) NSString *textTakePhoto;
@property(nonatomic, retain) NSString *textFromLibrary;

- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void) resizeImageInBackground:(UIImage *)image;

@end

@implementation USHImagePicker

@synthesize viewController = _viewController;
@synthesize popoverController = _popoverController;
@synthesize width = _width;
@synthesize rect = _rect;
@synthesize resize = _resize;
@synthesize textTakePhoto = _textTakePhoto;
@synthesize textFromLibrary = _textFromLibrary;

- (void)dealloc {
    [_viewController release];
    [_popoverController release];
    [_textTakePhoto release];
    [_textFromLibrary release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (id) initWithController:(UIViewController<USHImagePickerDelegate> *)viewController {
    if ((self = [super init])) {
		self.viewController = viewController;
        self.textTakePhoto = NSLocalizedString(@"Take Photo", nil);
        self.textFromLibrary = NSLocalizedString(@"From Library", nil);
	}
    return self;
}

- (void) showImagePickerForRect:(CGRect)rect resize:(BOOL)resize width:(CGFloat)width {
	self.width = width;
	self.rect = rect;
	self.resize = resize;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:nil
														otherButtonTitles:self.textTakePhoto, self.textFromLibrary, nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
		[actionSheet showInView:self.viewController.view];
		[actionSheet release];
	}
	else {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark -
#pragma mark Internal

- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	DLog(@"Source:%d", sourceType);
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.sourceType = sourceType;
	if ([USHDevice isIPad]) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		[self.popoverController setPopoverContentSize:imagePicker.view.frame.size animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:self.rect
		 										inView:self.viewController.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
	}
	else {
        imagePicker.modalPresentationStyle = UIModalPresentationPageSheet;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self.viewController presentModalViewController:imagePicker animated:YES];
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
    [self.viewController performSelectorOnMainThread:@selector(imagePickerDidSelect:) 
                                       waitUntilDone:YES 
                                         withObjects:self, nil];
	if (self.resize) {
		[self performSelectorInBackground:@selector(resizeImageInBackground:) withObject:image];
	}
	else {
        [self.viewController performSelectorOnMainThread:@selector(imagePickerDidFinish:image:) 
                                           waitUntilDone:YES 
                                             withObjects:self, image, nil];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	DLog(@"info: %@", info);
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self.viewController performSelectorOnMainThread:@selector(imagePickerDidSelect:) 
                                       waitUntilDone:YES 
                                         withObjects:self, nil];
	if (self.resize) {
		[self performSelectorInBackground:@selector(resizeImageInBackground:) withObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
	}
	else {
        [self.viewController performSelectorOnMainThread:@selector(imagePickerDidFinish:image:) 
                                           waitUntilDone:YES 
                                             withObjects:self, [info objectForKey:UIImagePickerControllerOriginalImage], nil];
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
	[self.viewController performSelectorOnMainThread:@selector(imagePickerDidCancel:) 
                                       waitUntilDone:YES 
                                         withObjects:self, nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([titleAtIndex isEqualToString:self.textTakePhoto]) {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([titleAtIndex isEqualToString:self.textFromLibrary]) {
		[self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark -
#pragma mark UIImage+Resize

- (void) resizeImageInBackground:(UIImage *)original {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    DLog(@"resizeImageInBackground");
	@try {
		if (self.width > 0) {
			CGSize size = CGSizeMake(self.width, self.width * original.size.height / original.size.width);
			DLog(@"Original: %f,%f Resized: %f,%f", original.size.width, original.size.height, size.width, size.height);
			UIImage *resized = [original scaledWithSize:size];
			if (resized != nil) {
                [self.viewController performSelectorOnMainThread:@selector(imagePickerDidFinish:image:) 
                                                   waitUntilDone:YES 
                                                     withObjects:self, resized, nil];
			}
			else {
                [self.viewController performSelectorOnMainThread:@selector(imagePickerDidFinish:image:) 
                                                   waitUntilDone:YES 
                                                     withObjects:self, original, nil];
			}
		}
		else {
            [self.viewController performSelectorOnMainThread:@selector(imagePickerDidFinish:image:) 
                                               waitUntilDone:YES 
                                                 withObjects:self, original, nil];
		}
	}
	@catch (NSException *e) {
		DLog(@"NSException: %@", e);
        [self.viewController performSelectorOnMainThread:@selector(imagePickerDidFinish:image:) 
                                           waitUntilDone:YES 
                                             withObjects:self, original, nil];
	}
	[pool release];
}

@end
