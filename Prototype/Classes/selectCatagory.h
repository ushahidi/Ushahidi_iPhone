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

@class UshahidiProjAppDelegate;

#define kCellImageViewTag		1000
#define kCellLabelTag			1001
#define kCellImageTag			999

#define kLabelIndentedRect	CGRectMake(87.0, 20.0, 275.0, 20.0)
#define kLabelRect			CGRectMake(40.0, 20.0, 275.0, 20.0)
#define kImageIndentedRect	CGRectMake(40.0, 12.0, 42.0, 42.0)
#define kImageRect			CGRectMake(15.0, 12.0, 42.0, 42.0)
@interface selectCatagory : UIViewController <UITableViewDelegate,UITableViewDataSource>{

	IBOutlet UITableView *tblView;
	NSArray *arrData;
	NSMutableArray *selectedArray;
	UIImage *selectedImage,*unselectedImage;
	UshahidiProjAppDelegate *app;
}

- (void)populateSelectedArray;
@property(nonatomic,retain)NSMutableArray *selectedArray;
@end
