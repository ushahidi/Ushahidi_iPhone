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

#import "VideoPickerController.h"
#import "Device.h"
#import "NSObject+Extension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Settings.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "YouTubeUploader.h"
#import "Ushahidi.h"

@interface VideoPickerController ()

- (void) showVideoPickerForSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void) uploadVideoToYoutubeFromPath:(NSString*)filepath;
- (void) dismissPopover;
@end

@implementation VideoPickerController

@synthesize viewController, popoverController, delegate;

- (id)initWithController:(UIViewController *)controller {
    if ((self = [super init])) {
		self.viewController = controller;
	}
    return self;
}

- (void) showVideoPickerForDelegate:(id<VideoPickerDelegate>)theDelegate forRect:(CGRect)sourceRect {
    DLog(@"Rect:%@", NSStringFromCGRect(sourceRect));
    
	self.delegate = theDelegate;
    rect = sourceRect;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"Take Video", nil), 
                                      NSLocalizedString(@"From Library", nil), nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
		[actionSheet showInView:self.viewController.view];
		[actionSheet release];
	}
	else {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
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

- (void)navigationController:(UINavigationController *)navigationController 
      willShowViewController:(UIViewController *)theViewController 
                    animated:(BOOL)animated {
    [theViewController.navigationItem setTitle:NSLocalizedString(@"Videos", nil)];
}

#pragma mark -
#pragma mark Internal

- (void) showVideoPickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	DLog(@"Type:%d", sourceType);
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString*)kUTTypeMovie, nil];
    imagePicker.sourceType = sourceType;
    imagePicker.videoMaximumDuration = 10;
    
	if ([Device isIPad]) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		[self.popoverController setPopoverContentSize:imagePicker.view.frame.size animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:rect
		 										inView:self.viewController.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
	}
	else {
        imagePicker.modalPresentationStyle = UIModalPresentationPageSheet;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[viewController presentModalViewController:imagePicker animated:YES];
	}
	[imagePicker release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    NSString *path = [[editingInfo objectForKey:UIImagePickerControllerMediaURL] path];
    [self uploadVideoToYoutubeFromPath:path];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *path = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    [self uploadVideoToYoutubeFromPath:path];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	DLog(@"");
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
    if ([self.delegate respondsToSelector:@selector(videoPickerDidCancel:)]) {
        [self dispatchSelector:@selector(videoPickerDidCancel:) target:delegate objects:self, nil];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
	if ([titleAtIndex isEqualToString:NSLocalizedString(@"Take Video", nil)]) {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"From Library", nil)]) {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark -
#pragma mark Youtube

- (void) uploadVideoToYoutubeFromPath:(NSString *)file {
    DLog(@"File: %@", file);
    if (file) {
        youtubeUploader = [[YouTubeUploader alloc] init];
        youtubeUploader.source = [[Ushahidi sharedUshahidi] deploymentName];
        youtubeUploader.title = [self.delegate titleForVideo];
        youtubeUploader.description = [self.delegate descriptionForVideo];
        youtubeUploader.delegate = self;
        [youtubeUploader uploadVideo:file];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(videoPickerDidFail:withError:)]) {
            [self.delegate videoPickerDidFail:self withError:NSLocalizedString(@"Invalid Video File", nil)];
        }
    }
}

#pragma mark -
#pragma mark YoutubeUploader Delegate

- (void) youtubeUploaderDidStart:(YouTubeUploader *)uploader {
    if ([self.delegate respondsToSelector:@selector(videoPickerDidStart:)]) {
        [self.delegate videoPickerDidStart:self];   
    }
    [self dismissPopover];    
}

- (void) youtubeUploaderDidFinish:(YouTubeUploader *)uploader withAddress:(NSString *)address {
    DLog(@"Address: %@", address);
    if ([self.delegate respondsToSelector:@selector(videoPickerDidFinish:withAddress:)]) {
        [self.delegate videoPickerDidFinish:self withAddress:address];   
    }
    [youtubeUploader release];
}

- (void) youtubeUploaderDidFail:(YouTubeUploader *)uploader withError:(NSString *)error {
    DLog(@"");
    if ([self.delegate respondsToSelector:@selector(videoPickerDidFail:withError:)]) {
        [self.delegate videoPickerDidFail:self withError:error];
    }
    [youtubeUploader release];
}

- (void) dismissPopover {
    if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
}

@end
