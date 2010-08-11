//
//  BooleanTableCell.m
//  gTasks
//
//  Created by Dale Zak on 10-08-03.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "BooleanTableCell.h"

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
