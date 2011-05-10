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

#import "ImageViewController.h"
#import "LoadingViewController.h"
#import "TwitterViewController.h"
#import "Settings.h"
#import "Email.h"

@interface ImageViewController ()

@property(nonatomic,retain) Email *email;

- (void) savePhotoInBackground;
- (void) imageSaved:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

@implementation ImageViewController

typedef enum {
	NavBarPrevious,
	NavBarNext
} NavBar;

@synthesize twitterViewController, imageView, image, images, nextPrevious, email, pending;
@synthesize emailButton, saveButton, tweetButton;

- (IBAction) nextPrevious:(id)sender {
	NSInteger index = [self.images indexOfObject:self.image];
	if (self.nextPrevious.selectedSegmentIndex == NavBarNext) {
		DLog(@"Next Image");
		self.image = [self.images objectAtIndex:index + 1];
		self.imageView.image = [self.images objectAtIndex:index + 1];
	}
	else if (self.nextPrevious.selectedSegmentIndex == NavBarPrevious) {
		DLog(@"Previous Image");
		self.image = [self.images objectAtIndex:index - 1];
		self.imageView.image = [self.images objectAtIndex:index - 1];
	}
	NSInteger newIndex = [self.images indexOfObject:self.image];
	self.title = [NSString stringWithFormat:@"%d / %d", newIndex + 1, [self.images count]];
	[self.nextPrevious setEnabled:(newIndex > 0) forSegmentAtIndex:NavBarPrevious];
	[self.nextPrevious setEnabled:(newIndex + 1 < [self.images count]) forSegmentAtIndex:NavBarNext];
}

- (IBAction) tweetPhoto:(id)sender {
	self.twitterViewController.tweet = [NSMutableString	stringWithFormat:@""];
	[self presentModalViewController:self.twitterViewController animated:YES];
}

- (IBAction) sendEmail:(id)sender {
	DLog(@"");
	[self.email	sendToRecipients:nil withMessage:nil withSubject:nil withPhotos:[NSArray arrayWithObject:self.image]];
}

- (IBAction) savePhoto:(id)sender {
	DLog(@"");
	[self.loadingView showWithMessage:NSLocalizedString(@"Saving...", nil)];
	[self performSelectorInBackground:@selector(savePhotoInBackground) withObject:nil];
}

- (void) savePhotoInBackground {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	UIImageWriteToSavedPhotosAlbum
	(self.imageView.image, self, @selector(imageSaved:didFinishSavingWithError:contextInfo:), nil);
	[pool release];
}

- (void)imageSaved:(UIImage *)theImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[self.loadingView hide];
    if (error != nil) {
		[self.alertView showOkWithTitle:NSLocalizedString(@"Error Saving Photo", nil) 
							 andMessage:[error localizedDescription]];
	}
}

#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.toolBar.tintColor = [[Settings sharedSettings] toolBarTintColor];
	self.email = [[Email alloc] initWithController:self];
	self.emailButton.enabled = [self.email canSend];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.email = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.imageView.image = self.image;
	if (self.images != nil) {
		NSInteger index = [self.images indexOfObject:self.image];
		if (index != NSNotFound) {
			self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.images count]];
			[self.nextPrevious setEnabled:index > 0 forSegmentAtIndex:NavBarPrevious];
			[self.nextPrevious setEnabled:index + 1 < [self.images count] forSegmentAtIndex:NavBarNext];	
		}
		else {
			self.title = @"1 / 1";
			[self.nextPrevious setEnabled:NO forSegmentAtIndex:NavBarPrevious];
			[self.nextPrevious setEnabled:NO forSegmentAtIndex:NavBarNext];
		}	
	}
	else {
		[self.nextPrevious setEnabled:NO forSegmentAtIndex:NavBarPrevious];
		[self.nextPrevious setEnabled:NO forSegmentAtIndex:NavBarNext];
	}
	self.tweetButton.enabled = !self.pending;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {
	[twitterViewController release];
	[imageView release];
	[image release];
	[images	release];
	[nextPrevious release];
	[email release];
	[emailButton release];
	[saveButton release];
	[tweetButton release];
	[super dealloc];
}

@end
