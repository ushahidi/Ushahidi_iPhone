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
#import <QuartzCore/QuartzCore.h>
#import <Ushahidi/USHTableCell.h>

@interface USHReportTableCell : USHTableCell {
@public
    UIImageView *imageView;
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationLabel;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *verifiedView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIImageView *starredView;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) NSString *title;
@property (nonatomic, weak) NSString *location;
@property (nonatomic, weak) NSString *category;
@property (nonatomic, weak) NSString *description;
@property (nonatomic, weak) NSString *date;
@property (nonatomic, weak) UIImage *image;

@property (nonatomic, assign) BOOL uploading;
@property (nonatomic, assign) BOOL pending;
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, assign) BOOL starred;
@property (nonatomic, assign) BOOL modified;

+ (CGFloat) cellHeight;
- (void) setHTML:(NSString *)html;
- (CGSize) webViewSize;

@end
