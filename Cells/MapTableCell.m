//
//  MapTableCell.m
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-10.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import "MapTableCell.h"

@implementation MapTableCell

@synthesize delegate, indexPath;

- (id)initWithDelegate:(id<MapTableCellDelegate>)theDelegate reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		self.delegate = theDelegate;
        
	}
    return self;
}

@end
