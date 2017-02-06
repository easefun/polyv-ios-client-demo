//
//  UINavigationController+Orientation.h
//  polyvSDK
//
//  Created by LinBq on 17/2/5.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Orientation)

- (BOOL)shouldAutorotate;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
- (BOOL)prefersStatusBarHidden;

@end
