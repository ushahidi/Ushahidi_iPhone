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
@interface settings : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {

	UshahidiProjAppDelegate *app;
	IBOutlet UITableView *tblView;
	NSMutableArray *data,*data1;
	UITextField *url1,*fname1,*lname1,*email1;
	IBOutlet UIView *v1;
	
}
-(IBAction)clear_Clicked:(id)sender;
@end
