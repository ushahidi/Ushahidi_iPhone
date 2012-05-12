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

#import <UIKit/UIKit.h>

@protocol VideoPickerDelegate;

@interface VideoPickerController : NSObject<UINavigationControllerDelegate,
											UIImagePickerControllerDelegate,
											UIActionSheetDelegate,
											UIPopoverControllerDelegate> {
@public
	UIViewController *viewController;
	UIPopoverController *popoverController;
	id<VideoPickerDelegate> delegate;
                                                
@private
    CGRect rect;
}

@property(nonatomic, retain) UIViewController *viewController;
@property(nonatomic, retain) UIPopoverController *popoverController;
@property(nonatomic, assign) id<VideoPickerDelegate> delegate;

- (id) initWithController:(UIViewController *)controller;
- (void) showVideoPickerForDelegate:(id<VideoPickerDelegate>)theDelegate forRect:(CGRect)rect;
@end

@protocol VideoPickerDelegate <NSObject>

@optional

- (void) videoPickerDidCancel:(VideoPickerController *)imagePicker;
- (void) videoPickerDidSelect:(VideoPickerController *)imagePicker;
- (void) videoPickerDidFinish:(VideoPickerController *)imagePicker filepath:(NSString *)image;

@end