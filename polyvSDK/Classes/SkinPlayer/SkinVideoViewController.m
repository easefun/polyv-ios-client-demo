//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//
#import "SkinVideoViewController.h"
#import "PolyvSettings.h"
#import "PLVMoviePlayerController.h"
#import "PvExam.h"
#import "PVDanmuManager.h"
#import "PvDanmuSendView.h"
#import "PvReportManager.h"
#import "PolyvUtil.h"
#import <Photos/Photos.h>

static NSString * const PLVAutoContinueKey = @"autoContinue";
const CGFloat PLVPanPrecision = 20;

static const CGFloat PLVPlayerAnimationInterval = 0.3;
//NSString *const PLVSkinVideoViewControllerVidAvailable = @"PLVSkinVideoViewControllerVidAvailable";

@interface SkinVideoViewController ()<PLVMoviePlayerDelegate, PvDanmuSendViewDelegate>

/// 播放控制视图
@property (nonatomic, strong) SkinVideoViewControllerView *videoControl;

@property (nonatomic, assign) BOOL keepNavigationBar;
@property (nonatomic, assign) CGRect originFrame;

@property (nonatomic, assign) BOOL danmuEnabled;
@property (nonatomic, strong) PVDanmuManager *danmuManager;
@property (nonatomic, strong) PvDanmuSendView *danmuSendView;
@property (nonatomic, assign) BOOL sendingDanmu;

@property (nonatomic, assign) BOOL volumeEnable;
@property (nonatomic, assign) NSString *headtitle;

/// 播放过程定时器
@property (nonatomic, strong) NSTimer *playbackTimer;


// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, panHandler) {
	panHandlerhorizontalPan, //横向移动
	panHandlerverticalPan    //纵向移动
};

/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) panHandler panHandler;

@end

@interface SkinVideoViewController (RotateFullScreen)
- (void)fullScreenAction:(UIButton *)sender;
- (void)backButtonAction;
- (void)addOrientationObserver;
- (void)removeOrientationObserver;
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation;
@end

@interface SkinVideoViewController (Gesture)<UIGestureRecognizerDelegate>

- (void)panHandler:(UIPanGestureRecognizer *)recognizer;

@end

@implementation SkinVideoViewController
{
	int _position;
	__weak UINavigationController *_navigationController;
	__weak UIViewController *_parentViewController;
	BOOL _isPrepared;
	
	BOOL _isSeeking;
	BOOL _isSwitching;  // 切换码率中
	
	NSMutableArray *_videoExams;
	NSMutableDictionary *_parsedSrt;
}

@dynamic fullscreen;

#pragma mark - property
- (SkinVideoViewControllerView *)videoControl {
	if (!_videoControl) {
		_videoControl = [[SkinVideoViewControllerView alloc] init];
		_videoControl.translatesAutoresizingMaskIntoConstraints = YES;
	}
	return _videoControl;
}

- (void)setFrame:(CGRect)frame {
	_frame = frame;
	[self.view setFrame:frame];
	[self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	[self.videoControl setNeedsLayout];
	[self.videoControl layoutIfNeeded];
}

- (void)setEnableExam:(BOOL)enableExam {
	_enableExam = enableExam;
	if (!self.getVid || !self.video.isInteractiveVideo) return;
	if (_enableExam) { // 开启问答
		//NSLog(@"开启问答");
		_videoExams = [PolyvSettings getVideoExams:self.vid];
		//清空答题纪录，下次观看也会重新弹出问题
		[self.videoControl.pvExamView resetExamHistory];
	} else { // 关闭问答
		//NSLog(@"关闭问答");
	}
}

/// 开启截图功能
- (void)setEnableSnapshot:(BOOL)enableSnapshot {
	_enableSnapshot = enableSnapshot;
	self.videoControl.enableSnapshot = enableSnapshot;
}

/// 开启弹幕功能
- (void)setEnableDanmuDisplay:(BOOL)enableDanmuDisplay {
	_enableDanmuDisplay = enableDanmuDisplay;
	
	if (!enableDanmuDisplay) {
		[self enableDanmu:NO];
	}
}

#pragma mark - dealloc & init
- (void)dealloc {
    [self cancelObserver];
	PLVDebugLog(@"%s", __FUNCTION__)
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super init]) {
		frame = CGRectMake(frame.origin.x, frame.origin.y + 20, frame.size.width, frame.size.height);
		self.frame = frame;
		self.originFrame = frame;
		[self.view addSubview:self.videoControl.subtitleLabel];
        [self.view addSubview:self.videoControl.indicator];
        [self.view addSubview:self.videoControl.indicatorView];
		[self.view addSubview:self.videoControl];
		self.videoControl.frame = self.view.bounds;
		
		self.view.backgroundColor = [UIColor blackColor];
		self.videoControl.closeButton.hidden = YES;
		[self.videoControl.indicatorView startAnimating];
		self.enableDanmuDisplay = YES;
		self.enableRateDisplay  = YES;
		[self configControlAction];
		//[self configObserver];
	}
	return self;
}

/// 主动销毁
- (void)cancel {
	[super cancel];
	[self cancelPlaybackTimer];
}

/// 主动销毁，在导航控制器中不会执行
- (void)dismiss {
	[self cancelPlaybackTimer];
	__weak typeof(self) weakSelf = self;
	[UIView animateWithDuration:PLVPlayerAnimationInterval animations:^{
		weakSelf.view.alpha = 0.0;
	} completion:^(BOOL finished) {
		[weakSelf.view removeFromSuperview];
		if (weakSelf.dimissCompleteBlock) {
			// 回调结束闭包
			weakSelf.dimissCompleteBlock();
		}
	}];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - public
- (void)fullscreen:(BOOL)enable {
	//	UIButton *sender = fullscreen ? self.videoControl.fullScreenButton : self.videoControl.shrinkScreenButton;
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	if (enable) { // 即将全屏
		if (orientation == UIInterfaceOrientationPortrait) {
			[self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
		}
	} else {
		if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) {
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		}
	}
//	if (orientation == UIInterfaceOrientationPortrait && enable)  {
//		[self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
//	}else if((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) && !enable) {
//		[self interfaceOrientation:UIInterfaceOrientationPortrait];
//	}else if(!enable) {
//		
//	}
}

/// 窗口模式
- (void)showInWindow {
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	if (!keyWindow) {
		keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
	}
	[keyWindow addSubview:self.view];
	self.view.alpha = 0.0;
	self.videoControl.closeButton.hidden = NO;
	self.videoControl.showInWindowMode = YES;
	self.videoControl.backButton.hidden = YES;
	[UIView animateWithDuration:PLVPlayerAnimationInterval animations:^{
		self.view.alpha = 1.0;
	} completion:^(BOOL finished) {}];
}

/// 保留导航栏
- (void)keepNavigationBar:(BOOL)keep {
	self.keepNavigationBar = keep;
	if (keep) {
		CGRect frame = self.view.frame;
		frame = CGRectMake(frame.origin.x, frame.origin.y - 20, frame.size.width, frame.size.height);
		self.view.frame = frame;
		self.originFrame = frame;
		[_navigationController setNavigationBarHidden:NO animated:NO];
		self.videoControl.backButton.hidden = YES;
	}
}

/// 启用弹幕
- (void)enableDanmu:(BOOL)enable {
	self.danmuEnabled  = enable;
	CGRect dmFrame;
	dmFrame = self.view.bounds;
	self.danmuManager = [[PVDanmuManager alloc] initWithFrame:dmFrame withVid:self.vid inView:self.view underView:self.videoControl durationTime:1];
	if(self.danmuEnabled) {
		[self.videoControl setDanmuButtonColor:[UIColor yellowColor]];
	} else {
		[self.videoControl setDanmuButtonColor:[UIColor whiteColor]];
	}
}

/// 设置播放器标题
- (void)setHeadTitle:(NSString *)headtitle {
	[self.videoControl setHeadTitle:headtitle];
}

- (void)setNavigationController:(UINavigationController *)navigationController {
	_navigationController = navigationController;
	if (!self.keepNavigationBar) {
		[_navigationController setNavigationBarHidden:YES animated:NO];
	}
}
- (void)setParentViewController:(UIViewController *)viewController {
	_parentViewController = viewController;
}

/// 设置播放器logo
- (void)setLogo:(UIImage *)image location:(int)location size:(CGSize)size alpha:(CGFloat)alpha {
	self.videoControl.logoImageView.image = image;
	self.videoControl.logoImageView.frame = CGRectMake(0, 0, size.width, size.height);
	self.videoControl.logoImageView.alpha = alpha;
	self.videoControl.logoPosition = location;
}

/// 发送跑马灯
- (void)rollInfo:(NSString *)info font:(UIFont *)font color:(UIColor *)color withDuration:(NSTimeInterval)duration {
	CGFloat width = self.frame.size.width;
	__block UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, 0, 0)];
	if (!font) {
		font = [UIFont systemFontOfSize:13];
	}
	if (color) {
		infoLabel.textColor = color;
	}
	infoLabel.font = font;
	infoLabel.text = info;
	[self.view addSubview:infoLabel];
	[infoLabel sizeToFit];
	[UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		infoLabel.transform = CGAffineTransformMakeTranslation(-width-infoLabel.bounds.size.width, 0);
	}completion:^(BOOL finished) {
		[infoLabel removeFromSuperview];
		infoLabel = nil;
	}];
}

// 自动续播，建议根据实际项目需求实现记录的存储
- (void)setAutoContinue:(BOOL)autoContinue {
	if (autoContinue) {
		_autoContinue = autoContinue;
		NSDictionary *autoContinueDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PLVAutoContinueKey];
		if (autoContinueDict) {
			double startTime = [autoContinueDict[self.vid] doubleValue];
			if (startTime > 0) {
				self.watchStartTime = startTime;
				//NSLog(@"start time = %f", self.watchStartTime);
			}
		}
	}
}

#pragma mark - observation

/// 注册监听
- (void)configObserver {
	super.delegate = self;
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	// 播放状态改变，可配合playbakcState属性获取具体状态
	[notificationCenter addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification)
							   name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
	// 媒体网络加载状态改变
	[notificationCenter addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification)
							   name:MPMoviePlayerLoadStateDidChangeNotification object:nil];

	// 播放时长可用
	[notificationCenter addObserver:self selector:@selector(onMPMovieDurationAvailableNotification)
							   name:MPMovieDurationAvailableNotification object:nil];
	// 媒体播放完成或用户手动退出, 具体原因通过MPMoviePlayerPlaybackDidFinishReasonUserInfoKey key值确定
	[notificationCenter addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification:)
							   name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
	// 视频就绪状态改变
	[notificationCenter addObserver:self selector:@selector(onMediaPlaybackIsPreparedToPlayDidChangeNotification)
							   name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
	
	[notificationCenter addObserver:self selector:@selector(onMPMoviePlayerNowPlayingMovieDidChangeNotification)
							   name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
	
	[self addOrientationObserver];
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
	pan.delegate = self;
	[self.view addGestureRecognizer:pan];
}

/// 移除监听
- (void)cancelObserver {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 播放资源变化
- (void)onMPMoviePlayerNowPlayingMovieDidChangeNotification {
	// 显示码率
	[self setBitRateButtonDisplay:self.currentLevel];
	// 本地视频不允许切换码率
	self.videoControl.bitRateButton.enabled = self.videoControl.routeLineButton.enabled = self.localVideoLevel == 0;
}
- (void)setBitRateButtonDisplay:(int)level {
	NSString *title = [NSString new];
	switch (level) {
		case 0: title = @"自动";
			break;
		case 1: title = @"流畅";
			break;
		case 2: title = @"高清";
			break;
		case 3: title = @"超清";
			break;
		default:
			break;
	}
	[self.videoControl.bitRateButton setTitle:title forState:UIControlStateNormal];
}

// 播放状态改变
- (void)onMPMoviePlayerPlaybackStateDidChangeNotification {
	[self syncPlayButtonState];
	if (self.playbackState == MPMoviePlaybackStatePlaying) {
		[self.videoControl.indicatorView stopAnimating];
		[self startPlaybackTimer];
		[self.videoControl autoFadeOutControlBar];
	} else {
		//[self stopPlaybackTimer];
		if (self.playbackState == MPMoviePlaybackStateStopped) {
			[self.videoControl animateShow];
		}
	}
}

// 网络加载状态改变
- (void)onMPMoviePlayerLoadStateDidChangeNotification {
	[self syncPlayButtonState];
	
	if (self.loadState & MPMovieLoadStateStalled) {
		[self.videoControl.indicatorView startAnimating];
		_isPrepared = NO;
	}
	if (self.loadState & MPMovieLoadStatePlaythroughOK) {
		[self.videoControl.indicatorView stopAnimating];
		_isPrepared = YES;
		_isSeeking = NO;
	} else {
		
	}
	if (self.loadState & MPMovieLoadStatePlayable) {
	}
}

/// 成功获取视频时长
- (void)onMPMovieDurationAvailableNotification {
	CGFloat duration = self.duration;
	self.videoControl.slider.progressMinimumValue = .0f;
	self.videoControl.slider.progressMaximumValue = duration;
}

// 做好播放准备后
- (void)onMediaPlaybackIsPreparedToPlayDidChangeNotification {
	if (_watchStartTime > 0 && _watchStartTime < self.duration) {
		self.currentPlaybackTime = _watchStartTime;
		[self setTimeLaWithTime:_watchStartTime duration:self.duration];
		_watchStartTime = -1;
	}
	_isSwitching = NO;
}

// 播放完成或退出
- (void)onMPMoviePlayerPlaybackDidFinishNotification:(NSNotification *)notification {
	[self.videoControl.indicatorView stopAnimating];
	[self syncPlayButtonState];
	
	MPMovieFinishReason finishReason = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
	
	if (self.autoContinue && finishReason != MPMovieFinishReasonPlaybackEnded) {
		NSMutableDictionary *autoContinueDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PLVAutoContinueKey].mutableCopy;
		if (!autoContinueDict) autoContinueDict = [NSMutableDictionary dictionary];
		autoContinueDict[self.vid] = @(self.currentPlaybackTime);
		[[NSUserDefaults standardUserDefaults] setObject:autoContinueDict forKey:PLVAutoContinueKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	switch (finishReason) {
		case MPMovieFinishReasonPlaybackEnded:{
			// 播放结束清除续播记录
			NSMutableDictionary *autoContinueDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PLVAutoContinueKey].mutableCopy;
			if (self.vid && autoContinueDict.count) {
				[autoContinueDict removeObjectForKey:self.vid];
				[[NSUserDefaults standardUserDefaults] setObject:autoContinueDict forKey:PLVAutoContinueKey];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
			
			// 结束回调
			self.isWatchCompleted = YES;
			if (self.watchCompletedBlock) {
				self.watchCompletedBlock();
			}
		}break;
		case MPMovieFinishReasonUserExited:{
			
		}break;
		case MPMovieFinishReasonPlaybackError:{
			NSError *playbackError = notification.userInfo[@"error"];
			NSString *errorMessage = playbackError ? playbackError.localizedDescription : @"playback failed without any given reason";
			NSLog(@"playback failed: %@", errorMessage);
			[PvReportManager reportError:[super getPid] uid:PolyvUserId vid:self.vid error:errorMessage param1:self.param1 param2:@"" param3:@"" param4:@"" param5:@"polyv-ios-sdk"];
		}break;
		default:{}break;
	}
}


#pragma mark - rewrite
- (void)play {
	[self.videoControl.indicatorView startAnimating];
	[super play];
}


#pragma mark - control action

/// 配置按钮事件
- (void)configControlAction {
	[self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDragInside];
	[self.videoControl.slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
	[self.videoControl.slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
	
	[self.videoControl.sendDanmuButton addTarget:self action:@selector(sendDanmuButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.shrinkScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.rateButton addTarget:self action:@selector(rateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.videoControl.backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.danmuButton addTarget:self action:@selector(danmuButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.snapshotButton addTarget:self action:@selector(snapshot) forControlEvents:UIControlEventTouchUpInside];
	
	[self.videoControl.bitRateButton addTarget:self action:@selector(bitRateButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.routeLineButton addTarget:self action:@selector(routeLineButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

// 播放
- (void)playButtonClick {
	if (self.playButtonClickBlock) {
		self.playButtonClickBlock();
	}
	
	[self play];
	self.videoControl.playButton.hidden = YES;
	self.videoControl.pauseButton.hidden = NO;
}
- (void)pauseButtonClick {
	if (self.pauseButtonClickBlock) {
		self.pauseButtonClickBlock();
	}
	[self pause];
	self.videoControl.playButton.hidden = NO;
	self.videoControl.pauseButton.hidden = YES;
}

// 进度滑块
- (void)progressSliderTouchBegan:(UISlider *)slider {
	_isSeeking = YES;
	[self pause];
	[self.videoControl cancelAutoFadeOutControlBar];
}
- (void)progressSliderValueChanged:(UISlider *)slider {
	double currentTime = floor(slider.value);
	double totalTime = floor(self.duration);
	[self setTimeLaWithTime:currentTime duration:totalTime];
}
- (void)progressSliderTouchEnded:(UISlider *)slider {
	[self.videoControl autoFadeOutControlBar];
	[self setCurrentPlaybackTime:floor(slider.value)];
	[self play];
}

// 倍速播放
- (void)rateButtonClick:(UIButton *)sender {
	sender.layer.borderColor = [[UIColor redColor] CGColor];
	[sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	static int counter = 0;
	counter ++;
	switch (counter) {
		case 1:{
			[sender setTitle:@"1.25X" forState:UIControlStateNormal];
			self.currentPlaybackRate = 1.25;
		}break;
		case 2:{
			[sender setTitle:@"1.5X" forState:UIControlStateNormal];
			self.currentPlaybackRate = 1.5;
		}break;
		case 3:{
			[sender setTitle:@"2X" forState:UIControlStateNormal];
			self.currentPlaybackRate = 2.0;
		}break;
		default:{
			counter = 0;
			sender.layer.borderColor = [[UIColor whiteColor] CGColor];
			[sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[sender setTitle:@"1X" forState:UIControlStateNormal];
			self.currentPlaybackRate = 1.0;
		}break;
	}
}

// 切换码率
- (void)bitRateButtonClick {
	if (self.videoControl.sideView.hidden) {
		self.videoControl.sideView.hidden = NO;
		[self.videoControl animateHide];
		
		// 创建码率列表
		NSMutableArray *buttons = [self.videoControl createBitRateButton:[super getLevel]];
		for (int i = 0; i < buttons.count; i++) {
			UIButton *_button = [buttons objectAtIndex:i];
			[_button addTarget:self action:@selector(bitRateViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
		}
	} else {
		self.videoControl.sideView.hidden = YES;
	}
}
- (void)bitRateViewButtonClick:(UIButton *)button {
	self.watchStartTime = [super currentPlaybackTime];
	_isSwitching = YES;         // 码率切换
	self.videoControl.sideView.hidden = YES;
	
	switch (button.tag) {
		case 0:
			[super switchLevel:0];
			[self.videoControl.bitRateButton setTitle:@"自动" forState:UIControlStateNormal];
			break;
		case 1:
			[super switchLevel:1];
			[self.videoControl.bitRateButton setTitle:@"流畅" forState:UIControlStateNormal];
			break;
		case 2:
			[super switchLevel:2];
			[self.videoControl.bitRateButton setTitle:@"高清" forState:UIControlStateNormal];
			break;
		case 3:
			[super switchLevel:3];
			[self.videoControl.bitRateButton setTitle:@"超清" forState:UIControlStateNormal];
			break;
		default:
			break;
	}
}

// 切换线路
- (void)routeLineButtonClick {
	if (self.videoControl.sideView.hidden) {
		self.videoControl.sideView.hidden = NO;
		[self.videoControl animateHide];
		
		// 创建线路列表
		NSArray *buttons = self.videoControl.createRouteLineButton;
		for (int i = 0; i < buttons.count; i++) {
			UIButton *_button = [buttons objectAtIndex:i];
			[_button addTarget:self action:@selector(routeLineClick:) forControlEvents:UIControlEventTouchUpInside];
		}
	} else {
		self.videoControl.sideView.hidden = YES;
	}
}
- (void)routeLineClick:(UIButton *)button {
	self.watchStartTime = [super currentPlaybackTime];
	switch (button.tag) {
		case 0:
			self.routeLine = PLVRouteLine01;
			[self.videoControl.indicator showMessage:@"切换到线路一"];
			[self.videoControl.routeLineButton setTitle:@"线路一" forState:UIControlStateNormal];
			break;
		case 1:
			self.routeLine = PLVRouteLine02;
			[self.videoControl.indicator showMessage:@"切换到线路二"];
			[self.videoControl.routeLineButton setTitle:@"线路二" forState:UIControlStateNormal];
			break;
		default:
			break;
	}
	_isSwitching = YES;
	self.videoControl.sideView.hidden = YES;
	
}

// 关闭
- (void)closeButtonClick {
	[self dismiss];
}

#pragma mark - PLVMoviePlayerDelegate
- (void)moviePlayer:(PLVMoviePlayerController *)player didLoadVideoInfo:(PvVideo *)video {
	// 维护状态
	_videoExams = nil;
	_parsedSrt = nil;
	
//	// 码率列表
//	NSMutableArray *buttons = [self.videoControl createBitRateButton:[super getLevel]];
//	for (int i = 0; i < buttons.count; i++) {
//		UIButton *_button = [buttons objectAtIndex:i];
//		[_button addTarget:self action:@selector(bitRateViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//	}
	
	// 问答
	[self setEnableExam:self.enableExam];
	
	// 字幕
	[self parseSubRip];
}

- (void)moviePlayerTeaserDidBegin:(PLVMoviePlayerController *)player {
	self.videoControl.hidden = YES;
}
- (void)moviePlayerTeaserDidEnd:(PLVMoviePlayerController *)player {
	self.videoControl.hidden = NO;
}

- (void)syncPlayButtonState {
	if (self.loadState & MPMovieLoadStatePlayable
		&& self.playbackState == MPMoviePlaybackStatePlaying) {
		self.videoControl.playButton.hidden = YES;
		self.videoControl.pauseButton.hidden = NO;
	} else {
		self.videoControl.playButton.hidden = NO;
		self.videoControl.pauseButton.hidden = YES;
	}
}


#pragma mark - subtitle
- (void)searchSubtitles {
	if (self.playbackState == MPMoviePlaybackStatePlaying) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K <= %f AND %K >= %f", @"from", self.currentPlaybackTime, @"to", self.currentPlaybackTime];
		
		NSArray *values = [_parsedSrt allValues];
		if ([values count] > 0) {
			NSArray *search = [values filteredArrayUsingPredicate:predicate];
			if ([search count] > 0) {
				NSDictionary *result =  [search objectAtIndex:0];
				NSString *text = [result objectForKey:@"text"];
				self.videoControl.subtitleLabel.text = text;
			} else {
				self.videoControl.subtitleLabel.text = @"";
			}
		}
	}
}
- (void)parseSubRip {
	_parsedSrt = [NSMutableDictionary new];
	
	NSString *val = nil;
	NSArray *values = [self.video.videoSrts allValues];
	
	if ([values count] != 0) {
		//暂时只选择第一条字幕
		val = [values objectAtIndex:0];
	}
	if (!val) {
		return;
	}
	NSString *string = [NSString stringWithContentsOfURL:[NSURL URLWithString:val] encoding:NSUTF8StringEncoding error:NULL];
	if (string == nil) {
		return;
	}
	
	string = [string stringByReplacingOccurrencesOfString:@"\n\r\n" withString:@"\n\n"];
	string = [string stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
	
	NSScanner *scanner = [NSScanner scannerWithString:string];
	
	while (![scanner isAtEnd])
	{
		@autoreleasepool
		{
			NSString *indexString;
			(void) [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&indexString];
			
			NSString *startString;
			(void) [scanner scanUpToString:@" --> " intoString:&startString];
			NSScanner *aScanner = [NSScanner scannerWithString:startString];
			
			NSTimeInterval h =  0.0;
			NSTimeInterval m =  0.0;
			NSTimeInterval s =  0.0;
			NSTimeInterval c =  0.0;
			
			[aScanner scanDouble:&h];
			[aScanner scanString:@":" intoString:NULL];
			[aScanner scanDouble:&m];
			[aScanner scanString:@":" intoString:NULL];
			
			[aScanner scanDouble:&s];
			[aScanner scanString:@"," intoString:NULL];
			[aScanner scanDouble:&c];
			double fromTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0);
			
			
			(void) [scanner scanString:@"-->" intoString:NULL];
			
			NSString *endString;
			(void) [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&endString];
			aScanner = [NSScanner scannerWithString:endString];
			[aScanner scanDouble:&h];
			[aScanner scanString:@":" intoString:NULL];
			[aScanner scanDouble:&m];
			[aScanner scanString:@":" intoString:NULL];
			
			[aScanner scanDouble:&s];
			[aScanner scanString:@"," intoString:NULL];
			[aScanner scanDouble:&c];
			double endTime = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0);
			
			NSString *textString = @"";
			// BEGIN EDIT
			(void) [scanner scanUpToString:@"\n\n" intoString:&textString];
			
			textString = [textString stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
			textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			// END EDIT
			
			NSMutableDictionary *dictionary = [NSMutableDictionary new];
			[dictionary setObject:[NSNumber numberWithDouble:fromTime] forKey:@"from"];
			[dictionary setObject:[NSNumber numberWithDouble:endTime] forKey:@"to"];
			[dictionary setObject:textString forKey:@"text"];
			
			
			
			[_parsedSrt setObject:dictionary forKey:indexString];
		}
	}
}

#pragma mark - snapshot
- (void)snapshot {
	// 请求图库权限
	PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
	switch (status) {
		case PHAuthorizationStatusNotDetermined:{
			// 请求权限
			[PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
				switch (status) {
					case PHAuthorizationStatusAuthorized:{
						NSLog(@"图库访问已授权");
					}break;
					default:{
						NSLog(@"未授权访问图库");
					}break;
				}
			}];
		}break;
		case PHAuthorizationStatusAuthorized:{
			NSLog(@"图库访问已授权");
		}break;
		case PHAuthorizationStatusDenied:
		case PHAuthorizationStatusRestricted:{
			NSLog(@"未授权访问图库");
		}break;
		default:{}break;
	}
	
	// 获取当前时长，并请求截图
	int currentTime = (int)self.currentPlaybackTime;
	int level = self.getLevel;
	if (!level) level = self.localVideoLevel;
	NSString *sign = [NSString stringWithFormat:@"%@%d%dpolyvsnapshot", self.vid, level, currentTime];
	NSString *urlStr = [NSString stringWithFormat:@"http://go.polyv.net/snapshot/videoimage.php?vid=%@&level=%d&second=%d&sign=%@", self.vid, level, currentTime, [PolyvUtil md5HexDigest:sign]];
	//NSLog(@"url = %@", urlStr);
	NSURL *url = [NSURL URLWithString:urlStr];
	[[[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			NSLog(@"request snapshot error: %@", error);
			return;
		}
		NSString *destinationPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
		[[NSFileManager defaultManager] moveItemAtPath:location.path toPath:destinationPath error:nil];
		UIImage *image = [UIImage imageWithContentsOfFile:destinationPath];
		UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	}] resume];
}

-  (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error == nil) {
		if (LOG_INFO) NSLog(@"截图保存成功");
		[self.videoControl.indicator showMessage:@"截图保存成功"];
	} else {
		if (LOG_INFO) NSLog(@"截图保存失败");
		[self.videoControl.indicator showMessage:@"截图保存失败"];
	}
}

- (void)setTimeLaWithTime:(double)currentTime duration:(double)duration {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.videoControl.timeLabel.text = [self timeStringWithTime:currentTime duration:duration];
	});
}

- (NSString *)timeStringWithTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
	return [NSString stringWithFormat:@"%@/%@", [self timeStringWithSeconds:currentTime], [self timeStringWithSeconds:duration]];
}
- (NSString *)timeStringWithSeconds:(NSTimeInterval)time {
	NSInteger minutes = (NSUInteger)time / 60;
	NSInteger seconds = (NSUInteger)time % 60;
	return [NSString stringWithFormat:@"%02zd:%02zd", minutes, seconds];
}

#pragma mark - timer

- (void)startPlaybackTimer {
    if (!_playbackTimer) {
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.playbackTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)cancelPlaybackTimer {
	[self.playbackTimer invalidate];
    self.playbackTimer = nil;
}

- (void)monitorVideoPlayback {
    [self trackBuffer];
	
	//NSString *playbackLog = [NSString stringWithFormat:@"seeking: %s, prepared: %s, switching: %s", _isSeeking?"YES":"NO", _isPrepared?"YES":"NO", _isSwitching?"YES":"NO"];
	//NSLog(@"%@", playbackLog);
	if (_isSeeking || !_isPrepared) return;
	if (_isSwitching) {     // 正在切换码率，return出去
		return;
	}
	
	double currentTime = self.currentPlaybackTime;
	double totalTime = self.duration;
	[self setTimeLaWithTime:currentTime duration:totalTime];
	self.videoControl.slider.progressValue = currentTime;
	
	[self searchSubtitles];
	if (self.danmuEnabled && !self.sendingDanmu) {
		[_danmuManager rollDanmu:currentTime];
	}
	
	if(self.enableExam) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		PvExam *examShouldShow;
		for(PvExam *exam in _videoExams) {
			if (exam.seconds < currentTime && ![[userDefaults stringForKey:[NSString stringWithFormat:@"exam_%@", exam.examId]] isEqualToString:@"Y"]) {
				//NSLog(@"%sYYY", __FUNCTION__);
				examShouldShow = exam;
				break;
			}
		}
		if (examShouldShow) {
			[self pause];
			[self showExam:examShouldShow];
		}
	}
}

- (void)showExam:(PvExam *)exam {
	[self cancelPlaybackTimer];
	[self.videoControl.pvExamView setExam:exam];
	__weak typeof(self)weakSelf = self;
	self.videoControl.pvExamView.closedBlock = ^(int seekto) {
		weakSelf.videoControl.pvExamView.hidden = YES;
		if (seekto!=-1) {
			[weakSelf setCurrentPlaybackTime:seekto];
		}
		
		[weakSelf play];
		[weakSelf startPlaybackTimer];
	};
	self.videoControl.pvExamView.hidden = NO;
}

- (void)trackBuffer {
	CGFloat buffer = (CGFloat)self.playableDuration/self.duration;
	if (!isnan(buffer)) {
		//        self.videoControl.progressView.progress = buffer;
		self.videoControl.slider.loadValue = buffer;
	}
}

// 弹幕
- (void)sendDanmuButtonClick {
	if (self.danmuSendView != nil) {
		self.danmuSendView = nil;
	}
	self.danmuSendView = [[PvDanmuSendView alloc] initWithFrame:self.view.bounds];
	//self.danmuSendView = [[QHDanmuSendView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:self.danmuSendView];
	self.danmuSendView.deleagte = self;
	[self.danmuSendView showAction:self.view];
	[super pause];
	[self.danmuManager pause];
	self.sendingDanmu = YES;
}

- (void)danmuButtonClick {
	if (self.danmuEnabled) {
		[self enableDanmu:false];
		self.videoControl.sendDanmuButton.hidden = YES;
	} else {
		[self enableDanmu:true];
		self.videoControl.sendDanmuButton.hidden = NO;
	}
}

#pragma mark - QHDanmuSendViewDelegate

- (void)sendDanmu:(PvDanmuSendView *)danmuSendV info:(NSString *)info {
	NSTimeInterval currentTime = [super currentPlaybackTime];
	[self.danmuManager sendDanmu:self.vid msg:info time:currentTime fontSize:24 fontMode:@"roll" fontColor:@"0xFFFFFF"];
	self.sendingDanmu = NO;
}

- (void)closeSendDanmu:(PvDanmuSendView *)danmuSendV {
	[super play];
}

@end




@implementation SkinVideoViewController (RotateFullScreen)
/// 旋转按钮事件
- (void)fullScreenAction:(UIButton *)sender {
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
	switch (interfaceOrientation) {
			
		case UIInterfaceOrientationPortraitUpsideDown:{ // 电池栏在下
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		} break;
		case UIInterfaceOrientationPortrait:{ // 电池栏在上
			[self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
		} break;
		case UIInterfaceOrientationLandscapeLeft:{ // 电池栏在右
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		} break;
		case UIInterfaceOrientationLandscapeRight:{ // 电池栏在左
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		} break;
		default:
			[self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
			break;
	}
}


/// 强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
	if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
		SEL selector = NSSelectorFromString(@"setOrientation:");
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
		[invocation setSelector:selector];
		[invocation setTarget:[UIDevice currentDevice]];
		int val = orientation;
		[invocation setArgument:&val atIndex:2];
		[invocation invoke];
	}
}

// 返回按钮事件
- (void)backButtonAction {
	if (self.isFullscreenMode) { // 全屏模式
		[self fullScreenAction:self.videoControl.shrinkScreenButton];
	} else { // 非全屏模式
		[self cancel];          // 清除定时器等操作
		if (_navigationController) {
			//NSLog(@"导航控制器");
			[_navigationController popViewControllerAnimated:YES];
			[_navigationController setNavigationBarHidden:NO animated:YES];
		}else if(_parentViewController) {
			//NSLog(@"present 控制器");
			[_parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (void)addOrientationObserver {
	UIDevice *device = [UIDevice currentDevice];
	[device beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
}

- (void)removeOrientationObserver {
	UIDevice *device = [UIDevice currentDevice];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)orientationChanged:(NSNotification *)note {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIInterfaceOrientationPortrait && self.isFullscreenMode) {
		[self shrinkScreenStyle];
	}else if((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) && !self.isFullscreenMode) {
		[self fullScreenStyle];
	}else if(!self.isFullscreenMode) {
		// [self fullScreenStyle];
	}
}

/// 全屏样式
- (void)fullScreenStyle {
	if (self.videoControl.showInWindowMode) { // 窗口模式
		[UIApplication sharedApplication].statusBarHidden = YES;
		__block UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//		self.originFrame = self.view.frame;
		CGFloat height = [[UIScreen mainScreen] bounds].size.width;
		CGFloat width = [[UIScreen mainScreen] bounds].size.height;
		CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);
		
		[UIView animateWithDuration:0.3f animations:^{
			self.frame = frame;
			self.view.frame = frame;
			if (orientation == UIInterfaceOrientationLandscapeLeft) {
				[self.view setTransform:CGAffineTransformIdentity];
				[self.view setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
			}else if (orientation == UIInterfaceOrientationLandscapeRight) {
				[self.view setTransform:CGAffineTransformIdentity];
				[self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
			}
		} completion:^(BOOL finished) {
			self.isFullscreenMode = YES;
			self.videoControl.fullScreenButton.hidden = YES;
			self.videoControl.shrinkScreenButton.hidden = NO;
		}];
	} else { // 视图模式
        CGRect frame = CGRectZero;
        frame = [self fullscreenFrame];
		self.frame = self.view.frame = frame;
		[self.videoControl changeToFullsreen];
		if (self.keepNavigationBar) {
			[_navigationController setNavigationBarHidden:YES];
			self.videoControl.backButton.hidden = NO;
		}
		self.videoControl.fullScreenButton.hidden = YES;
		self.videoControl.shrinkScreenButton.hidden = NO;
		
		if (self.danmuEnabled) {
			if (self.danmuManager) {
				[self.danmuManager resetDanmuWithFrame:self.view.frame];
				[self.danmuManager initStart];
			}
			self.videoControl.sendDanmuButton.hidden = NO;
		}
		
		self.videoControl.danmuButton.hidden = !self.enableDanmuDisplay;
		self.videoControl.rateButton.hidden = !self.enableRateDisplay;
		self.isFullscreenMode = YES;
	}
	if (self.fullscreenBlock) {
		self.fullscreenBlock();
	}
}

- (CGRect)fullscreenFrame {
    CGRect fullscreenFrame = [UIScreen mainScreen].bounds;
    CGSize fullscreenSize = fullscreenFrame.size;
    if (fullscreenSize.width < fullscreenSize.height) {
        CGFloat tmp = fullscreenSize.width;
        fullscreenSize.width = fullscreenSize.height;
        fullscreenSize.height = tmp;
    }
    fullscreenFrame.size = fullscreenSize;
    return fullscreenFrame;
}

/// 非全屏样式
- (void)shrinkScreenStyle {
	self.videoControl.snapshotButton.hidden = YES;
	if (self.videoControl.showInWindowMode) {
		[UIView animateWithDuration:0.3f animations:^{
			[self.view setTransform:CGAffineTransformIdentity];
			self.frame = self.originFrame;
			[UIApplication sharedApplication].statusBarHidden = NO;
		} completion:^(BOOL finished) {
			self.isFullscreenMode = NO;
			self.videoControl.fullScreenButton.hidden = NO;
			self.videoControl.shrinkScreenButton.hidden = YES;
		}];
	} else {
		[self.danmuSendView backAction];
		if (self.keepNavigationBar) {
			[_navigationController setNavigationBarHidden:NO];
			self.videoControl.backButton.hidden = YES;
		} else {
			_parentViewController.view.frame = _parentViewController.view.superview.bounds;
		}
		
		self.frame = self.originFrame;
		self.view.frame = self.originFrame;
		[self.videoControl changeToSmallsreen];
		self.videoControl.fullScreenButton.hidden = NO;
		self.videoControl.shrinkScreenButton.hidden = YES;
		if (self.danmuManager) {
			[self.danmuManager resetDanmuWithFrame:self.view.frame];
			[self.danmuManager initStart];
		}
		if (self.danmuEnabled) {
			self.videoControl.sendDanmuButton.hidden = YES;
		}
		self.isFullscreenMode = NO;
	}
	if (self.shrinkscreenBlock) {
		self.shrinkscreenBlock();
	}
}


@end



@implementation SkinVideoViewController (Gesture)

#pragma mark - 平移手势方法

- (void)panHandler:(UIPanGestureRecognizer *)recognizer {
	if (!self.videoControl.pvExamView.hidden) return;
	CGPoint offset = [recognizer translationInView:recognizer.view];
	
	//根据在view上Pan的位置，确定是调音量还是亮度
	CGPoint locationPoint = [recognizer locationInView:recognizer.view];
	
	// 我们要响应水平移动和垂直移动
	// 根据上次和本次移动的位置，算出一个速率的point
	//	CGPoint veloctyPoint = [recognizer velocityInView:recognizer.view];
	
	// 判断是垂直移动还是水平移动
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:{ // 开始移动
			CGFloat x = fabs(offset.x);
			CGFloat y = fabs(offset.y);
			if (x > y) { // 水平移动
				[self pauseButtonClick];
				self.panHandler           = panHandlerhorizontalPan;
				
			}
			else if (x < y) { // 垂直移动
				self.panHandler = panHandlerverticalPan;
				if (locationPoint.x > self.frame.size.width / 2) {
					self.volumeEnable = YES;
				} else {
					self.volumeEnable = NO;
				}
			}
			break;
		}
		case UIGestureRecognizerStateChanged:{
			switch (self.panHandler) {
				case panHandlerhorizontalPan:{
					[self horizontalPan:offset.x];
					break;
				}
				case panHandlerverticalPan:{
					[self verticalPan:offset.y];
					break;
				}
				default:
					break;
			}
			break;
		}
		case UIGestureRecognizerStateEnded:{ // 移动停止
			switch (self.panHandler) {
				case panHandlerhorizontalPan:{
					[self setCurrentPlaybackTime:floor([self getMoveToTime:offset.x])];
					[self play];
					break;
				}
				case panHandlerverticalPan:{ // 垂直移动结束后，把状态改为不再控制音量
					self.volumeEnable = NO;
					break;
				}
				default:
					break;
			}
			break;
		}
		default:
			break;
	}
}

#pragma mark - pan垂直移动的方法

- (void)verticalPan:(CGFloat)value {
	if (self.volumeEnable) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGFloat volume = [MPMusicPlayerController applicationMusicPlayer].volume;
        volume -= value / 10000;
        [MPMusicPlayerController applicationMusicPlayer].volume = volume;
#pragma clang diagnostic pop
	}else {
		[UIScreen mainScreen].brightness -= value / 10000;
	}
}

#pragma mark - pan水平移动的方法
- (CGFloat)getMoveToTime:(CGFloat)move {
	CGFloat current = self.currentPlaybackTime;
	CGFloat duration = self.duration;
	CGFloat moveToValue = move / PLVPanPrecision + current;
	if (moveToValue >= duration) {
		moveToValue = duration;
	}else if (moveToValue <= 0) {
		moveToValue = 0;
	}
	return moveToValue;
}

- (void)horizontalPan:(CGFloat)value {
	double currentTime = floor([self getMoveToTime:value]);
	double totalTime = floor(self.duration);
	[self setTimeLaWithTime:currentTime duration:totalTime];
	double minutesElapsed = floor(currentTime / 60.0);
	double secondsElapsed = fmod(currentTime, 60.0);
	NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
	if (currentTime <= 0.0 || currentTime >= totalTime) {
		timeElapsedString = @"到头啦！";
	}
	if (value < 0) {
		[self.videoControl.indicator forward:NO time:timeElapsedString];
	}
	else if (value > 0){
		[self.videoControl.indicator forward:YES time:timeElapsedString];
	}
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	CGPoint point = [touch locationInView:self.view];
    return !(point.y > self.frame.size.height-40);
}

@end
