//
//  UITabBarController+Orientation.m
//  polyvSDK
//
//  Created by LinBq on 17/2/5.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import "UITabBarController+Orientation.h"

@implementation UITabBarController (Orientation)

- (BOOL)shouldAutorotate{
	return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	return self.selectedViewController.supportedInterfaceOrientations;
}

- (BOOL)prefersStatusBarHidden{
	return self.selectedViewController.prefersStatusBarHidden;
}

@end
