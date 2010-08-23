//
//  ImageViewController.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-11.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController {
	
@public
	UIImageView *imageView;
	UIImage *image;
}

@property(nonatomic, retain) IBOutlet UIImageView *imageView;
@property(nonatomic, retain) UIImage *image;

@end
