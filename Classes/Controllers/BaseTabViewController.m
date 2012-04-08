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

#import "BaseTabViewController.h"
#import "BaseTableViewController.h"
#import "BaseDetailsViewController.h"
#import "BaseAddViewController.h"
#import "BaseMapViewController.h"
#import "LoadingViewController.h"
#import "NSString+Extension.h"
#import "UIView+Extension.h"
#import "Deployment.h"
#import "Device.h"
#import "Settings.h"
#import "ItemPicker.h"
#import "Ushahidi.h"

@interface BaseTabViewController() 

- (void) mainQueueFinished;
- (void) mapQueueFinished;
- (void) photoQueueFinished;
- (void) uploadQueueFinished;

@end

@implementation BaseTabViewController

@synthesize baseAddViewController;
@synthesize baseDetailsViewController;
@synthesize baseMapViewController;
@synthesize baseTableViewController;
@synthesize displayMode;
@synthesize addButton;
@synthesize refreshButton;
@synthesize filterButton;
@synthesize deployment;
@synthesize itemPicker;
@synthesize containerView;
@synthesize allItems;
@synthesize filteredItems;
@synthesize pendingItems;
@synthesize filters;
@synthesize filter;
@synthesize popoverController;

#pragma mark -
#pragma mark Handlers

- (IBAction) add:(id)sender event:(UIEvent*)event  {
	DLog(@"");
	self.baseAddViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    self.baseAddViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.baseAddViewController load:nil];
	[self presentModalViewController:self.baseAddViewController animated:YES];
}

- (IBAction) refresh:(id)sender event:(UIEvent*)event {
    DLog(@"");
}

- (IBAction) filter:(id)sender event:(UIEvent*)event {
    DLog(@""); 
}

- (IBAction) display:(id)sender event:(UIEvent*)event {
    DLog(@"");
    self.containerView.autoresizesSubviews = YES;
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (self.displayMode.selectedSegmentIndex == ViewModeTable) {
        self.baseTableViewController.view.frame = self.containerView.frame;
        self.baseTableViewController.view.autoresizesSubviews = YES;
        self.baseTableViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.baseTableViewController.pendingRows = self.pendingItems;
        [self.baseTableViewController populate:self.allItems filter:self.filter];
        if ([self.containerView.subviews containsObject:self.baseTableViewController.view]) {
            [self.baseTableViewController viewWillDisappear:NO];
            [self.baseTableViewController.view removeFromSuperview];
            [self.baseTableViewController viewDidDisappear:NO];
        }
        [self.baseTableViewController viewWillAppear:NO];
        [self.containerView addSubview:self.baseTableViewController.view];
        [self.baseTableViewController viewDidAppear:NO];
        
        if (self.containerView.subviews.count > 1) {
            [self.baseMapViewController viewWillDisappear:NO];
            [self.baseMapViewController.view removeFromSuperview];
            [self.baseMapViewController viewDidDisappear:NO];
        }
    }
    else if (self.displayMode.selectedSegmentIndex == ViewModeMap){
        self.baseMapViewController.view.frame = self.containerView.frame;
        self.baseMapViewController.view.autoresizesSubviews = YES;
        self.baseMapViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.baseMapViewController.pendingPins = self.pendingItems;
        [self.baseMapViewController populate:self.allItems filter:self.filter];
        if ([self.containerView.subviews containsObject:self.baseMapViewController.view]) {
            [self.baseMapViewController viewWillDisappear:NO];
            [self.baseMapViewController.view removeFromSuperview];
            [self.baseMapViewController viewDidDisappear:NO];
        }
        [self.baseMapViewController viewWillAppear:NO];
        [self.containerView addSubview:self.baseMapViewController.view];
        [self.baseMapViewController viewDidAppear:NO];
        
        if (self.containerView.subviews.count > 1) {
            [self.baseTableViewController viewWillDisappear:NO];
            [self.baseTableViewController.view removeFromSuperview];
            [self.baseTableViewController viewDidDisappear:NO];
        }
    }
}

- (void) populateWithFilter:(NSObject*)theFilter {
    DLog(@"");
    self.filter = theFilter;
    if (self.displayMode.selectedSegmentIndex == ViewModeTable) {
        [self.baseTableViewController populate:self.allItems filter:self.filter];
    }
    else if (self.displayMode.selectedSegmentIndex == ViewModeMap){
        [self.baseMapViewController populate:self.allItems filter:self.filter];
    }
}

- (void) populate:(NSArray*)theItems filter:(NSObject*)theFilter {
    self.filter = theFilter;
    [self.allItems removeAllObjects];
    [self.allItems addObjectsFromArray:theItems];
    if (self.displayMode.selectedSegmentIndex == ViewModeTable) {
        [self.baseTableViewController populate:self.allItems filter:self.filter];
    }
    else if (self.displayMode.selectedSegmentIndex == ViewModeMap){
        [self.baseMapViewController populate:self.allItems filter:self.filter];
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    self.allItems = [[NSMutableArray alloc] initWithCapacity:0];
	self.filteredItems = [[NSMutableArray alloc] initWithCapacity:0];
    self.pendingItems = [[NSMutableArray alloc] initWithCapacity:0];
    self.filters = [[NSMutableArray alloc] initWithCapacity:0];
    self.itemPicker = [[ItemPicker alloc] initWithDelegate:self forController:self];
    self.addButton.tintColor = [[Settings sharedSettings] doneButtonColor];
    [self display:self.displayMode event:nil];
} 

- (void)viewDidUnload {
    [super viewDidUnload];
    self.allItems = nil;
    self.filteredItems = nil;
    self.pendingItems = nil;
    self.filters = nil;
	self.itemPicker = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.deployment != nil) {
		self.title = self.deployment.name;
	}
    if (self.willBePushed) {
        DLog(@"willBePushed");
        [self display:self.displayMode event:nil];
    }
    else if (self.wasPushed) {
        DLog(@"wasPushed");
        [self display:self.displayMode event:nil];
    }
    else {
        DLog(@"NOT willBePushed & NOT wasPushed");
        if (self.displayMode.selectedSegmentIndex == ViewModeTable) {
            [self.baseTableViewController viewWillAppear:animated];
        }
        else if (self.displayMode.selectedSegmentIndex == ViewModeMap){
            [self.baseMapViewController viewWillAppear:animated];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainQueueFinished) name:kMainQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapQueueFinished) name:kMapQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoQueueFinished) name:kPhotoQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadQueueFinished) name:kUploadQueueFinished object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    if (self.wasPushed == NO) {
        if (self.displayMode.selectedSegmentIndex == ViewModeTable) {
            [self.baseTableViewController viewDidAppear:animated];
        }
        else if (self.displayMode.selectedSegmentIndex == ViewModeMap){
            [self.baseMapViewController viewDidAppear:animated];
        }
    }
    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMainQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kMapQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kPhotoQueueFinished object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kUploadQueueFinished object:nil];
}

- (void)dealloc {
    [containerView release];
    [itemPicker release];
    [filterButton release];
    [refreshButton release];
    [addButton release];
	[displayMode release];
	[deployment release];
	[allItems release];
    [filteredItems release];
    [pendingItems release];
    [filters release];
    [filter release];
    [baseMapViewController release];
    [baseDetailsViewController release];
    [baseAddViewController release];
    [baseTableViewController release];
    [popoverController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Queue

- (void) mainQueueFinished {
	DLog(@"");
	[self.loadingView hideAfterDelay:1.0];
}

- (void) mapQueueFinished {
	DLog(@"");
}

- (void) photoQueueFinished {
	DLog(@"");
}

- (void) uploadQueueFinished {
	DLog(@"");
}

#pragma mark -
#pragma mark UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController*)splitController 
     willHideViewController:(UIViewController*)viewController 
          withBarButtonItem:(UIBarButtonItem*)barButtonItem 
       forPopoverController:(UIPopoverController*)thePopupController {
    DLog(@"Portait:%@", viewController.class);
    barButtonItem.title = viewController.title;
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.popoverController = thePopupController;
}

- (void)splitViewController:(UISplitViewController*)splitController 
     willShowViewController:(UIViewController*)viewController 
  invalidatingBarButtonItem:(UIBarButtonItem*)barButtonItem {
    DLog(@"Landscape:%@", viewController.class);
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.popoverController = nil;
}

- (BOOL) splitViewController:(UISplitViewController *)splitController
    shouldHideViewController:(UIViewController *)viewController
               inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

@end
