//
//  CustomCell.h
//  6StarLimousine
//
//  Created by Sunil Jagnani on 12/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
