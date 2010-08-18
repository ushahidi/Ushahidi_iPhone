//
//  TextTableCell.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextTableCellDelegate;

@interface TextTableCell : UITableViewCell {

@public
	NSIndexPath *indexPath;

@private
	id<TextTableCellDelegate> delegate;	
}

@property (nonatomic, retain) NSIndexPath *indexPath; 

- (id)initWithDelegate:(id<TextTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setText:(NSString *)text;
- (NSString *) getText;
- (CGSize) getCellSize;
+ (CGSize)getCellSizeForText:(NSString *)theText forWidth:(CGFloat)width;

@end

@protocol TextTableCellDelegate <NSObject>

@optional

- (void) textChanged:(TextTableCell *)cell indexPath:(NSIndexPath *)indexPath size:(CGSize)size;

@end