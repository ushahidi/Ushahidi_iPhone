//
//  ViewIncidentViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "TextTableCell.h"

@class WebViewController;
@class MapViewController;

@interface ViewIncidentViewController : TableViewController<UIWebViewDelegate, UIActionSheetDelegate, TextTableCellDelegate> {
	WebViewController *webViewController;
	MapViewController *mapViewController;
	UISegmentedControl *nextPrevious;
}

@property(nonatomic,retain) IBOutlet WebViewController *webViewController;
@property(nonatomic,retain) IBOutlet MapViewController *mapViewController;
@property(nonatomic,retain) IBOutlet UISegmentedControl *nextPrevious;

- (IBAction) action:(id)sender;
- (IBAction) nextPrevious:(id)sender;

@end
