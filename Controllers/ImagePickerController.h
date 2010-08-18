//
//  ImagePickerController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagePickerController : NSObject<UINavigationControllerDelegate,
											UIImagePickerControllerDelegate,
											UIActionSheetDelegate,
											UIPopoverControllerDelegate> {
@public
	UIViewController *viewController;
	UIPopoverController *popoverController;
}

@property(nonatomic, retain) UIViewController *viewController;
@property(nonatomic, retain) UIPopoverController *popoverController;

- (id) initWithController:(UIViewController *)controller;
- (void) showImagePicker;

@end
