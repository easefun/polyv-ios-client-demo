//
//  DetailViewController.m
//  polyvSDK
//
//  Created by seanwong on 10/23/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import "DetailViewController2.h"
#import "SkinVideoViewController.h"
#import "PvVideo.h"
#import "PolyvSettings.h"
@interface DetailViewController2 ()

@property (nonatomic, strong)  SkinVideoViewController *videoPlayer;

@property (nonatomic, assign) NSString *currentVid;     // 存储当前的vid
@property (nonatomic, assign) BOOL isShouldPause;


@end


@implementation DetailViewController2

- (SkinVideoViewController *)videoPlayer{
	if (!_videoPlayer) {
		CGFloat width = self.view.bounds.size.width;
		_videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, width*(9.0/16.0))];
		[_videoPlayer configObserver];
	}
	return _videoPlayer;
}

- (void)viewDidDisappear:(BOOL)animated {
	// 主动调用 cancel 方法销毁播放器
	[self.videoPlayer cancel];    // cancel方法中调用了cancelObserver
	[[NSNotificationCenter defaultCenter] removeObserver:self];
 
	[super viewDidDisappear:animated];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeNone;
	self.isPresented = NO;
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	// 播放指定 vid 的视频
	[self.videoPlayer setVid:self.video.vid];
	
	[self.view addSubview:self.videoPlayer.view];
	[self.videoPlayer setParentViewController:self];
	
	// 需要保留导航栏
	[self.videoPlayer keepNavigationBar:YES];
	[self.videoPlayer setNavigationController:self.navigationController];
	
	// 设置附加组件
	[self.videoPlayer setHeadTitle:self.video.title];
	//[self.videoPlayer setEnableDanmuDisplay:NO];      // 不显示弹幕按钮
	//[self.videoPlayer setEnableRateDisplay:NO];       // 不显示播放速率按钮
	
	//UIImage *logo = [UIImage imageNamed:@"pvlogo.png"];
	//[self.videoPlayer setLogo:logo location:PvLogoLocationTopLeft size:CGSizeMake(70, 30) alpha:0.8]; // 设置logo
	
	// 开启片头播放
	// self.videoPlayer.teaserEnable = YES;
	
	// 自动续播, 是否继续上次观看的位置
	//	self.videoPlayer.autoContinue = YES;
	
	// 开启弹幕
	[self.videoPlayer enableDanmu:YES];
	
	// 是否开启截图
	self.videoPlayer.enableSnapshot = YES;
	
	// 设置是否自动播放，默认为YES
	//self.videoPlayer.shouldAutoplay = NO;
	
	
	/**
	 *  ---- 回调代码块 ----
	 */
	[self.videoPlayer setPlayButtonClickBlock:^{
		NSLog(@"user click play button");
	}];
	[self.videoPlayer setPauseButtonClickBlock:^{
		NSLog(@"user click pause button");
	}];
	
	[self.videoPlayer setFullscreenBlock:^{
		//NSLog(@"should hide toolbox in this viewcontroller if needed");
	}];
	[self.videoPlayer setShrinkscreenBlock:^{
		//NSLog(@"show toolbox back if needed");
	}];
	
	// 视频播放完成的回调代码块
	[self.videoPlayer setWatchCompletedBlock:^{
		NSLog(@"user watching completed");
	}];
}


///**
// *  ----- 以下按钮部分为测试视频跳转实例，如无需要可自行删除 ----
// */
//- (void)addTestButton {
//    // 跳转指定时间测试按钮
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(200, 230, 120, 30)];
//    [btn setTitle:@"跳至30s" forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.view addSubview:btn];
//    [btn addTarget:self action:@selector(seekBtnClick) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton *video1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 230, 150, 30)];
//    [self.view addSubview:video1];
//    [video1 setTitle:@"视频1 20s播放" forState:UIControlStateNormal];
//    video1.tag = 100;
//    [video1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [video1 addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton *video2 = [[UIButton alloc] initWithFrame:CGRectMake(20, 280, 150, 30)];
//    [self.view addSubview:video2];
//    video2.tag = 101;
//    [video2 setTitle:@"视频2 30s播放" forState:UIControlStateNormal];
//    [video2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [video2 addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton *video3 = [[UIButton alloc] initWithFrame:CGRectMake(20, 330, 150, 30)];
//    [self.view addSubview:video3];
//    video3.tag = 102;
//    [video3 setTitle:@"视频3 40s播放" forState:UIControlStateNormal];
//    [video3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [video3 addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)seekBtnClick {
//
//    // 注意：1.续播用setWatchStartTime:跳到某个播放位置
//    //      2.主动点击seek到某个位置，用setCurrentPlaybackTime:(播放中)
//    [self.videoPlayer setCurrentPlaybackTime:30.0];
//
//    //[self.videoPlayer play];   // 播放视频，如果设置setAutoplay为NO, 须调用此方法
//}
//
//
//- (void)switchVideo:(UIButton *)button {
//    switch (button.tag) {
//        case 100: {
//            self.currentVid = @"sl8da4jjbx1c8baed8a48212d735d905_s";        // 加密
//            [self.videoPlayer setWatchStartTime:20.0];                      // 跳至20s
//        }
//            break;
//        case 101: {
//            self.currentVid = @"sl8da4jjbxe69c6942a7a737819660de_s";        // 加密
//            [self.videoPlayer setWatchStartTime:30];                        // 跳至30s
//            //[self.videoPlayer setAutoplay:NO];                            // 是否自动播放
//        }
//            break;
//        case 102: {
//            //[self.videoPlayer setAutoplay:YES];  // 如果之前设置自动播放为NO，此处须重新设置YES进行自动播放
//            self.currentVid = @"sl8da4jjbx1db751c1820f564192800a_s";        // 非加密
//            [self.videoPlayer setWatchStartTime:40];                        // 跳至40s
//        }
//            break;
//        default:
//            break;
//    }
//    [self.videoPlayer setVid:self.currentVid];
//}
@end
