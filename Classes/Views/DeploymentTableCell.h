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
#import "IndexedTableCell.h"

@interface DeploymentTableCell : IndexedTableCell {

@public
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *urlLabel;
	IBOutlet UILabel *descriptionLabel;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *urlLabel;
@property (nonatomic, retain) UILabel *descriptionLabel;
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *url;
@property (nonatomic, assign) NSString *description;

+ (CGFloat) getCellHeight;

- (void) setSelectedColor:(UIColor *)color;

@end
