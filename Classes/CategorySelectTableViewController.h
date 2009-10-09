//
//  CategorySelectTableViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 10/8/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"

@interface CategorySelectTableViewController : UITableViewController {
	API *instanceAPI;
	NSMutableArray *categories;
	NSMutableArray *categoryNames;
	NSMutableArray *categoryIDs;
	NSString *currentCategory;
	NSString *currentCategoryID;
}
@property (nonatomic, retain) API *instanceAPI;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *categoryNames;
@property (nonatomic, retain) NSMutableArray *categoryIDs;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) NSString *currentCategoryID;
@end
