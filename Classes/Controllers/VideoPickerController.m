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

#import "VideoPickerController.h"
#import "Device.h"
#import "NSObject+Extension.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Settings.h"
#import "GDataServiceGoogleYouTube.h"
#import "GDataEntryYouTubeUpload.h"

@interface VideoPickerController ()

- (void) showVideoPickerForSourceType:(UIImagePickerControllerSourceType)sourceType;
- (void) uploadVideoToYoutubeFromPath:(NSString*)filepath;

@end

@implementation VideoPickerController

@synthesize viewController, popoverController, delegate;

- (id)initWithController:(UIViewController *)controller {
    if ((self = [super init])) {
		self.viewController = controller;
	}
    return self;
}

- (void) showVideoPickerForDelegate:(id<VideoPickerDelegate>)theDelegate forRect:(CGRect)sourceRect {
	self.delegate = theDelegate;
    rect = sourceRect;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
												   destructiveButtonTitle:nil
														otherButtonTitles:NSLocalizedString(@"Take Video", nil), 
																		  NSLocalizedString(@"From Library", nil), nil];
		[actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
		[actionSheet showInView:self.viewController.view];
		[actionSheet release];
	}
	else {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

- (void)dealloc {
	delegate = nil;
	[viewController release];
	[popoverController release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark -
#pragma mark Internal

- (void) showVideoPickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
	DLog(@"showVideoPicker");
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
    imagePicker.mediaTypes = [NSArray arrayWithObjects: (NSString*)kUTTypeMovie, nil];
    imagePicker.sourceType = sourceType;
    imagePicker.videoMaximumDuration = 10;
    
	if ([Device isIPad]) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
		[self.popoverController setPopoverContentSize:imagePicker.view.frame.size animated:NO];
		self.popoverController.delegate = self;
		[self.popoverController presentPopoverFromRect:rect
		 										inView:self.viewController.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny 
											  animated:YES];
	}
	else {
        imagePicker.modalPresentationStyle = UIModalPresentationPageSheet;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[viewController presentModalViewController:imagePicker animated:YES];
	}
	[imagePicker release];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	DLog(@"editingInfo: %@", editingInfo);
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
    
	[self dispatchSelector:@selector(videoPickerDidSelect:) target:delegate objects:self, nil];

    NSString *path = [[editingInfo objectForKey:UIImagePickerControllerMediaURL] path];
    [self uploadVideoToYoutubeFromPath:path];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	DLog(@"info: %@", info);
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self dispatchSelector:@selector(videoPickerDidSelect:) target:delegate objects:self, nil];

    NSString *path = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    [self uploadVideoToYoutubeFromPath:path];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	DLog(@"");
	if (self.popoverController != nil) {
		[self.popoverController dismissPopoverAnimated:YES];
	}
	else {
		[self.viewController dismissModalViewControllerAnimated:YES];
	}
	[self dispatchSelector:@selector(videoPickerDidCancel:) target:delegate objects:self, nil];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *titleAtIndex = [actionSheet buttonTitleAtIndex:buttonIndex];
	DLog(@"titleAtIndex: %@", titleAtIndex);
	if ([titleAtIndex isEqualToString:NSLocalizedString(@"Take Video", nil)]) {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypeCamera];
	}
	else if ([titleAtIndex isEqualToString:NSLocalizedString(@"From Library", nil)]) {
		[self showVideoPickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	}
}

#pragma mark -
#pragma mark Youtube

- (void) uploadVideoToYoutubeFromPath:(NSString*)filepath {
    DLog(@"uploadVideoToYoutubeFromPath: %@", filepath);

    GDataServiceGoogleYouTube *service = [self youTubeService];
    [service setYouTubeDeveloperKey:[Settings sharedSettings].youtubeDeveloperKey];

    NSURL *url = [GDataServiceGoogleYouTube youTubeUploadURLForUserID:[Settings sharedSettings].youtubeLogin];
    
    // load the file data
    NSData *data = [NSData dataWithContentsOfFile:filepath];
    
    // gather all the metadata needed for the mediaGroup
    NSString *titleStr = @"test";
    GDataMediaTitle *title = [GDataMediaTitle textConstructWithString:titleStr];
    
    NSString *descStr = @"test3";
    GDataMediaDescription *desc = [GDataMediaDescription textConstructWithString:descStr];
    
    NSString *categoryStr = @"Nonprofit";
    GDataMediaCategory *category = [GDataMediaCategory mediaCategoryWithString:categoryStr];

    
    NSString *keywordsStr = @"test4";
    GDataMediaKeywords *keywords = [GDataMediaKeywords keywordsWithString:keywordsStr];

    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [mediaGroup setMediaTitle:title];
    [mediaGroup setMediaDescription:desc];
    [mediaGroup setMediaKeywords:keywords];
    [mediaGroup setMediaCategories:[NSArray arrayWithObject:category]];
    [mediaGroup setIsPrivate:NO];
    
    NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:filepath
                                               defaultMIMEType:@"video/mp4"];
    
    // create the upload entry with the mediaGroup and the file data
    GDataEntryYouTubeUpload *entry;
    entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                          data:data
                                                      MIMEType:mimeType
                                                          slug:titleStr];
    
    SEL progressSel = @selector(ticket:hasDeliveredByteCount:ofTotalByteCount:);
    [service setServiceUploadProgressSelector:progressSel];
    
    GDataServiceTicket *ticket;
    ticket = [service fetchEntryByInsertingEntry:entry
                                      forFeedURL:url
                                        delegate:self
                               didFinishSelector:@selector(uploadTicket:finishedWithEntry:error:)];
}


// progress callback
- (void)ticket:(GDataServiceTicket *)ticket
hasDeliveredByteCount:(unsigned long long)numberOfBytesRead 
ofTotalByteCount:(unsigned long long)dataLength {
    
//    [mProgressView setProgress:(double)numberOfBytesRead / (double)dataLength];
}


- (void)uploadTicket:(GDataServiceTicket *)ticket
   finishedWithEntry:(GDataEntryYouTubeVideo *)videoEntry
               error:(NSError *)error {
    if (error == nil) {
        // tell the user that the add worked
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uploaded!"
                                                        message:[NSString stringWithFormat:@"%@ succesfully uploaded", 
                                                                 [[videoEntry title] stringValue]]                    
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
        
        
        [self dispatchSelector:@selector(videoPickerDidFinish:image:)
                        target:self.delegate 
                       objects:self, @"FILEPATH", nil];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:[NSString stringWithFormat:@"Error: %@", 
                                                                 [error description]] 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
        
        [alert show];
        [alert release];
    }
   // [mProgressView setProgress: 0.0];
}

- (GDataServiceGoogleYouTube *)youTubeService {
    
    static GDataServiceGoogleYouTube* service = nil;
    
    if (!service) {
        service = [[GDataServiceGoogleYouTube alloc] init];
        
        [service setServiceShouldFollowNextLinks:YES];
        [service setIsServiceRetryEnabled:YES];
    }
    
    NSString *username = [Settings sharedSettings].youtubeLogin;
    NSString *password = [Settings sharedSettings].youtubePassword;
    
    [service setUserCredentialsWithUsername:username password:password];
    
    service.youTubeDeveloperKey = [Settings sharedSettings].youtubeDeveloperKey;
    return service;
}


@end
