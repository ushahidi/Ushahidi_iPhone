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

#import "USHVideoPicker.h"
#import "NSObject+USH.h"
#import "NSString+USH.h"
#import "UIActionSheet+USH.h"
#import "UIAlertView+USH.h"
#import "UIViewController+USH.h"
#import "USHDevice.h"

@interface USHVideoPicker ()

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIViewController<USHVideoPickerDelegate> *viewController;
@property (nonatomic, retain) NSString *textCaptureVideo;
@property (nonatomic, retain) NSString *textFromLibrary;
@property (nonatomic, assign) CGRect touch;

- (void) dismissModalViewController;

@end

@implementation USHVideoPicker

@synthesize viewController = _viewController;
@synthesize popoverController = _popoverController;
@synthesize textCaptureVideo = _textCaptureVideo;
@synthesize textFromLibrary = _textFromLibrary;

#pragma mark - NSObject

- (id) initWithController:(UIViewController<USHVideoPickerDelegate> *)viewController {
    if ((self = [super init])) {
		self.viewController = viewController;
        self.textCaptureVideo = NSLocalizedString(@"Capture Video", nil);
        self.textFromLibrary = NSLocalizedString(@"From Library", nil);
	}
    return self;
}

- (void)dealloc {
	[_viewController release];
	[_popoverController release];
    [_textCaptureVideo release];
    [_textFromLibrary release];
	[super dealloc];
}

#pragma mark - USHVideoPicker

- (void) showVideoPickerForEvent:(UIEvent*)event {
    [self showVideoPickerForRect:[self.viewController touchForEvent:event]];
}

- (void) showVideoPickerForCell:(UITableViewCell*)cell {
    [self showVideoPickerForRect:cell.frame];
}

- (void) showVideoPickerForRect:(CGRect)rect {
    self.touch = rect;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:nil
														otherButtonTitles:self.textCaptureVideo, self.textFromLibrary, nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
		[actionSheet showInView:self.viewController.view];
		[actionSheet release];
	}
	else {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark - Private Helpers

- (void) showVideoPickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	DLog(@"Type:%d", sourceType);
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeMovie, nil];
    imagePicker.sourceType = sourceType;
    imagePicker.videoMaximumDuration = 10;
	if ([USHDevice isIPad]) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		[self.popoverController setPopoverContentSize:imagePicker.view.frame.size animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:self.touch
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

- (void) dismissModalViewController {
    if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    [viewController.navigationItem setTitle:NSLocalizedString(@"Videos", nil)];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:self.textCaptureVideo]) {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([buttonTitle isEqualToString:self.textFromLibrary]) {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    DLog(@"%@", url);
    [self.viewController performSelector:@selector(videoPickerDidFinish:url:)
                             withObjects:self, url, nil];
    [self dismissModalViewController];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    DLog(@"%@", url);
    [self.viewController performSelector:@selector(videoPickerDidFinish:url:)
                             withObjects:self, url, nil];
    [self dismissModalViewController];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	DLog(@"");
    [self.viewController performSelector:@selector(videoPickerDidCancel:) withObjects:self, nil];
	[self dismissModalViewController];
}

@end
