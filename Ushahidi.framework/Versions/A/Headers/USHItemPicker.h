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

#import <UIKit/UIKit.h>

@protocol USHItemPickerDelegate;

@interface USHItemPicker : NSObject<UIPickerViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPopoverControllerDelegate> 

@property (nonatomic, retain) NSString *item;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSInteger index;

- (id) initWithController:(UIViewController<USHItemPickerDelegate> *)controller;
- (void) showWithItems:(NSArray *)items selected:(NSString *)item event:(UIEvent*)event tag:(NSInteger)tag;

@end

@protocol USHItemPickerDelegate <NSObject>

@optional

- (void) itemPickerReturned:(USHItemPicker *)itemPicker item:(NSString *)item index:(NSInteger)index;
- (void) itemPickerCancelled:(USHItemPicker *)itemPicker;

@end
