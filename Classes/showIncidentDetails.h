//
//  showIncidentDetails.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 23/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface showIncidentDetails : UIViewController {

	NSMutableDictionary *dict;
	IBOutlet UILabel *event,*place,*date,*verified;
	IBOutlet UITextView *tv;
	IBOutlet UIImageView *imgView;
	int mediacount;
	IBOutlet UIButton *btn_Photo;
}

@property (nonatomic,retain) NSMutableDictionary *dict;
-(IBAction)mapButton_Clicked:(id)sender;
-(IBAction)btn_Photo_Clicked:(id)sender;

@end
