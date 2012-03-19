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
#import <QuartzCore/QuartzCore.h>
#import "IndexedTableCell.h"

@interface CheckinTableCell : IndexedTableCell {

@public
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *messageLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSString *message;
@property (nonatomic, assign) NSString *date;
@property (nonatomic, assign) UIImage *image;
@property (nonatomic, assign) UIColor *selectedColor;

+ (CGFloat) getCellHeightForMessage:(NSString*)message;

@end
