//
//  SubtitleTableCell.h
//  Ushahidi
//
//  Created by Dale Zak on 10-04-26.
//  Copyright 2010 Dale Zak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubtitleTableCell : UITableViewCell {
	
@public
	NSIndexPath *indexPath;
	UIImage *defaultImage;
}

@property (nonatomic, retain) NSIndexPath *indexPath; 
@property (nonatomic, retain) UIImage *defaultImage;

- (id)initWithDefaultImage:(UIImage *)defaultImage reuseIdentifier:(NSString *)reuseIdentifier;
- (void) setText:(NSString *)text;
- (void) setDescription:(NSString *)description;
- (void) setImage:(UIImage *)image;

@end
