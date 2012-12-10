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

#import "USHAddViewController.h"

@interface USHAddViewController ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

- (void) tapGestureRecognizer:(UITapGestureRecognizer *)recognizer;

@end

@implementation USHAddViewController

@synthesize cancelButton = _cancelButton;
@synthesize doneButton = _doneButton;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;

#pragma mark - IBActions

- (IBAction)cancel:(id)sender event:(UIEvent*)event {
    DLog(@"");
}

- (IBAction)done:(id)sender event:(UIEvent*)event {
    DLog(@"");    
}

- (void) tapGestureRecognizer:(UITapGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:self.tableView];
    [self tableView:self.tableView didTouchAtPoint:point];
}

- (void) tableView:(UITableView *)tableView didTouchAtPoint:(CGPoint)point {
    DLog(@"%f,%f", point.x, point.y);
}

#pragma mark - UIViewController

- (void)dealloc {
    [_doneButton release];
    [_cancelButton release];
    [_tapGestureRecognizer release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    self.tapGestureRecognizer.numberOfTouchesRequired = 1;
    self.tapGestureRecognizer.cancelsTouchesInView = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.tableView removeGestureRecognizer:self.tapGestureRecognizer];
}

@end
