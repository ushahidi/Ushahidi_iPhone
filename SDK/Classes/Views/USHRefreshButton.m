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

#import "USHRefreshButton.h"

@interface USHRefreshButton ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIImage *blankImage;

@end

@implementation USHRefreshButton

@synthesize activityIndicator = _activityIndicator;
@synthesize originalImage = _originalImage;
@synthesize blankImage = _blankImage;

- (void)awakeFromNib {
    self.originalImage = [self imageForState:UIControlStateNormal];
    self.blankImage = [self blankFromImage:self.originalImage];
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    self.activityIndicator.hidesWhenStopped = YES;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.originalImage = [self imageForState:UIControlStateNormal];
        self.blankImage = [self blankFromImage:self.originalImage];
        self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return self;
}

- (void) setRefreshing:(BOOL)refreshing {
    if (refreshing) {
        [self setImage:self.blankImage forState:UIControlStateNormal];
        self.enabled = NO;
        if (self.activityIndicator.superview == nil) {
            [self addSubview:self.activityIndicator];
        }
        CGRect frame = self.activityIndicator.frame;
        frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
        frame.origin.y = (self.frame.size.height - frame.size.height) / 2;
        self.activityIndicator.frame = frame;
        [self.activityIndicator startAnimating];
    }
    else {
        [self setImage:self.originalImage forState:UIControlStateNormal];
        self.enabled = YES;
        [self.activityIndicator stopAnimating];
    }
}

- (BOOL) refreshing {
    return self.enabled == NO;
}

- (UIImage*)blankFromImage:(UIImage*)original {
    CGImageRef rawImageRef = original.CGImage;
    
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    UIGraphicsBeginImageContext(original.size);
    
    CGImageRef imageMask = CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, original.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, original.size.width, original.size.height), imageMask);
    
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    
    CGImageRelease(imageMask);
    UIGraphicsEndImageContext();
    
    return blank;
}

- (void)dealloc{
    [_activityIndicator removeFromSuperview];
    [_activityIndicator release];
    [_originalImage release];
    [_blankImage release];
	[super dealloc];
}

@end
