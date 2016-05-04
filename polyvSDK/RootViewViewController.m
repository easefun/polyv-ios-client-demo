//
//  RootViewViewController.m
//  polyvSDK
//
//  Created by LinBq on 16/4/14.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "RootViewViewController.h"
#import "DetailViewController2.h"
#import "DetailViewController.h"
#import "SkinVideoViewController.h"
#import "DownloadListTableViewController.h"
#import "AppDelegate.h"

#define ApplicationDelegate   ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface RootViewViewController ()

@end

@implementation RootViewViewController

-(void)awakeFromNib{
	self.selectedIndex = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 哪些页面支持自动转屏
- (BOOL)shouldAutorotate{
	UIViewController *vc = self.viewControllers[self.selectedIndex];
	if ([vc isMemberOfClass:[UINavigationController class]]) {
		UIViewController *topVC = ((UINavigationController *)vc).topViewController;
		if ([topVC isMemberOfClass:[DetailViewController2 class]] || [topVC isMemberOfClass:[DetailViewController class]]) {
			return YES;
		}
	}
	return NO;
}

// 支持哪些转屏方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	UIViewController *vc = self.viewControllers[self.selectedIndex];
	if ([vc isMemberOfClass:[UINavigationController class]]){
		UINavigationController *nav = (UINavigationController *)vc;
		if ([nav.topViewController isMemberOfClass:[DetailViewController2 class]] || [nav.topViewController isMemberOfClass:[DetailViewController class]]) {
			return UIInterfaceOrientationMaskAllButUpsideDown;
		}else { // 其他页面支持转屏方向
			return UIInterfaceOrientationMaskPortrait;
		}
	}
	return UIInterfaceOrientationMaskPortrait;
}
@end
