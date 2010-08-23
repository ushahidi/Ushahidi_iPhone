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

#import "BooleanTableCell.h"

@interface BooleanTableCell ()

@property (nonatomic, assign) id<BooleanTableCellDelegate> delegate;

@end


@implementation BooleanTableCell

typedef enum {
	SegmentToDo,
	SegmentCompleted
} Segment;

@synthesize delegate, indexPath, segmentControl;

- (id)initWithDelegate:(id<BooleanTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		self.segmentControl = [[UISegmentedControl alloc] initWithFrame:self.contentView.frame];
		self.segmentControl.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		[self.segmentControl insertSegmentWithTitle:@"To Do" atIndex:SegmentToDo animated:NO];
		[self.segmentControl insertSegmentWithTitle:@"Complete" atIndex:SegmentCompleted animated:NO];
		[self.segmentControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
		[self.contentView addSubview:self.segmentControl];
	}
    return self;
}

- (void) setIsCompleted:(BOOL)isCompleted {
	if (isCompleted) {
		self.segmentControl.selectedSegmentIndex = SegmentCompleted;
	}
	else {
		self.segmentControl.selectedSegmentIndex = SegmentToDo;
	}
}

- (BOOL) getIsCompleted {
	return self.segmentControl.selectedSegmentIndex == SegmentCompleted;
}

- (void) valueChanged:(id)sender {
	SEL selector = @selector(booleanCellChanged:completed:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate booleanCellChanged:self completed:(self.segmentControl.selectedSegmentIndex == SegmentCompleted)];
	}
}

- (void)dealloc {
	delegate = nil;
	[indexPath release];
	[segmentControl release];
    [super dealloc];
}

@end
