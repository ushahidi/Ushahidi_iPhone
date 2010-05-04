//
//  photosViewController.h
//  UshahidiProj
//
//  Created by iSoft Solutions on 31/03/10.
//  Copyright 2010 iSoft Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface photosViewController : UIViewController<UIScrollViewDelegate> {

	UIScrollView *scView;
	NSMutableDictionary *photoDict;
}
@property(nonatomic,retain) NSMutableDictionary *photoDict;
@end
