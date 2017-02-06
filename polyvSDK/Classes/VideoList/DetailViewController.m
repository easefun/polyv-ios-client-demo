//
//  DetailViewController.m
//  polyvSDK
//
//  Created by seanwong on 10/23/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import "DetailViewController.h"
#import "SkinVideoViewController.h"

@interface DetailViewController ()

@property (nonatomic, strong)  SkinVideoViewController*videoPlayer;

@end


@implementation DetailViewController


-(void)viewDidDisappear:(BOOL)animated {
	self.isPresented = YES;
	self.videoPlayer.contentURL = nil;
	[self.videoPlayer stop];
	[self.videoPlayer cancel];
	//[self.videoPlayer cancelObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
	[self.videoPlayer configObserver];
    self.isPresented = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
//	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	[super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    CGFloat width = self.view.bounds.size.width;
    if (!self.videoPlayer) {
        self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(0, 0, width, width*(9.0/16.0))];
    }
    [self.videoPlayer setHeadTitle:self.video.title];
    UIImage*logo = [UIImage imageNamed:@"pvlogo.png"];
    [self.videoPlayer setLogo:logo location:PvLogoLocationTopLeft size:CGSizeMake(70,30) alpha:0.8];
    
//    [self.view addSubview:self.videoPlayer.view];
	CGSize playerSize = self.videoPlayer.frame.size;
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, playerSize.width, playerSize.height + 20)];
	[self.view addSubview:contentView];
	contentView.backgroundColor = [UIColor blackColor];
	[contentView addSubview:self.videoPlayer.view];
    [self.videoPlayer setParentViewController:self];
    [self.videoPlayer setNavigationController:self.navigationController];
    [self.videoPlayer setVid:self.video.vid];
    //直接跳到上一次播放位置
    //[self.videoPlayer setWatchStartTime:30];
	
	[self.videoPlayer rollInfo:@"info" font:[UIFont systemFontOfSize:10] color:[UIColor whiteColor] withDuration:3.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
