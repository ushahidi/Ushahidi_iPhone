//
//  IncidentDetailViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/23/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IncidentDetailViewController : UIViewController {
	NSMutableDictionary *incident;
	
	IBOutlet UILabel *incidentDate;
	IBOutlet UILabel *incidentLocation;
	IBOutlet UITextView *incidentSummary;
}

@property (nonatomic, retain) NSMutableDictionary *incident;

@property (nonatomic, retain) IBOutlet UILabel *incidentDate;
@property (nonatomic, retain) IBOutlet UILabel *incidentLocation;
@property (nonatomic, retain) IBOutlet UITextView *incidentSummary;

@end
