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

#import "USHRefreshButtonItem.h"

@interface USHRefreshButtonItem ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIImage *blankImage;

- (UIImage*)blankFromImage:(UIImage*)original;

@end

@implementation USHRefreshButtonItem

@synthesize activityIndicator = _activityIndicator;
@synthesize originalImage = _originalImage;
@synthesize blankImage = _blankImage;

- (void)awakeFromNib {
    self.originalImage = self.image;
    self.blankImage = [self blankFromImage:self.image];
    self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    self.activityIndicator.hidesWhenStopped = YES;
}

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action {
    if (self = [super initWithImage:image style:style target:target action:action]){
        self.originalImage = image;
        self.blankImage = [self blankFromImage:image];
        self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image tintColor:(UIColor*)tintColor target:(id)target action:(SEL)action {
    if (self = [super initWithImage:image style:UIBarButtonItemStyleBordered target:target action:action]){
        self.originalImage = image;
        if ([self respondsToSelector:@selector(tintColor)]) {
            self.tintColor = tintColor;
        }
        self.blankImage = [self blankFromImage:image];
        self.activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
        self.activityIndicator.hidesWhenStopped = YES;
    }
    return self;
}

- (void) setRefreshing:(BOOL)refreshing {
    if (refreshing) {
        self.image = self.blankImage;
        self.enabled = NO;
        UIView *view = [self valueForKey:@"view"];
        if (self.activityIndicator.superview == nil) {
            [view addSubview:self.activityIndicator];
        }
        CGRect frame = self.activityIndicator.frame;
        frame.origin.x = (view.frame.size.width - frame.size.width) / 2;
        frame.origin.y = (view.frame.size.height - frame.size.height) / 2;
        self.activityIndicator.frame = frame;
        [self.activityIndicator startAnimating];
    }
    else {
        self.image = self.originalImage;
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

- (UIActivityIndicatorViewStyle) indicator {
    return self.activityIndicator.activityIndicatorViewStyle;
}

- (void) setIndicator:(UIActivityIndicatorViewStyle)indicator {
    self.activityIndicator.activityIndicatorViewStyle = indicator;
}

@end
