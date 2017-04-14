//
//  PolyvPlayerDemoViewController.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "PolyvPlayerDemoViewController.h"
#import "PLVMoviePlayerController.h"

#import "PvUrlSessionDownload.h"
#import "PolyvSettings.h"

@interface PolyvPlayerDemoViewController (){
    PvUrlSessionDownload *_downloader;
    NSString *_vid;
    UIImageView *_posterImageView;
}
    
@property (nonatomic, strong) PLVMoviePlayerController *videoPlayer;

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation PolyvPlayerDemoViewController

- (void)dealloc{
	[self.videoPlayer cancel];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad{
	_vid = @"sl8da4jjbxc5565c46961a6f88ca52e5_s";
	
	// 配置下载器
	_downloader = [[PvUrlSessionDownload alloc] initWithVid:_vid level:1];
	
	// 自动选择码率
	self.videoPlayer = [[PLVMoviePlayerController alloc] initWithVid:_vid];
	[self.view addSubview:self.videoPlayer.view];
	[self.videoPlayer.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 240)];
	
	// 设置播放器选项
	self.videoPlayer.shouldAutoplay = NO;
 
	// 设置播放器首图
	NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://v.polyv.net/uc/video/getImage?vid=%@", _vid]];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
		NSData *data0 = [NSData dataWithContentsOfURL:imageURL];
		UIImage *image = [UIImage imageWithData:data0];
		
		dispatch_sync(dispatch_get_main_queue(), ^(void) {
			UIImage *buttonImage = [UIImage imageNamed:@"video-play.png"];
			_posterImageView = [[UIImageView alloc] initWithImage:image];
			_posterImageView.contentMode = UIViewContentModeScaleAspectFit;
			_posterImageView.backgroundColor = [UIColor blackColor];
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
	
	// 监听播放器通知
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlayBackDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleBackgroundSession:)
												 name:PLVBackgroundSessionUpdateNotification
											   object:nil];
	
	[super viewDidLoad];
}

- (void)handleBackgroundSession:(NSNotification *)notification {
	// AppDelegate 执行 -application:handleEventsForBackgroundURLSession:completionHandler: 才把 block 属性赋值
	if ([notification.userInfo[PLVSessionIdKey] isEqualToString:_downloader.sessionId]) {
		_downloader.completeBlock = notification.userInfo[PLVBackgroundSessionCompletionHandlerKey];
	}
}
#pragma mark - 按钮事件
- (IBAction)closeAction:(id)sender {
	[self.videoPlayer stop];
	[self dismissViewControllerAnimated:YES completion:nil];
}
// 播放器操作
- (IBAction)seekAction:(id)sender {
    [self.videoPlayer setCurrentPlaybackTime:40];
}
- (IBAction)playAction:(id)sender {
    [self playButtonTap];
}
- (void)playButtonTap{
	if(self.videoPlayer.playbackState != MPMoviePlaybackStatePlaying && self.videoPlayer.playbackState!=MPMoviePlaybackStatePaused){
		[_posterImageView removeFromSuperview];
	}
	[self.videoPlayer play];
}
- (IBAction)pauseAction:(id)sender {
	[self.videoPlayer pause];
}
- (IBAction)fullscreenAction:(id)sender {
	[self.videoPlayer setFullscreen:YES animated:YES];
}
- (IBAction)switchVid:(id)sender {
	self.videoPlayer.vid = @"sl8da4jjbxe69c6942a7a737819660de_s";
}

// 下载器操作
- (IBAction)downloadAction:(id)sender {
	[_downloader setDownloadDelegate:self];
	[_downloader start];
}
- (IBAction)stopAction:(id)sender {
	[_downloader stop];
}
- (IBAction)deleteAction:(id)sender {
	// [VideoDownloader deleteVideo:_vid level:1];
	[PvUrlSessionDownload deleteVideo:_vid];
}

#pragma mark - 通知响应
- (void)moviePlayBackDidFinish:(NSNotification *)notification{
	//NSLog(@"moviePlayBackDidFinish");
	
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

#pragma download delegate
- (void)dataDownloadStop:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid{
    
}
- (void)downloadDidFinished:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid{
    NSLog(@"vid:%@", vid);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知"
                                                        message:@"视频下载完成"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}
- (void)dataDownloadFailed:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid reason:(NSString *)reason{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载失败"
                                                        message:reason
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent:(NSNumber *)percent{
    NSLog(@"%@", percent);
    dispatch_async(dispatch_get_main_queue(), ^{
		CGFloat progress = percent.floatValue;
        [self.progressLabel setText:[NSString stringWithFormat:@"%.02f%%", progress]];
		self.progressView.progress = progress / 100.0;
    });
    
    //_progressLabel.text=@"aaa";
}

- (BOOL)prefersStatusBarHidden{
	return YES;
}

#pragma mark - 页面旋转
- (BOOL)shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}
@end
