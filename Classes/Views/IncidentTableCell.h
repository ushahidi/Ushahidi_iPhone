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

@interface IncidentTableCell : UITableViewCell {

@public
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *categoryLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UILabel *categoryLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL uploading;

- (void) setTitle:(NSString *)title;
- (NSString *) getTitle;

- (void) setLocation:(NSString *)location;
- (NSString *) getLocation;

- (void) setCategory:(NSString *)category;
- (NSString *) getCategory;

- (void) setDate:(NSString *)date;
- (NSString *) getDate;

- (void) setImage:(UIImage *)image;
- (UIImage *) getImage;

- (void) setSelectedColor:(UIColor *)color;

+ (CGFloat) getCellHeight;

@end
