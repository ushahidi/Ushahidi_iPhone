//
//  TextViewTableCell.h
//  Ushahidi
//
//  Created by Dale Zak on 10-05-20.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextViewTableCellDelegate;

@interface TextViewTableCell : UITableViewCell<UITextViewDelegate> {
	
@public
	UITextView *textView;
	NSIndexPath *indexPath;
	NSInteger limit;
	
@private
	id<TextViewTableCellDelegate> delegate;
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, assign) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger limit;

- (id)initWithDelegate:(id<TextViewTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;

- (void) setText:(NSString *)text;
- (void) setPlaceholder:(NSString *)placeholder;
- (NSString *) getText;
- (void) showKeyboard;
- (void) hideKeyboard;

@end

@protocol TextViewTableCellDelegate <NSObject>

@optional

- (void) textViewFocussed:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath;
- (void) textViewChanged:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;
- (void) textViewReturned:(TextViewTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text;

@end