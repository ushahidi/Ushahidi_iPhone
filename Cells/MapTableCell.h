//
//  MapTableCell.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@protocol MapTableCellDelegate;

@interface MapTableCell : NSObject {
	id<MapTableCellDelegate> delegate;
	NSIndexPath	*indexPath;
}

@property (nonatomic, assign) id<MapTableCellDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *indexPath; 

- (id)initWithDelegate:(id<MapTableCellDelegate>)delegate reuseIdentifier:(NSString *)reuseIdentifier;

@end

@protocol MapTableCellDelegate <NSObject>

@optional

@end