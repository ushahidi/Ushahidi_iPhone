//
//  CategoriesViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/20/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UshahidiAppDelegate.h"
#import "API.h"

@interface CategoriesViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
	IBOutlet UIPickerView *categoryPicker;
	IBOutlet UITextField *selectedCategory;
	
	int selectedCatgoryID;
	
	//UshahidiAppDelegate *delegate;
	API *instanceAPI;
	NSArray *categories;
}

NSArray *incidents;
+ (NSArray *)filteredIncidents;

BOOL catChanged;
+ (BOOL)categoryChanged;

- (void)hideView;
- (void)filterIncidents;

@property (nonatomic, retain) IBOutlet UIPickerView *categoryPicker;
@property (nonatomic, retain) IBOutlet IBOutlet UITextField *selectedCategory;

//@property (nonatomic, retain) UshahidiAppDelegate *delegate;
@property (nonatomic, retain) API *instanceAPI;
@property (nonatomic, retain) NSArray *categories;

@end
