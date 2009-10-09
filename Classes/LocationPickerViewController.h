//
//  LocationPickerViewController.h
//  Ushahidi
//
//  Created by Wilfred Mworia on 10/9/09.
//  Copyright 2009 African Pixel. All rights reserved.
//



//  Some code used here was adapted from MapApp tutorial - http://mithin.in/2009/06/22/using-iphone-sdk-mapkit-framework-a-tutorial/
//  Created by Mithin on 21/06/09.
//  Copyright 2009 Techtinium Corporation. All rights reserved.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface AddressAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	
	NSString *mTitle;
	NSString *mSubTitle;
}

@end


@interface LocationPickerViewController : UIViewController<MKMapViewDelegate> {
	IBOutlet UITextField *addressField;
	IBOutlet UIBarButtonItem *goButton;
	MKMapView *mapView;
	
	AddressAnnotation *addAnnotation;
	
	NSString *loc_name;
}
@property (nonatomic, retain) AddressAnnotation *addAnnotation;
@property (nonatomic, retain) NSString *loc_name;

- (IBAction) showAddress;

-(CLLocationCoordinate2D) addressLocation;

@end
