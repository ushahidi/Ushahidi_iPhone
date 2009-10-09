//
//  AboutViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/21/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
	IBOutlet UIButton *link;
}

- (void)openWebsite:(id)sender;

@property (nonatomic, retain) IBOutlet UIButton *link;

@end
