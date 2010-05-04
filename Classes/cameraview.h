//
//  cameraview.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 24/02/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

// Forward Class Declaration
@class UshahidiProjAppDelegate;

// Implement Interface
@interface cameraview : UIViewController<UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate> {
	IBOutlet UIImageView *imageView;
	UIImagePickerController *UIPicker;
	UIToolbar *tb;
	IBOutlet UIView *viewImages;
	UIImage *images[20];
	int i;
	UIScrollView *scView;
	UshahidiProjAppDelegate *app;
}

// Implement Custom Methods
-(void)openCamera;
-(void)showImages;
@end
