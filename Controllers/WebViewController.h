//
//  WebViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-09.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIActionSheetDelegate> {
	UIWebView *webView;
	UIBarButtonItem *refreshButton;
	UIBarButtonItem *backButton;
	UIBarButtonItem *forwardButton;
	NSString *website;
}

@property(nonatomic,retain) IBOutlet UIWebView *webView;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *backButton;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *forwardButton;
@property(nonatomic,retain) NSString *website;

- (IBAction) action:(id)sender;

@end
