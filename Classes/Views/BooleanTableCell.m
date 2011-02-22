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
@property (nonatomic, retain) UISwitch *yesNo;

@end

@implementation BooleanTableCell

@synthesize delegate, yesNo;

- (id)initForDelegate:(id<BooleanTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.accessoryType = UITableViewCellAccessoryNone;
		
		self.yesNo = [[UISwitch alloc] initWithFrame:CGRectZero];
		[self.yesNo addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];

		self.textLabel.font = [UIFont systemFontOfSize:16];
		
		self.accessoryView = self.yesNo;
	}
    return self;
}

- (void) setValue:(BOOL)value {
	self.yesNo.on = value;
}

- (BOOL) getValue {
	return self.yesNo.on;
}

- (void) setText:(NSString *)theText {
	self.textLabel.text = theText;
}

- (NSString *) getText {
	return self.textLabel.text;
}

- (void) valueChanged:(id)sender {
	SEL selector = @selector(booleanCellChanged:value:);
	if (self.delegate != NULL && [self.delegate respondsToSelector:selector]) {
		[self.delegate booleanCellChanged:self value:self.yesNo.on];
	}
}

- (void)dealloc {
	delegate = nil;
	[yesNo release];
    [super dealloc];
}

@end
