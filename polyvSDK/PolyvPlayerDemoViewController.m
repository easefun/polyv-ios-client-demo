//
//  PolyvPlayerDemoViewController.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "PolyvPlayerDemoViewController.h"
#import "MPMoviePlayerController+plv.h"

#import "M3U8Downloader.h"
#import "DownloadDelegate.h"

@interface PolyvPlayerDemoViewController (){
    M3U8Downloader*_downloader;
    NSString* _vid;
}
    
@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;


@end

@implementation PolyvPlayerDemoViewController

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    NSLog(@"moviePlayBackDidFinish");
    
    NSDictionary *notificationUserInfo = [notification userInfo];
    NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    MPMovieFinishReason reason = [resultValue intValue];
    if (reason == MPMovieFinishReasonPlaybackError)
    {
        NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
        if (mediaPlayerError)
        {
            NSLog(@"playback failed with error description: %@", [mediaPlayerError localizedDescription]);
        }
        else
        {
            NSLog(@"playback failed without any given reason");
        }
    }
    
    // Remove observer
    [[NSNotificationCenter 	defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:nil];
    
}



- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)stopAction:(id)sender {
    [_downloader stop];
    
 }
- (IBAction)deleteAction:(id)sender {
    [_downloader deleteVideo:_vid level:1];
    
 
}
/**
 点击播放按钮执行创建一个PolyvPlayerViewController实例，设置播放器大小为320x180，位置在左上角0，0坐标
 */
- (IBAction)playAction:(id)sender {
    [self.videoPlayer play];
}

/**
 播放器切换另外一个视频
 */
- (IBAction)switchVid:(id)sender {
    [self.videoPlayer stop];
    [self.videoPlayer setVid:@"sl8da4jjbx5d715bc3a8ce8f8194afab_s"];
    [self.videoPlayer play];
}
/**
 暂停播放器
 **/
- (IBAction)pauseAction:(id)sender {
    [self.videoPlayer pause];
}
/**
 启动下载器
 **/
- (IBAction)downloadAction:(id)sender {
    [_downloader setDownloadDelegate:self];
    [_downloader start:_vid level:1];
}

/**
 按了全屏按钮
 */

- (IBAction)fullscreenAction:(id)sender {
    
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



- (void) playerLoadStateDidChange:(NSNotification*)notification
{
    
    
    MPMoviePlayerController *moviePlayer = [notification object];
    
    
    if ([moviePlayer loadState] != MPMovieLoadStateUnknown) {
        NSLog(@"playerReady");
        // Remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        
        
        // Add movie player as subview
        //[[self view] addSubview:[moviePlayer view]];
        
        
        
        
    }
    
}

- (void)viewDidLoad
{

    _downloader = [[M3U8Downloader alloc]init];
    _vid = @"sl8da4jjbx811f5fe77c6a056d660e8e_s";
    
    //自动选择码率
    self.videoPlayer = [[MPMoviePlayerController alloc]initWithVid:_vid];
    //播放流畅码率
    //self.videoPlayer = [[MPMoviePlayerController alloc]initWithVid:vid level:1];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer.view setFrame:CGRectMake(0,0,self.view.frame.size.width,240)];
    
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadDidFinished: (NSString *) vid{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频下载完成" message:vid delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [alert show];
    
    
    
}

- (void) dataDownloadAtPercent: (NSNumber *) percent{
    NSLog(@"%@",percent);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressLabel setText:[NSString stringWithFormat:@"%@%%",percent]];
    });
    
    //_progressLabel.text=@"aaa";
}


@end
