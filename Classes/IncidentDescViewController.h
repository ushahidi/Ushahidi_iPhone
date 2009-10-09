//
//  IncidentDescViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 10/8/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IncidentDescViewController : UIViewController {
	IBOutlet UITextView *textView;
	IBOutlet UIButton *roundedButton;
}

- (NSString *)incidentDescription;

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIButton *roundedButton;

@end
