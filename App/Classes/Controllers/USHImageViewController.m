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

#import "USHImageViewController.h"
#import <Ushahidi/UIAlertView+USH.h>
#import <Ushahidi/USHDevice.h>

@interface USHImageViewController ()

@property (strong, nonatomic) USHShareController *shareController;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeLeftRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer * swipeRightRecognizer;

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer;
- (void) savePhotoInBackground;
- (void) imageSaved:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
- (float) minimumZoomScale;

@end

@implementation USHImageViewController

typedef enum {
	NavBarPrevious,
	NavBarNext
} NavBar;

@synthesize imageView = _imageView;
@synthesize scrollView = _scrollView;
@synthesize images = _images;
@synthesize image = _image;
@synthesize nextPrevious = _nextPrevious;
@synthesize shareController = _shareController;
@synthesize name = _name;
@synthesize url = _url;
@synthesize swipeLeftRecognizer = _swipeLeftRecognizer;
@synthesize swipeRightRecognizer = _swipeRightRecognizer;

#pragma mark - ToolBar

- (void) adjustToolBarHeight {
    if ([USHDevice isIPad] && self.toolBar != nil && self.scrollView != nil) {
        NSInteger tabBarHeight = 49;
        CGRect toolBarFrame = self.toolBar.frame;
        toolBarFrame.size.height = tabBarHeight;
        toolBarFrame.origin.y = self.view.frame.size.height - tabBarHeight;
        self.toolBar.frame = toolBarFrame;
        CGRect scrollViewFrame = self.scrollView.frame;
        scrollViewFrame.size.height = self.view.frame.size.height - self.scrollView.frame.origin.y - tabBarHeight;
        self.scrollView.frame = scrollViewFrame;
    }
}

#pragma mark - IBActions

- (IBAction) nextPrevious:(id)sender {
    DLog(@"");
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

- (IBAction) save:(id)sender event:(UIEvent*)event {
    DLog(@"");
    [self showLoadingWithMessage:NSLocalizedString(@"Saving...", nil)];
	[self performSelectorInBackground:@selector(savePhotoInBackground) withObject:nil];
}

- (IBAction) action:(id)sender event:(UIEvent*)event {
    [self.shareController showShareForEvent:event];
}

#pragma mark - UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5f;
    self.scrollView.maximumZoomScale = 5.0f;
    
    self.shareController = [[USHShareController alloc] initWithController:self];
    
    self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self adjustToolBarHeight];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.shareController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
	if (self.images != nil && self.image != nil) {
		NSInteger index = [self.images indexOfObject:self.image];
        DLog(@"%d / %d", index + 1, self.images.count);
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
    [self.view addGestureRecognizer:self.swipeLeftRecognizer];
    [self.view addGestureRecognizer:self.swipeRightRecognizer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    DLog(@"");
    [self.view removeGestureRecognizer:self.swipeLeftRecognizer];
    [self.view removeGestureRecognizer:self.swipeRightRecognizer];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.scrollView.contentSize = self.imageView.image.size;
    [self.imageView sizeToFit];
    self.scrollView.zoomScale = [self minimumZoomScale];
    self.scrollView.minimumZoomScale = [self minimumZoomScale];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
    self.imageView.frame = frameToCenter;
}

- (float) minimumZoomScale {
    float widthRatio = self.scrollView.bounds.size.width / self.imageView.image.size.width;
    float heightRatio = self.scrollView.bounds.size.height / self.imageView.image.size.height;
    return MIN(widthRatio, heightRatio);
}

#pragma mark - UIImage

- (void) savePhotoInBackground {
	@autoreleasepool {
		UIImageWriteToSavedPhotosAlbum
		(self.imageView.image, self, @selector(imageSaved:didFinishSavingWithError:contextInfo:), nil);
	}
}

- (void)imageSaved:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error != nil) {
        [self hideLoading];
        [UIAlertView showWithTitle:NSLocalizedString(@"Error Saving Photo", nil)
                           message:[error localizedDescription] 
                          delegate:self 
                               tag:0 
                            cancel:NSLocalizedString(@"OK", nil) 
                           buttons:nil];
	}
    else {
        [self showLoadingWithMessage:NSLocalizedString(@"Saved", nil) hide:2.0];
    }
}

#pragma mark - UISwipeGestureRecognizer

- (void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    DLog(@"");
    NSInteger index = [self.images indexOfObject:self.image];
    if (self.images.count > index + 1) {
        index += 1;
        self.image = [self.images objectAtIndex:index];
        self.imageView.image = [self.images objectAtIndex:index];
        self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.images count]];
        [self.nextPrevious setEnabled:(index > 0) forSegmentAtIndex:NavBarPrevious];
        [self.nextPrevious setEnabled:(index + 1 < [self.images count]) forSegmentAtIndex:NavBarNext];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)recognizer {
    DLog(@"");
    NSInteger index = [self.images indexOfObject:self.image];
    if (index > 0) {
        index -= 1;
        self.image = [self.images objectAtIndex:index];
        self.imageView.image = [self.images objectAtIndex:index];
        self.title = [NSString stringWithFormat:@"%d / %d", index + 1, [self.images count]];
        [self.nextPrevious setEnabled:(index > 0) forSegmentAtIndex:NavBarPrevious];
        [self.nextPrevious setEnabled:(index + 1 < [self.images count]) forSegmentAtIndex:NavBarNext];
    }
}

#pragma mark - USHShareController

- (void) sharePrintText:(USHShareController*)share {
    DLog(@"");
    NSData *data = UIImageJPEGRepresentation(self.image, 1);
    [self.shareController printData:data title:self.name];
}

- (void) shareSendEmail:(USHShareController*)share {
    NSData *data = UIImageJPEGRepresentation(self.image, 1);
    NSString *email = [NSString stringWithFormat:@"%@<br/><a href='%@'>%@</a>", self.name, self.url, self.url, nil];
    [self.shareController sendEmail:email subject:self.name attachment:data fileName:@"image.jpg" recipient:nil];
}

- (void) shareSendTweet:(USHShareController*)share {
    [self.shareController sendTweet:self.name url:self.url image:self.image];
}

- (void) sharePostFacebook:(USHShareController*)share {
    [self.shareController postFacebook:self.name url:self.url image:self.image];
}

@end
