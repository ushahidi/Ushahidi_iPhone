//
//  UNViewController+Extension.m
//  Ushahidi_iOS
//
//  Created by Dale Zak on 12-04-26.
//  Copyright (c) 2012 Ushahidi. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (BOOL) isTopLevelController {
    NSArray *viewControllers = [[self navigationController] viewControllers];
    UIViewController *rootViewController = [viewControllers objectAtIndex:0];    
    return rootViewController == self;
}

@end
