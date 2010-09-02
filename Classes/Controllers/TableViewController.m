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

#import "TableViewController.h"
#import "TableCellFactory.h"
#import "UIView+Extension.h"

@interface TableViewController ()

- (void) scrollToIndexPath:(NSIndexPath *)indexPath;
- (void) keyboardChanged:(NSNotification *)notification;

@end

@implementation TableViewController

@synthesize tableView, allRows, filteredRows;

- (id) rowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.allRows count] > indexPath.row) {
		return [self.allRows objectAtIndex:indexPath.row];
	}
	return nil;
}

- (id) rowAtIndex:(NSInteger)index {
	if ([self.allRows count] > index) {
		return [self.allRows objectAtIndex:index];
	}
	return nil;
}

- (id) filteredRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.filteredRows count] > indexPath.row) {
		return [self.filteredRows objectAtIndex:indexPath.row];
	}
	return nil;
}

#pragma mark -
#pragma mark UIViewController

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillHideNotification object:nil];
	DLog(@"%@", self.nibName);
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
	DLog(@"%@", self.nibName);
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillAppear:animated];
	DLog(@"%@", self.nibName);
	UIView *firstResponder = [self.view findFirstResponder];
	if (firstResponder != nil) {
		[firstResponder resignFirstResponder];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
	[super viewDidAppear:animated];
	DLog(@"%@", self.nibName);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	DLog(@"%@", self.nibName);
	self.allRows = [[NSMutableArray alloc] initWithCapacity:0];
	self.filteredRows = [[NSMutableArray alloc] initWithCapacity:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	DLog(@"%@", self.nibName);
}

- (void)viewDidUnload {
    [super viewDidUnload];
	DLog(@"%@", self.nibName);
}

- (void)dealloc {
	DLog(@"%@", self.nibName);
	[allRows release];
	[filteredRows release];
	[tableView release];
	[super dealloc];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 0;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return [self.filteredRows count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [TableCellFactory getDefaultTableCellForTable:theTableView];
}

#pragma mark -
#pragma mark Keyboard

-(void) keyboardChanged:(NSNotification *) notification {
	if (self.navigationController.topViewController == self) {
		DLog(@"nib:%@ notification:%@", self.nibName, notification);
		NSTimeInterval duration = 0.3;
		[[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:duration];
		
		CGRect keyboardFrameBegin;
		[[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrameBegin];
		
		CGRect keyboardFrameEnd;
		[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrameEnd];
		
		CGRect tableViewFrame  = self.tableView.frame;
		if (keyboardFrameBegin.origin.y > keyboardFrameEnd.origin.y) {
			tableViewFrame.size.height -= keyboardFrameEnd.size.height;
		}
		else {
			tableViewFrame.size.height += keyboardFrameEnd.size.height;
		}
		self.tableView.frame = tableViewFrame;
		[UIView commitAnimations];	
	}
}

- (void) scrollToIndexPath:(NSIndexPath *)indexPath {
	DLog(@"scrollToIndexPath: [%d, %d]", indexPath.section, indexPath.row);
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];	
}

@end
