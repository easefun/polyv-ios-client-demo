//
//  UINavigationController+Orientation.m
//  polyvSDK
//
//  Created by LinBq on 17/2/5.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)

- (BOOL)shouldAutorotate{
	return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
	return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)prefersStatusBarHidden{
	return self.topViewController.prefersStatusBarHidden;
}

@end
