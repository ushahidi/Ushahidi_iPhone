/*****************************************************************************
 ** Copyright (c) 2012 Ushahidi Inc
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

#import "USHInputTableCell.h"
#import <Ushahidi/NSObject+USH.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UITableView+USH.h>
#import <Ushahidi/USHDevice.h>

@interface USHInputTableCell ()

@property (nonatomic, retain) UIButton *clearButton;

@end

@implementation USHInputTableCell

@synthesize imageView;
@synthesize textView = _textView;
@synthesize placeholder = _placeholder;
@synthesize delegate = _delegate;
@synthesize clearButton = _clearButton;

- (void)clear:(id)sender event:(UIEvent*)event {
    self.textView.text = nil;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearButton setFrame:CGRectMake(0, 0, 20, 20)];
    [self.clearButton setImage:[UIImage imageNamed:@"clear.png"] forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(clear:event:) forControlEvents:UIControlEventTouchUpInside];
    if ([USHDevice isIOS6]) {
       self.textView.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
    }
    self.textView.backgroundColor = self.backgroundColor;
}

- (void)dealloc {
    [_delegate release];
    [imageView release];
    [_textView release];
    [_placeholder release];
    [_clearButton release];
    [super dealloc];
}

- (void) setText:(NSString *)text {
    if ([NSString isNilOrEmpty:text]) {
        self.textView.text = self.placeholder;
        self.textView.textColor = [UIColor lightGrayColor];
        self.accessoryView = nil;
    }
    else {
        self.textView.text = text;
        self.textView.textColor = [UIColor blackColor];
        self.accessoryView = self.clearButton;
    }
}

- (NSString *)text {
    if ([self.textView.text isEqualToString:self.placeholder]) {
        return nil;
    }
    return self.textView.text;
}

- (void) showKeyboard {
    [self.textView becomeFirstResponder];
}

- (void) hideKeyboard {
    [self.textView resignFirstResponder];
}

+ (CGFloat) heightForTable:(UITableView *)tableView text:(NSString *)text {
    CGFloat width = [tableView contentWidth];
    width -= 34; //left
    width -= 26; //right
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17]
                   constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                       lineBreakMode:NSLineBreakByWordWrapping];
	CGFloat height = size.height;
    height += 6; //top
    height += 6; //bottom
    height += 4; //padding
    return MAX(44, height);
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([textView.text isEqualToString:self.placeholder]) {
		textView.text = @"";
		textView.textColor = [UIColor blackColor];
	}
	[textView becomeFirstResponder];
    [self.delegate performSelectorOnMainThread:@selector(inputFocussed:indexPath:) 
                                 waitUntilDone:YES 
                                   withObjects:self, self.indexPath, nil];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([textView.text isEqualToString:@""]) {
		textView.text = self.placeholder;
		textView.textColor = [UIColor lightGrayColor];
	}
    [self.delegate performSelectorOnMainThread:@selector(inputReturned:indexPath:text:) 
                                 waitUntilDone:YES 
                                   withObjects:self, self.indexPath, self.textView.text, nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([NSString isNilOrEmpty:textView.text]) {
        self.accessoryView = nil;
    }
    else {
        self.accessoryView = self.clearButton;
    }
    [self.delegate performSelectorOnMainThread:@selector(inputChanged:indexPath:text:) 
                                 waitUntilDone:YES 
                                   withObjects:self, self.indexPath, self.textView.text, nil];
}

@end
