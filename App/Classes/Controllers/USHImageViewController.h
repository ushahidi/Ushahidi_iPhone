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

#import <Ushahidi/USHViewController.h>
#import <Ushahidi/USHShareController.h>

@interface USHImageViewController : USHViewController<USHShareControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *nextPrevious;
@property (strong, nonatomic) NSArray *images;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;

- (IBAction) nextPrevious:(id)sender;
- (IBAction) save:(id)sender event:(UIEvent*)event;
- (IBAction) action:(id)sender event:(UIEvent*)event;

- (void) adjustToolBarHeight;

@end
