//
//  PolyvPlayerDemoViewController.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "PolyvPlayerDemoViewController.h"
#import "PolyvPlayerViewController.h"
#import "DownloadHelper.h"
#import "Helper.h"
@interface PolyvPlayerDemoViewController (){
    
    PolyvPlayerViewController *player;
    int plausTime;
    NSString * vid;
    DownloadHelper* downloder;
    BOOL isfullscreen;
}

@end

@implementation PolyvPlayerDemoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)stopAction:(id)sender {
    
    
    [downloder cancel];
}
- (IBAction)deleteAction:(id)sender {
    
    
    [downloder deleteVideo];
}
/**
 点击播放按钮执行创建一个PolyvPlayerViewController实例，设置播放器大小为320x180，位置在左上角0，0坐标
 */
- (IBAction)playAction:(id)sender {
    //用vid初始化播放器
    player = [[PolyvPlayerViewController alloc] initWithVid:vid delegate:self];
    [player setFrame: CGRectMake(0, 0, 320, 180)];
    [player setPlayerControlStyle:MPMovieControlStyleDefault];
    [self.view addSubview:player.view];
    //启动播放器
    [player startPlayer];
}

/**
 播放器切换另外一个视频
 */
- (IBAction)switchVid:(id)sender {
    [player stopPlayer];
    [player changeVideo:@"sl8da4jjbx2d77fa6b3588b379f33289_s"];
    [player startPlayer];
}
/**
 暂停播放器
 **/
- (IBAction)pauseAction:(id)sender {
    [player pausePlayer];
}
/**
 启动下载器
 **/
- (IBAction)downloadAction:(id)sender {
    [downloder download];
}

/**
 播放本地视频，要事先下载好视频之后，如果本地文件不存在则无法播放
 [Helper getDownloadFilePath:vid]用vid获取到本地文件所在路径
 */
- (IBAction)playLocalAction:(id)sender {
    player = [[PolyvPlayerViewController alloc] initPlayerWithLocalPath:[Helper getDownloadFilePath:vid] encoded:YES delegate:self];
    NSLog(@"play local file:%@",[Helper getDownloadFilePath:vid]);
    
    
    [player setFrame: CGRectMake(0, 0, 320, 240)];
    [player setPlayerControlStyle:MPMovieControlStyleDefault];
    
    [self.view addSubview:player.view];
    
    [player startPlayer];

}
/**
 按了全屏按钮
 */

- (IBAction)fullscreenAction:(id)sender {
    [player setFullscreen:YES animated:YES];
}

- (IBAction)closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-(NSInteger)supportedInterfaceOrientations{
    
    if(isfullscreen){
        return UIInterfaceOrientationLandscapeLeft;

    }else{
        return UIInterfaceOrientationPortrait ;
    }
}*/




- (void)willEnterFullscreen:(NSNotification*)notification
{
    NSLog(@"willEnterFullscreen");
    
    isfullscreen = true;
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft]
                                forKey:@"orientation"];

    
}

- (void)willExitFullscreen:(NSNotification*)notification
{
    NSLog(@"willExitFullscreen");
    isfullscreen = false;
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];

}

/**
 初始化viewcontroller
 **/

- (void)viewDidLoad
{
    //演示用的vid
    
    vid = @"sl8da4jjbxa3c15f99bc37545693f7f9_s";
    
    //初始化下载器，encode为true，下载的视频到本地的时候做加密
    downloder = [[DownloadHelper alloc] initWithVid:vid encode:true delegate:self];
    //设置下载目录属性
    [downloder addSkipBackupAttributeToDownloadedVideos];
    //downloder.delegate = self;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterFullscreen:)
                                                 name:MPMoviePlayerWillEnterFullscreenNotification
                                               object:nil];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark PolyvPlayerDelegate
/**
 
 @abstract 播放器暂停后回调消息
 @discussion 检测播放器暂停状态时，回调此方法
 */

- (void)videoPlayerPaused{
    NSLog(@"videoPlayerPaused");
}

/**
 
 @abstract 播放器开始后回调消息
 @discussion 检测播放器开始播放状态时，回调此方法
 */
- (void)videoPlayerStarted{
    NSLog(@"videoPlayerStarted");
    //
}

/**
 
 @abstract 播放器停止后回调消息
 @discussion 检测播放器播放完毕状态时，回调此方法
 */
- (void)videoPlayerStopped{
    NSLog(@"videoPlayerStopped");
}

/**
 
 @abstract 播放器播放将要结束时回调消息
 @discussion 检测播放器将要结束状态时，回调此方法
 */
- (void)videoPlayerEnded{
    NSLog(@"videoPlayerEnded");
}

/**
 
 @abstract 播放器出现错误回调消息
 @discussion 检测播放器出现错误状态时，回调此方法
 */
- (void)videoPlayerError{
    NSLog(@"videoPlayerError");
    
}




#pragma mark -


#pragma mark DownloadHelperDelegate
- (void) downloadDidFinished: (NSString *) filepath{
    NSLog(@"downloadDidFinished:%@",filepath);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频下载完成" message:filepath delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [alert show];
}
- (void) didReceiveFilename: (NSString *) aName{
    NSLog(@"didReceiveFilename:%@",aName);
}
- (void) dataDownloadFailed: (NSString *) reason{
    NSLog(@"dataDownloadFailed:%@",reason);
}
- (void) dataDownloadAtPercent: (NSNumber *) aPercent{
    NSString *finalNumber = [NSString stringWithFormat:@"%.1f%%", [aPercent floatValue]*100];

     NSLog(@"dataDownloadAtPercent:%@",finalNumber);
}
#pragma mark -


-(NSInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
