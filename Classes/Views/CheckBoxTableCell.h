//
//  CheckBoxTableCell.h
//  Ushahidi
//
//  Created by Dale Zak on 10-04-26.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CheckBoxTableCellDelegate;

@interface CheckBoxTableCell : UITableViewCell {

@public
	NSIndexPath	*indexPath;
	UIImage *checkedImage;
	UIImage *uncheckedImage;

@private
	id<CheckBoxTableCellDelegate> delegate;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) UIImage *checkedImage;
@property (nonatomic, retain) UIImage *uncheckedImage;

- (id)initWithDelegate:(id<CheckBoxTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setChecked:(BOOL)checked;
- (BOOL) getChecked;
- (void) setTitle:(NSString *)title;

@end

@protocol CheckBoxTableCellDelegate <NSObject>

@optional

- (void) checkBoxTableCellChanged:(CheckBoxTableCell *)cell index:(NSIndexPath *)indexPath checked:(BOOL)checked;

@end