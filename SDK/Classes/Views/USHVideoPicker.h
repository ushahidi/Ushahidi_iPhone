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

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol USHVideoPickerDelegate;

@interface USHVideoPicker : NSObject<UINavigationControllerDelegate,
                                     UIActionSheetDelegate,
                                     UIImagePickerControllerDelegate,
                                     UIPopoverControllerDelegate>

- (id) initWithController:(UIViewController<USHVideoPickerDelegate> *)controller;

- (void) showVideoPickerForRect:(CGRect)rect;
- (void) showVideoPickerForEvent:(UIEvent*)event;
- (void) showVideoPickerForCell:(UITableViewCell*)cell;

@end

@protocol USHVideoPickerDelegate <NSObject>

- (void) videoPickerDidStart:(USHVideoPicker*)videoPicker;
- (void) videoPickerDidCancel:(USHVideoPicker*)videoPicker;
- (void) videoPickerDidFail:(USHVideoPicker*)videoPicker error:(NSError*)error;
- (void) videoPickerDidFinish:(USHVideoPicker*)videoPicker url:(NSURL *)url;

@end