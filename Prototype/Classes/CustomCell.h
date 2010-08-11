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

@interface CustomCell : UITableViewCell {

	UILabel *incName,*locationName;
	UIImageView *incImage;
	UILabel *date1,*verified;
    UILabel *lbl_Title;
	UITextField *txt;
	UILabel *lbl_setting;
	UILabel *add_Label;
	UILabel *showDate;
	UILabel *showLoc;
}

@property(nonatomic,retain)UILabel *incName,*locationName;
@property(nonatomic,retain)UIImageView *incImage;
@property(nonatomic,retain)UILabel *date1,*verified,*lbl_Title,*lbl_setting;
@property(nonatomic,retain)UITextField *txt;
@property(nonatomic,retain)UILabel *add_Label,*showDate,*showLoc;
@end
