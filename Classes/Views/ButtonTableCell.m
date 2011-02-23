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

#import "ButtonTableCell.h"

@interface ButtonTableCell ()

@property (nonatomic, assign) id<ButtonTableCellDelegate> delegate;

- (void) buttonClicked:(id)sender;

@end

@implementation ButtonTableCell

@synthesize delegate;

- (id)initForDelegate:(id<ButtonTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		self.delegate = theDelegate;
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		[button setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[button setFrame:CGRectMake(-1.0f, -1.0f, self.contentView.frame.size.width + 1, self.contentView.frame.size.height + 4)];
		[button setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
		[button setBackgroundImage:[UIImage imageNamed:@"button_red_selected.png"] forState:UIControlStateSelected];
		[button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[button.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
		[self.contentView addSubview:button];
	}
    return self;
}

- (void) setText:(NSString *)text {
	UIButton *button = [self.contentView.subviews objectAtIndex:0];
	[button setTitle:text forState:UIControlStateNormal];
	[button setTitle:text forState:UIControlStateSelected];
}

- (void) buttonClicked:(id)sender {
	SEL selector = @selector(buttonCellClicked:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate buttonCellClicked:self];
	}
}

- (void)dealloc {
	self.delegate = nil;
    [super dealloc];
}

@end


