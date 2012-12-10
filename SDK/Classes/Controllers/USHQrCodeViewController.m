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

#import "USHQrCodeViewController.h"
#import "QREncoder.h"
#import "UIAlertView+USH.h"
#import "NSString+USH.h"
#import "UIBarButtonItem+USH.h"

@interface USHQrCodeViewController ()

- (void)done:(id)sender event:(UIEvent*)event;

@end

@implementation USHQrCodeViewController

@synthesize imageView = _imageView;
@synthesize text = _text;

#pragma mark - IBActions

- (void)done:(id)sender event:(UIEvent*)event {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIViewController

- (void)dealloc {
    [_imageView release];
    [_text release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem doneItemWithTitle:NSLocalizedString(@"Done", nil)
                                                                      tintColor:self.navBarColor
                                                                         target:self
                                                                         action:@selector(done:event:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DLog(@"Encoding:%@", self.text);
    if ([NSString isNilOrEmpty:self.text] == NO) {
        self.imageView.image = [QREncoder encode:self.text size:10 correctionLevel:QRCorrectionLevelHigh];
        [self.imageView layer].magnificationFilter = kCAFilterNearest;
    }
    else {
        self.imageView.image = nil;
    }
}

@end
