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

#import <Ushahidi/USHTableViewController.h>
#import <Ushahidi/USHShareController.h>

@class USHMap;
@class USHReport;
@class USHWebViewController;
@class USHImageViewController;
@class USHLocationViewController;
@class USHCommentAddViewController;

@interface USHReportDetailsViewController : USHTableViewController<USHShareControllerDelegate>

@property (strong, nonatomic) IBOutlet USHWebViewController *webViewController;
@property (strong, nonatomic) IBOutlet USHImageViewController *imageViewController;
@property (strong, nonatomic) IBOutlet USHLocationViewController *locationViewController;
@property (strong, nonatomic) IBOutlet USHCommentAddViewController *commentAddViewController;

@property (strong, nonatomic) IBOutlet UISegmentedControl *pager;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *starredButton;

@property (strong, nonatomic) USHMap *map;
@property (strong, nonatomic) USHReport *report;
@property (strong, nonatomic) NSArray *reports;

- (IBAction)page:(id)sender event:(UIEvent*)event; 
- (IBAction)comment:(id)sender event:(UIEvent*)event;
- (IBAction)share:(id)sender event:(UIEvent*)event;
- (IBAction)star:(id)sender event:(UIEvent*)event;

@end
