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

#import <Foundation/Foundation.h>


@protocol ItemPickerDelegate;

@interface ItemPicker : NSObject<UIPickerViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource> {

@public
	NSString *item;
	NSArray *items;

@private
	UIViewController *controller;
	id<ItemPickerDelegate>	delegate;
}

@property (nonatomic, retain) NSString *item;
@property (nonatomic, retain) NSArray *items;

- (id) initWithDelegate:(id<ItemPickerDelegate>)delegate forController:(UIViewController *)controller;
- (void) showWithItems:(NSArray *)items withSelected:(NSString *)item;

@end

@protocol ItemPickerDelegate <NSObject>

@optional

- (void) itemPickerReturned:(ItemPicker *)itemPicker item:(NSString *)item;
- (void) itemPickerCancelled:(ItemPicker *)itemPicker;

@end