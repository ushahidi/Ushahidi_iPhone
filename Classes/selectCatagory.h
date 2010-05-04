//
//  selectCatagory.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 27/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

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
