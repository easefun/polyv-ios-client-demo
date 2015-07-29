//
//  PolyvPlayerDemoViewController.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "PolyvPlayerDemoViewController.h"
#import "PLVMoviePlayerController.h"

#import "VideoDownloader.h"
#import "DownloadDelegate.h"

@interface PolyvPlayerDemoViewController (){
    VideoDownloader*_downloader;
    NSString* _vid;
    UIImageView * _posterImageView;
    UIActivityIndicatorView * _indicatorView;
    int _position;
}
    
@property (nonatomic, strong) PLVMoviePlayerController *videoPlayer;

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
    [self play];
    
}


/**
 播放器切换另外一个视频
 */
- (IBAction)switchVid:(id)sender {
    [self.videoPlayer stop];
    [_indicatorView startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerLoadStateDidChange:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    
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
    
    [self.videoPlayer setFullscreen:YES animated:YES];
}

- (IBAction)closeAction:(id)sender {
    if(self.videoPlayer.playbackState == MPMoviePlaybackStatePlaying){
        [self.videoPlayer stop];
    }
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
        [_indicatorView stopAnimating];
        //[_indicatorView removeFromSuperview];
        // Remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        
        
        // Add movie player as subview
        //[[self view] addSubview:[moviePlayer view]];
        
        
        
        
    }
    
}
-(void) play{
    if(self.videoPlayer.playbackState != MPMoviePlaybackStatePlaying && self.videoPlayer.playbackState!=MPMoviePlaybackStatePaused){
        [_posterImageView removeFromSuperview];
        [_indicatorView startAnimating];
        
    }
    [self.videoPlayer play];
    
    
    
}
-(void)playButtonTap{
   
    [self play];

}


- (void)viewDidLoad
{

    _downloader = [[VideoDownloader alloc]init];
    _vid = @"sl8da4jjbx5aae533a50efd39a3d438e_s";
    
    //自动选择码率
    self.videoPlayer = [[PLVMoviePlayerController alloc]initWithVid:_vid level:1];
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer.view setFrame:CGRectMake(0,0,self.view.frame.size.width,240)];
 
    NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://v.polyv.net/uc/video/getImage?vid=%@",_vid]];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSData *data0 = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:data0];
        
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            
            UIImage * buttonImage = [UIImage imageNamed:@"video-play.png"];
             _posterImageView = [[UIImageView alloc] initWithImage:image];
            _posterImageView.userInteractionEnabled = YES;
            _posterImageView.frame = self.videoPlayer.view.frame;
            UIImageView *iButton = [[UIImageView alloc] initWithImage:buttonImage];
            iButton.frame = CGRectMake(_posterImageView.frame.size.width/2 - 30, _posterImageView.frame.size.height/2 -30, 60, 60);
            [_posterImageView addSubview:iButton];
            
            UITapGestureRecognizer *playTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playButtonTap)];
            
            
            [_posterImageView addGestureRecognizer:playTap];
            
            
            [self.view addSubview:_posterImageView];

        });
    });
    
    
    
   
    
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.videoPlayer.view.frame.size.width/2-10, self.videoPlayer.view.frame.size.height/2-10, 20, 20)];
    
    [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
    [self.view addSubview:_indicatorView];
    
    

    
    //self.videoPlayer = [[PLVMoviePlayerController alloc]initWithLocalMp4:_vid level:1];
    //NSLog(@"current bitrate:%d",[self.videoPlayer getLevel]);
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
      
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateDidChangeNotification:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)moviePlayerPlaybackStateDidChangeNotification:(NSNotification *)notification {
    switch (self.videoPlayer.playbackState) {
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
            break;
        
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dataDownloadFailed:(VideoDownloader*)downloader withVid:(NSString*)vid reason:(NSString *) reason{
    NSLog(@"%@",reason);
}

- (void) downloadDidFinished:(VideoDownloader*)downloader withVid: (NSString *) vid{
    
    NSLog(@"download fininshed");
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频下载完成" message:vid delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        [alert show];    });
    
    
}

- (void) dataDownloadAtPercent:(VideoDownloader*)downloader withVid:(NSString*)vid percent:(NSNumber *) percent{
    NSLog(@"%@",percent);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressLabel setText:[NSString stringWithFormat:@"%@%%",percent]];
    });
    
    //_progressLabel.text=@"aaa";
}


@end
