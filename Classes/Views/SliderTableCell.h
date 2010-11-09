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

@protocol SliderTableCellDelegate;

@interface SliderTableCell : UITableViewCell {

@public
	NSIndexPath *indexPath; 

@private
	id<SliderTableCellDelegate>	delegate;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 

- (id)initForDelegate:(id<SliderTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier ;

- (void) setMinimum:(CGFloat)minimum;
- (void) setMaximum:(CGFloat)maximum;
- (void) setValue:(CGFloat)value;

@end

@protocol SliderTableCellDelegate <NSObject>

@optional

- (void) sliderCellChanged:(SliderTableCell *)cell value:(CGFloat)value;

@end