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

#import "USHCommentAddViewController.h"
#import <Ushahidi/USHMap.h>
#import <Ushahidi/USHReport.h>
#import <Ushahidi/USHDevice.h>
#import <Ushahidi/NSString+USH.h>
#import <Ushahidi/UIAlertView+USH.h>
#import "USHTableCellFactory.h"
#import "USHInputTableCell.h"
#import "USHSettings.h"
#import <Ushahidi/USHInternet.h>
#import "USHAnalytics.h"

@interface USHCommentAddViewController ()

@property (strong, nonatomic) USHComment *comment;
@property (strong, nonatomic) USHLoginDialog *loginDialog;
@property (strong, nonatomic) USHInputTableCell *inputCell;

- (void) showKeyboardForSection:(NSInteger)section;

@end

@implementation USHCommentAddViewController

typedef enum {
    TableSectionComment,
    TableSectionAuthor,
    TableSectionEmail,
    TableSections
} TableSection;

typedef enum {
    AlertViewDefault
} AlertViewType;

@synthesize map = _map;
@synthesize report = _report;
@synthesize comment = _comment;
@synthesize loginDialog = _loginDialog;
@synthesize inputCell = _inputCell;

#pragma mark - IBActions

- (IBAction)cancel:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self.inputCell hideKeyboard];
    [[Ushahidi sharedInstance] removeComment:self.comment];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender event:(UIEvent*)event {
    DLog(@"");
    if ([NSString isNilOrEmpty:self.comment.text]) {
        [self showMessage:NSLocalizedString(@"Comment Required", nil) hide:1.5];
        [self showKeyboardForSection:TableSectionComment];
    }
    else if ([NSString isNilOrEmpty:self.comment.author]) {
        [self showMessage:NSLocalizedString(@"Name Required", nil) hide:1.5];
        [self showKeyboardForSection:TableSectionAuthor];
    }
    else if ([NSString isNilOrEmpty:self.comment.email]) {
        [self showMessage:NSLocalizedString(@"Email Required", nil) hide:1.5];
        [self showKeyboardForSection:TableSectionEmail];
    }
    else {
        if ([[USHInternet sharedInstance] hasNetwork] || [[USHInternet sharedInstance] hasWiFi]) {
            [self.inputCell hideKeyboard];
            [self showLoadingWithMessage:NSLocalizedString(@"Sending...", nil)];
            [[Ushahidi sharedInstance] uploadComment:self.comment delegate:self];
        }
        else {
            self.comment.pending = [NSNumber numberWithBool:YES];
            [[Ushahidi sharedInstance] saveChanges];
            [self showMessage:NSLocalizedString(@"Comment Queued", nil) hide:1.5];
            [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:1.7];
        }
    }
}

- (void) showKeyboardForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    USHInputTableCell *cell = (USHInputTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell showKeyboard];
}

- (void) tableView:(UITableView *)tableView didTouchAtPoint:(CGPoint)point {
    if (self.inputCell != nil) {
        [self.inputCell hideKeyboard];
    }
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.loginDialog = [[USHLoginDialog alloc] initForDelegate:self];
    if (self.modalPresentationStyle == UIModalPresentationFormSheet) {
        self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | 
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin;   
    }
    self.cancelButton.title = NSLocalizedString(@"Cancel", nil);
    self.doneButton.title = NSLocalizedString(@"Done", nil);
    self.navigationItem.title = NSLocalizedString(@"Add Comment", nil);
    
    [USHAnalytics sendScreenView:USHAnalyticsCommentAddVCName];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.loginDialog = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([USHDevice isIPad]) {
        CGRect frame = self.view.superview.frame;
        frame.size.height = 380;
        self.view.superview.frame = frame;   
    }
    self.inputCell = nil;
    self.comment = [[Ushahidi sharedInstance] addCommentForReport:self.report];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([USHDevice isIPad]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        self.view.superview.center = self.view.superview.superview.center;
        [UIView commitAnimations];
    }
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return TableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionComment) {
        return [USHTableCellFactory inputTableCellForTable:tableView 
                                                 indexPath:indexPath 
                                                  delegate:self
                                               placeholder:NSLocalizedString(@"Enter comment", nil)
                                                      text:nil 
                                                      icon:@"comment.png"
                                            capitalization:UITextAutocapitalizationTypeSentences 
                                                correction:UITextAutocorrectionTypeNo 
                                                  spelling:UITextSpellCheckingTypeYes 
                                                  keyboard:UIKeyboardTypeDefault
                                                      done:UIReturnKeyDefault];
    }
    else if (indexPath.section == TableSectionAuthor) {
        NSString *author = [[USHSettings sharedInstance] contactFullName];
        self.comment.author = author;

        return [USHTableCellFactory inputTableCellForTable:tableView 
                                                 indexPath:indexPath 
                                                  delegate:self
                                               placeholder:NSLocalizedString(@"Enter name", nil)
                                                      text:author
                                                      icon:@"name.png"
                                            capitalization:UITextAutocapitalizationTypeWords 
                                                correction:UITextAutocorrectionTypeNo 
                                                  spelling:UITextSpellCheckingTypeNo 
                                                  keyboard:UIKeyboardTypeDefault 
                                                      done:UIReturnKeyDefault]; 
    }
    else if (indexPath.section == TableSectionEmail) {
        NSString *email = [[USHSettings sharedInstance] contactEmailAddress];
        self.comment.email = email;

        return [USHTableCellFactory inputTableCellForTable:tableView 
                                                 indexPath:indexPath 
                                                  delegate:self
                                               placeholder:NSLocalizedString(@"Enter email", nil)
                                                      text:email
                                                      icon:@"email.png"
                                            capitalization:UITextAutocapitalizationTypeNone 
                                                correction:UITextAutocorrectionTypeNo 
                                                  spelling:UITextSpellCheckingTypeNo 
                                                  keyboard:UIKeyboardTypeEmailAddress 
                                                      done:UIReturnKeyDefault]; 
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == TableSectionComment) {
        return [USHDevice isIPad] ? 150 : 175;
    }
    return 44;
}

#pragma mark - USHInputTableCellDelegate

- (void) inputFocussed:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath {
    DLog(@"%d,%d", indexPath.section, indexPath.row);
    self.inputCell = cell;
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void) inputChanged:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    self.inputCell = cell;
    if (indexPath.section == TableSectionComment) {
        self.comment.text = text;
    }
    else if (indexPath.section == TableSectionAuthor) {
        self.comment.author = text;
    }
    else if (indexPath.section == TableSectionEmail) {
        self.comment.email = text;
    }
}

- (void) inputReturned:(USHInputTableCell *)cell indexPath:(NSIndexPath *)indexPath text:(NSString *)text {
    DLog(@"%d,%d %@", indexPath.section, indexPath.row, text);
    [self.inputCell resignFirstResponder];
    self.inputCell = nil;
}

#pragma mark - USHLoginDialog
     
- (void) loginDialogReturned:(USHLoginDialog *)dialog username:(NSString *)username password:(NSString *)password {
    DLog(@"username:%@ password:%@", username, password);
    self.map.username = username;
    self.map.password = password;
    [[Ushahidi sharedInstance] saveChanges];
    [[Ushahidi sharedInstance] uploadComment:self.comment delegate:self];
}

- (void) loginDialogCancelled:(USHLoginDialog *)dialog {
    DLog(@"");
}

#pragma mark - UshahidiDelegate

- (void) ushahidi:(Ushahidi*)ushahidi uploaded:(USHMap*)map comment:(USHComment*)comment error:(NSError*)error {
    if (error) {
        [self hideLoading];
        DLog(@"Error:%@ Description:%@ Code:%d", error, error.description, error.code);
        if (error.code == NSURLErrorUserAuthenticationRequired) {
            [self.loginDialog showWithTitle:NSLocalizedString(@"Authentication Required", nil) 
                                   username:self.map.username 
                                   password:self.map.password];
        }
        else {
            [UIAlertView showWithTitle:NSLocalizedString(@"Upload Error", nil) 
                               message:[error localizedDescription] 
                              delegate:self 
                                   tag:AlertViewDefault 
                                cancel:NSLocalizedString(@"OK", nil) 
                               buttons:nil];   
        }
    }
    else {
        self.comment.pending = [NSNumber numberWithBool:NO];
        [[Ushahidi sharedInstance] saveChanges];
        [self showLoadingWithMessage:NSLocalizedString(@"Sent", nil) hide:2.0];
        [self performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:2.2];
    }
}

@end
