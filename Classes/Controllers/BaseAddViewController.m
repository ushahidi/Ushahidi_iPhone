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

#import "BaseAddViewController.h"
#import "BaseViewController.h"
#import "LoadingViewController.h"
#import "Settings.h"

@interface BaseAddViewController()

@end

@implementation BaseAddViewController

@synthesize cancelButton;
@synthesize doneButton;

#pragma mark - Handlers

- (IBAction) cancel:(id)sender {
    DLog(@"");
}

- (IBAction) done:(id)sender {
    DLog(@"");
}

- (void) load:(NSObject*)item {
    //child will provide implementation
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelButton.title = NSLocalizedString(@"Cancel", nil);
    self.doneButton.title = NSLocalizedString(@"Add", nil);
    if ([self.doneButton respondsToSelector:@selector(setTintColor:)]) {
        self.doneButton.tintColor = [[Settings sharedSettings] doneButtonColor];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	[cancelButton release];
	[doneButton release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
