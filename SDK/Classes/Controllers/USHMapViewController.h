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
#import <MapKit/MapKit.h>
#import "USHViewController.h"
#import "USHLocator.h"

@interface USHMapViewController : USHViewController<UIActionSheetDelegate,
                                                    USHLocatorDelegate,
                                                    UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *titleView;
@property (strong, nonatomic) IBOutlet UIButton *flipView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapType;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;

- (IBAction) showMapType:(id)sender event:(UIEvent*)event;
- (IBAction) mapTypeChanged:(id)sender event:(UIEvent*)event;
- (IBAction) mapTypeCancelled:(id)sender event:(UIEvent*)event;

- (IBAction) locate:(id)sender event:(UIEvent*)event;
- (IBAction) style:(id)sender event:(UIEvent*)event;

- (UIImage*) imageFromMapView;

- (void) adjustToolBarHeight;

- (void) userLocatedAtLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude;
- (void) mapTappedAtLatitude:(NSNumber*)latitude longitude:(NSNumber*)longitude;

@end
