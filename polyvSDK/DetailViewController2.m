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

@property (nonatomic, strong)  SkinVideoViewController*videoPlayer;

@property (nonatomic, assign) NSString *currentVid;     // 存储当前的vid
@property (nonatomic, assign) BOOL isShouldPause;


@end


@implementation DetailViewController2


-(void)moviePlayBackDidFinish:(NSNotification *)notification{
    //NSLog(@"finished");
}

-(void)movieLoadStateDidChange:(NSNotification *)notification{
    
     //NSLog(@"LoadStateDidChange");
}

- (void)moviePlaybackIsPreparedToPlayDidChange:(NSNotification *)notification {
    
    /* 演示代码示例
    if (_isShouldPause) {
        [self.videoPlayer pause];
        [self.videoPlayer monitorVideoPlayback];
        _isShouldPause = NO;
    } */
}

-(void)viewDidDisappear:(BOOL)animated {
 
    // 记录本视频播放时间,记录播放进度需要执行此操作
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[ [NSUserDefaults standardUserDefaults] dictionaryForKey:@"dict"]];
    if (!self.videoPlayer.isWatchCompleted) {
        [mDict setValue:@(self.videoPlayer.currentPlaybackTime) forKey:self.video.vid];
        [[NSUserDefaults standardUserDefaults] setObject:mDict forKey:@"dict"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.isPresented = YES;
    self.videoPlayer.contentURL = nil;
    [self.videoPlayer stop];
    [self.videoPlayer cancel];
    [self.videoPlayer cancelObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
 
    [super viewDidDisappear:animated];
}


- (void) showConfirmationAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"流量提示"
                                                   message:@"3G网络下继续播放?"
                                                  delegate:self
                                         cancelButtonTitle:@"停止播放"
                                         otherButtonTitles:@"继续播放",nil];
    [alert show];
    
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 = Tapped yes
    if (buttonIndex == 0)
    {
        // ....
        [self.videoPlayer stop];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.isPresented = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.videoPlayer configObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackIsPreparedToPlayDidChange:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = self.view.bounds.size.width;
    
    
    if (!self.videoPlayer) {
        self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, width*(9.0/16.0))];
        //self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, 100)];
    }
    
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer setParentViewController:self];
    
    // 需要保留导航栏
    [self.videoPlayer keepNavigationBar:YES];
    [self.videoPlayer setHeadTitle:self.video.title];
    // 开启片头播放
    [self.videoPlayer enableTeaser:YES];
    [self.videoPlayer setNavigationController:self.navigationController];
    
    [self.videoPlayer setVid:self.video.vid];
    
    //[self.videoPlayer setAutoContinue:YES];           // 自动续播, 是否继续上次观看的位置
    
    [self.videoPlayer enableDanmu:YES];                 // 开启弹幕
    
    [self.videoPlayer setAutoplay:YES];                 // 设置是否自动播放,默认为YES
	
	self.videoPlayer.enableSnapshot = YES;
    
    //[self.videoPlayer setEnableDanmuDisplay:NO];      // 不显示弹幕按钮
    //[self.videoPlayer setEnableRateDisplay:NO];       // 不显示播放速率按钮
    
    
    //[self.videoPlayer setWatchStartTime:20];
    
    //[self showConfirmationAlert];
    
    //直接跳到上一次播放位置
    //[self.videoPlayer setWatchStartTime:380];
    
    [self.videoPlayer setAutoplay:YES];     // 设置是否自动播放,默认为YES
    
    
    //UIImage*logo = [UIImage imageNamed:@"pvlogo.png"];
    //[self.videoPlayer setLogo:logo location:PvLogoLocationTopLeft size:CGSizeMake(70,30) alpha:0.8];
    
    [self.videoPlayer setFullscreenBlock:^{
        //NSLog(@"should hide toolbox in this viewcontroller if needed");
    }];
    [self.videoPlayer setShrinkscreenBlock:^{
        //NSLog(@"show toolbox back if needed");
    }];
    
    // 视频播放完成的回调代码块
    [self.videoPlayer setWatchCompletedBlock:^{
        
        // 此处为演示播放完视频之后自动续播的功能，配合MPMediaPlaybackIsPreparedToPlayDidChangeNotification通知
        // 中的moviePlaybackIsPreparedToPlayDidChange方法使用
        //weakSelf.currentVid = @"sl8da4jjbxe69c6942a7a737819660de_s";
        //[weakSelf.videoPlayer setVid:weakSelf.currentVid];
        //[weakSelf.videoPlayer setWatchStartTime:1000];
        //_isShouldPause = YES;       //
        
        NSLog(@"user watching completed");
    }];
    
  
    //[self addTestButton];         // 测试
}

/**
 *  ----- 以下按钮部分为测试视频跳转实例，如无需要可自行删除 ----
 */
- (void)addTestButton {
    // 跳转指定时间测试按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(200, 230, 120, 30)];
    [btn setTitle:@"跳至30s" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(seekBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *video1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 230, 150, 30)];
    [self.view addSubview:video1];
    [video1 setTitle:@"视频1 20s播放" forState:UIControlStateNormal];
    video1.tag = 100;
    [video1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [video1 addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *video2 = [[UIButton alloc] initWithFrame:CGRectMake(20, 280, 150, 30)];
    [self.view addSubview:video2];
    video2.tag = 101;
    [video2 setTitle:@"视频2 30s播放" forState:UIControlStateNormal];
    [video2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [video2 addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
   
    UIButton *video3 = [[UIButton alloc] initWithFrame:CGRectMake(20, 330, 150, 30)];
    [self.view addSubview:video3];
    video3.tag = 102;
    [video3 setTitle:@"视频3 40s播放" forState:UIControlStateNormal];
    [video3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [video3 addTarget:self action:@selector(switchVideo:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)seekBtnClick {
    
    // 注意：1.续播用setWatchStartTime:跳到某个播放位置
    //      2.主动点击seek到某个位置，用setCurrentPlaybackTime:(播放中)
    [self.videoPlayer setCurrentPlaybackTime:30.0];
    
    //[self.videoPlayer play];   // 播放视频，如果设置setAutoplay为NO,须调用此方法
}


- (void)switchVideo:(UIButton *)button {
    switch (button.tag) {
        case 100: {
            self.currentVid = @"sl8da4jjbx1c8baed8a48212d735d905_s";        // 加密
            [self.videoPlayer setWatchStartTime:20.0];                      // 跳至20s
        }
            break;
        case 101: {
            self.currentVid = @"sl8da4jjbxe69c6942a7a737819660de_s";        // 加密
            [self.videoPlayer setWatchStartTime:30];                        // 跳至30s
            //[self.videoPlayer setAutoplay:NO];                            // 是否自动播放
        }
            break;
        case 102: {
            //[self.videoPlayer setAutoplay:YES];  // 如果之前设置自动播放为NO，此处须重新设置YES进行自动播放
            self.currentVid = @"sl8da4jjbx1db751c1820f564192800a_s";        // 非加密
            [self.videoPlayer setWatchStartTime:40];                        // 跳至40s
        }
            break;
        default:
            break;
    }
    [self.videoPlayer setVid:self.currentVid];
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
