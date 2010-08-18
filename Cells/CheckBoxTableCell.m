//
//  CheckBoxTableCell.m
//  Ushahidi
//
//  Created by Dale Zak on 10-04-26.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import "CheckBoxTableCell.h"

@interface CheckBoxTableCell ()

@property (nonatomic, assign) id<CheckBoxTableCellDelegate>	delegate;

- (void) setButtonImage:(UIImage *)image;
- (void) buttonClicked:(id)sender;

@end

@implementation CheckBoxTableCell

@synthesize delegate, indexPath, checkedImage, uncheckedImage;

typedef enum {
	CheckedFalse,
	CheckedTrue
} Checked;

- (id)initWithDelegate:(id<CheckBoxTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)identifier {
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) {
		self.delegate = theDelegate;
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 35, 35)];
		button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		button.userInteractionEnabled=YES;
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[button setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:button];
		[button release];
		self.imageView.image = [UIImage imageNamed:@"blank.png"];
		self.accessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    return self;
}

- (void)dealloc {
	delegate = nil;
	[indexPath release];
	[checkedImage release];
	[uncheckedImage release];
	[super dealloc];
}

- (BOOL) getChecked {
	return (self.tag == CheckedTrue);
}

- (void) setChecked:(BOOL)isChecked {
	if (isChecked) {
		self.tag = CheckedTrue;
		[self setButtonImage:self.checkedImage];
	}
	else {
		self.tag = CheckedFalse;
		[self setButtonImage:self.uncheckedImage];
	}
}

- (void) setButtonImage:(UIImage *)image {
	UIButton *button = (UIButton *)[self.contentView.subviews objectAtIndex:0];
	if (button != nil && image != nil) {
		[button setBackgroundImage:image forState:UIControlStateNormal];
		[button setBackgroundImage:image forState:UIControlStateHighlighted];	
	}
}

- (void) setTitle:(NSString *)title {
	if (title == nil || [title isEqualToString:@""]) {
		self.textLabel.text = @"";
	}
	else {
		self.textLabel.text = title;
	}
}

- (void) hideImage {
	UIButton *button = (UIButton *)[self.contentView.subviews objectAtIndex:0];
	if (button != nil) {
		[button setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"blank.png"] forState:UIControlStateHighlighted];
	}
}

- (void) buttonClicked:(id)sender {
	DLog(@"");
	if ([self getChecked]) {
		[self setChecked:NO];
	}
	else {
		[self setChecked:YES];
	}
	SEL selector = @selector(checkBoxTableCellChanged:index:checked:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		DLog(@"");
		[self.delegate checkBoxTableCellChanged:self index:self.indexPath checked:[self getChecked]];
	}
}

@end
