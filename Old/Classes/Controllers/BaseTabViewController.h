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
#import "BaseViewController.h"
#import "ItemPicker.h"

@class Deployment;
@class ItemPicker;

@class BaseTableViewController;
@class BaseMapViewController;
@class BaseAddViewController;
@class BaseDetailsViewController;

#pragma mark -
#pragma mark Enums

typedef enum {
	ViewModeTable,
	ViewModeMap
} ViewMode;

typedef enum {
	ShouldAnimateYes,
	ShouldAnimateNo
} ShouldAnimate;

@interface BaseTabViewController : BaseViewController<UISplitViewControllerDelegate, 
                                                      ItemPickerDelegate> {

@public
    BaseTableViewController *baseTableViewController;
    BaseMapViewController *baseMapViewController;
	BaseAddViewController *baseAddViewController;
	BaseDetailsViewController *baseDetailsViewController;
                                                          
    UIPopoverController *popoverController;
                                                          
	UISegmentedControl *displayMode;
    UIBarButtonItem *addButton;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *filterButton;
    UIView *containerView;
    
    Deployment *deployment;
	ItemPicker *itemPicker;
    
    NSMutableArray *allItems;
    NSMutableArray *filteredItems;
    NSMutableArray *pendingItems;
    NSMutableArray *filters;
    NSObject *filter;
}

@property(nonatomic,retain) IBOutlet BaseTableViewController *baseTableViewController;
@property(nonatomic,retain) IBOutlet BaseMapViewController *baseMapViewController;
@property(nonatomic,retain) IBOutlet BaseAddViewController *baseAddViewController;
@property(nonatomic,retain) IBOutlet BaseDetailsViewController *baseDetailsViewController;

@property(nonatomic,retain) IBOutlet UISegmentedControl *displayMode;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *filterButton;
@property(nonatomic,retain) IBOutlet UIView *containerView;

@property(nonatomic,retain) UIPopoverController *popoverController;

@property(nonatomic,retain) Deployment *deployment;
@property(nonatomic,retain) ItemPicker *itemPicker;

@property(nonatomic,retain) NSMutableArray *allItems;
@property(nonatomic,retain) NSMutableArray *filteredItems;
@property(nonatomic,retain) NSMutableArray *pendingItems;
@property(nonatomic,retain) NSMutableArray *filters;
@property(nonatomic,retain) NSObject *filter;

- (IBAction) add:(id)sender event:(UIEvent*)event;
- (IBAction) refresh:(id)sender event:(UIEvent*)event;
- (IBAction) filter:(id)sender event:(UIEvent*)event;
- (IBAction) display:(id)sender event:(UIEvent*)event;
- (void) populateWithFilter:(NSObject*)filter;
- (void) populate:(NSArray*)items filter:(NSObject*)filter;

@end
