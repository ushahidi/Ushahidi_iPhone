//
//  ImageTableCell.h
//  Ushahidi_iPhone
//
//  Created by Dale Zak on 10-08-11.
//  Copyright 2010 Ushahidi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableCell : UITableViewCell {
	
@public
	NSIndexPath *indexPath;
	UIImageView *cellImageView;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) UIImageView *cellImageView;

- (id)initWithImage:(UIImage *)image reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setImage:(UIImage *)image;
- (UIImage *) getImage;

@end
