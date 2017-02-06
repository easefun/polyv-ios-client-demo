//
//  UITabBarController+Orientation.h
//  polyvSDK
//
//  Created by LinBq on 17/2/5.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (Orientation)

- (BOOL)shouldAutorotate;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (BOOL)prefersStatusBarHidden;

@end
