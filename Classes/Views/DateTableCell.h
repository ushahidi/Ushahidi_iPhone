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

@protocol DateTableCellDelegate;

@interface DateTableCell : UITableViewCell {

@public
	id<DateTableCellDelegate>	delegate;
	NSIndexPath					*indexPath;
	NSDate						*date;
}

@property (nonatomic, assign)			id<DateTableCellDelegate>	delegate;
@property (nonatomic, retain)			NSIndexPath					*indexPath; 
@property (nonatomic, retain, readonly) NSDate						*date;

- (id)initForDelegate:(id<DateTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setDate:(NSDate *)date timeFormat:(BOOL)timeFormat;
- (void) setFont:(UIFont *)font;
- (void) setPlaceholder:(NSString *)placeholder;

@end

@protocol DateTableCellDelegate <NSObject>

@optional

- (void) dateTableCellClicked:(DateTableCell *)cell date:(NSDate *)date indexPath:(NSIndexPath *)indexPath;

@end