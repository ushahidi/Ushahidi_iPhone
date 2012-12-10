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

#import "USHReportTableCell.h"
#import <Ushahidi/UIColor+USH.h>
#import <Ushahidi/USHDevice.h>
#import "USHSettings.h"
#import <Ushahidi/NSString+USH.h>

@implementation USHReportTableCell

typedef enum {
	VerifiedNo,
	VerifiedYes,
    PendingUpload
} Verified;

typedef enum {
	StatusViewed,
	StatusModified,
    StatusStarred
} Status;

@synthesize titleLabel = _titleLabel;
@synthesize locationLabel = _locationLabel;
@synthesize categoryLabel = _categoryLabel;
@synthesize dateLabel = _dateLabel;
@synthesize verifiedView = _verifiedView;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize imageView;
@synthesize webView = _webView;
@synthesize activityIndicator = _activityIndicator;
@synthesize starredView = _starredView;

- (void) awakeFromNib {
    [super awakeFromNib];
    self.imageView.superview.layer.cornerRadius = 5.0f;
    CGRect frame = self.starredView.frame;
    frame.origin.x = self.frame.size.width - self.verifiedView.frame.origin.x - self.starredView.frame.size.width;
    self.starredView.frame = frame;
}

- (void)dealloc {
	[_titleLabel release];
	[_locationLabel release];
	[_categoryLabel release];
	[_dateLabel release];
	[imageView release];
	[_verifiedView release];
    [_webView release];
    [_descriptionLabel release];
	[_activityIndicator release];
    [_starredView release];
    [super dealloc];
}

- (void) setStarred:(BOOL)starred {
    if (starred) {
        self.starredView.image = [UIImage imageNamed:@"starred.png"];
        self.starredView.tag = StatusStarred;
    }
}

- (BOOL) starred {
    return self.starredView.tag == StatusStarred;
}

- (void) setModified:(BOOL)modified {
    if (modified) {
        self.starredView.image = [UIImage imageNamed:@"modified.png"];
        self.starredView.tag = StatusModified;
    }
    else {
        self.starredView.image = nil;
        self.starredView.tag = StatusViewed;
    }
}

- (BOOL) modified {
    return self.starredView.tag == StatusModified;
}

- (void) setDescription:(NSString *)description {
    if (self.descriptionLabel != nil) {
        [self.descriptionLabel setText:description];
    }
}

- (NSString *) description {
    return self.descriptionLabel.text;
}

- (void) setHTML:(NSString *)html {
    if ([NSString isNilOrEmpty:html]) {
        self.imageView.hidden = NO;
        self.webView.hidden = YES;
    }
    else {
        self.imageView.hidden = YES;
        self.webView.hidden = NO;
        [self.webView loadHTMLString:html baseURL:nil];
    }
}

- (CGSize) webViewSize {
    return self.imageView.frame.size;
}

- (void) setTitle:(NSString *)title {
	self.titleLabel.text = title;
}

- (NSString *) title {
	return self.titleLabel.text;
}

- (void) setLocation:(NSString *)location {
	if (location != nil && [location length] > 0) {
		self.locationLabel.text = location;
	}
	else {
		self.locationLabel.text = NSLocalizedString(@"No Location", nil);
	}
}

- (NSString *) location {
	return self.titleLabel.text;
}

- (void) setCategory:(NSString *)category {
	if (category != nil && [category length] > 0) {
		self.categoryLabel.text = category;
	}
	else {
		self.categoryLabel.text = NSLocalizedString(@"No Category", nil);
	}
}

- (NSString *) category {
	return self.categoryLabel.text;
}

- (void) setDate:(NSString *)date {
	if (date != nil && [date length] > 0) {
		self.dateLabel.text = date;
	}
	else {
		self.dateLabel.text = NSLocalizedString(@"No Date", nil);
	}
}

- (NSString *) date {
	return self.dateLabel.text;
}

- (void) setImage:(UIImage *)image {
	if (image != nil) {
		self.imageView.image = image;
	} 
	else {
		self.imageView.image = [UIImage imageNamed:@"placeholder.png"];
	}
}

- (UIImage *) image {
	return self.imageView.image;
}

- (void) setVerified:(BOOL) verified {
	if (verified) {
		self.verifiedView.image = [UIImage imageNamed:@"verified.png"];
		self.verifiedView.tag = VerifiedYes;
	}
	else {
		self.verifiedView.image = [UIImage imageNamed:@"unverified.png"];
		self.verifiedView.tag = VerifiedNo;
	}
}

- (BOOL) verified {
	return self.verifiedView.tag == VerifiedYes;
}

- (void) setPending:(BOOL)pending {
    self.verifiedView.image = [UIImage imageNamed:@"upload"];
    self.verifiedView.tag = PendingUpload;
}

- (BOOL) pending {
    return self.verifiedView.tag == PendingUpload;
}

+ (CGFloat) cellHeight {
	return [USHDevice isIPad] ? 110 : 100;
}

- (BOOL) uploading {
	return [self.activityIndicator isAnimating];
}

- (void) setUploading:(BOOL)isUploading {
	if (isUploading) {
		[self.activityIndicator startAnimating];
	}
	else {
		[self.activityIndicator stopAnimating];
	}
}

@end
