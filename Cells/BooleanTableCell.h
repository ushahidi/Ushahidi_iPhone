//
//  BooleanCell.h
//  gTasks
//
//  Created by Dale Zak on 10-08-03.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BooleanTableCellDelegate;

@interface BooleanTableCell : UITableViewCell {
	id<BooleanTableCellDelegate> delegate;
	NSIndexPath *indexPath;
	UISegmentedControl *segmentControl;
}

@property (nonatomic, assign) id<BooleanTableCellDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) UISegmentedControl *segmentControl;

- (id)initWithDelegate:(id<BooleanTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setIsCompleted:(BOOL)completed;
- (BOOL) getIsCompleted;

@end

@protocol BooleanTableCellDelegate <NSObject>

@optional

- (void) booleanCellChanged:(BooleanTableCell *)cell completed:(BOOL)completed;

@end