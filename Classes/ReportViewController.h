//
//  ReportViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 9/23/09.
//  Copyright 2009 African Pixel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IncidentDescViewController.h"
#import "CategorySelectTableViewController.h"
#import "DatePickerViewController.h"
#import "LocationPickerViewController.h"
#import "API.h"

@interface ReportViewController : UITableViewController <UITextFieldDelegate, UITextInputTraits, UIAlertViewDelegate> {
	
	UIBarButtonItem *saveButton;
	UIBarButtonItem *doneButton;
	
	API *incidentAPI;
	
	IncidentDescViewController *descView;
	CategorySelectTableViewController *categoryView;
	DatePickerViewController *datePiker;
	LocationPickerViewController *locView;
	
	UITextField *titleTextView;
	NSString *description;
	
	UIImage *photo1;
	UIImage *photo2;
	UIImage *photo3;
	
	UITextView *newsLinkText;
	
	UITextView *videoLinkText;
	
	//postable properties
	NSString *incident_title;
	
	NSString *incident_description;
	
	NSString *incident_date; //mm/dd/yyyy
	
	NSString *incident_hour;
	
	NSString *incident_minute;
	
	NSString *incident_ampm;
	
	NSString *incident_category;
	
	double latitude;
	
	double longitude; 
	
	NSString *location_name;
	
}

- (void) doneEditing;

@property (nonatomic, retain) UIBarButtonItem *saveButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

@property (nonatomic, retain) API *incidentAPI;
@property (nonatomic, retain) IncidentDescViewController *descView;
@property (nonatomic, retain) CategorySelectTableViewController *categoryView;
@property (nonatomic, retain) DatePickerViewController *datePiker;
@property (nonatomic, retain) LocationPickerViewController *locView;
@property (nonatomic, retain) UITextField *titleTextView;
@property (nonatomic, retain) NSString *description;


@property (nonatomic, retain) NSString *incident_title;

@property (nonatomic, retain) NSString *incident_description;

@property (nonatomic, retain) NSString *incident_date; //mm/dd/yyyy

@property (nonatomic, retain) NSString *incident_hour;

@property (nonatomic, retain) NSString *incident_minute;

@property (nonatomic, retain) NSString *incident_ampm;

@property (nonatomic, retain) NSString *incident_category;

@property (nonatomic) double latitude;

@property (nonatomic) double longitude; 

@property (nonatomic, retain) NSString *location_name;

@end
