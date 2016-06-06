//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//
#import "SkinVideoViewController.h"
#import "SkinVideoViewControllerView.h"
#import "PolyvSettings.h"
#import "PLVMoviePlayerController.h"
#import "PvExam.h"
#import "PVDanmuManager.h"
#import "PvDanmuSendView.h"
#import "PvReportManager.h"
#import <AVFoundation/AVFoundation.h>
//#import "PvExamView.h"
#define kPanPrecision 20

static const CGFloat pVideoPlayerControllerAnimationTimeinterval = 0.3f;
NSString * const PLVSkinVideoViewControllerVidAvailable = @"PLVSkinVideoViewControllerVidAvailable";

@interface SkinVideoViewController ()<PvDanmuSendViewDelegate>

@property (nonatomic, strong) SkinVideoViewControllerView *videoControl;

@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) BOOL keepNavigationBar;
@property (nonatomic, assign) BOOL isBitRateViewShowing;
@property (assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, strong) NSTimer *bufferTimer;

@property (nonatomic, assign) BOOL danmuEnabled;
@property (nonatomic, assign) BOOL teaserEnabled;
@property (nonatomic, strong) PVDanmuManager *danmuManager;
@property (nonatomic, strong) PvDanmuSendView *danmuSendV;

@property (nonatomic, assign) NSString* headtitle;
@property (nonatomic, assign) NSString* teaserURL;
@property (nonatomic, assign) NSURL* videoContentURL;
@property (nonatomic, assign) NSString* param1;


@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGFloat curPosition;
@property (nonatomic, assign) CGFloat curVoice;
@property (nonatomic, assign) CGFloat curBrightness;

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, assign) BOOL volumeEnable;

//@property (nonatomic, assign) PvGestureType gestureType;

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, panHandler){
	panHandlerhorizontalPan, //横向移动
	panHandlerverticalPan    //纵向移动
};

/** 定义一个实例变量，保存枚举值 */
@property (nonatomic, assign) panHandler     panHandler;

@end

@interface SkinVideoViewController (RotateFullScreen)
- (void)fullScreenAction:(UIButton *)sender;
- (void)backButtonAction;
- (void)addOrientationObserver;
- (void)removeOrientationObserver;
@end

@interface SkinVideoViewController (Gesture)<UIGestureRecognizerDelegate>

- (void)panHandler:(UIPanGestureRecognizer *)recognizer;

@end

@implementation SkinVideoViewController{
    int _position;
    UINavigationController* _navigationController;
    UIViewController *_parentViewController;
    BOOL _isPrepared;
    
    NSTimer *_stallTimer;
    NSDate* _firstLoadStartTime;
    NSDate* _secondLoadStartTime;
    BOOL _firstLoadTimeSent;
    BOOL _secondLoadTimeSent;
    BOOL _cancel;
	BOOL _isSeeking;
    NSTimer *_watchTimer;
    
    PvVideo * _pvVideo;
    int _pvPlayMode;
    
    NSMutableArray* _videoExams;
    NSMutableDictionary * _parsedSrt;
    
}

@synthesize watchVideoTimeDuration;
@synthesize watchStartTime;

- (void)setEnableExam:(BOOL)enableExam{
	_enableExam = enableExam;
//	NSLog(@"%s - vid = %@ - 是否可交互 = %d", __FUNCTION__, self.getVid, _pvVideo.isInteractiveVideo);
	if (!self.getVid || !_pvVideo.isInteractiveVideo) return;
	if (_enableExam) { // 开启问答
//		NSLog(@"开启问答");
		_videoExams = [PolyvSettings getVideoExams:self.getVid];
		//清空答题纪录，下次观看也会重新弹出问题
		[self.videoControl.pvExamView resetExamHistory];
	}else{ // 关闭问答
//		NSLog(@"关闭问答");
	}
}

-(void)play{
    [self.videoControl.indicatorView startAnimating];
    [super play];
}
-(void)stop{
    [self.videoControl.indicatorView stopAnimating];
    [super stop];
}
- (void)cancel{
//    NSLog(@"cancel");
    _cancel = YES;
    [super cancel];
	[self cancelObserver];
    [self stopBufferTimer];
    [self stopDurationTimer];
    [self stopCountWatchTime];
    [_watchTimer invalidate];
    [_bufferTimer invalidate];
    [_stallTimer invalidate];
    _durationTimer = nil;
    _watchTimer = nil;
    _bufferTimer = nil;
    _stallTimer = nil;
    [self.videoControl removeFromSuperview];
    _pvVideo = nil;
    self.videoControl = nil;
	self.videoContentURL = nil;
}


- (void)keepNavigationBar:(BOOL)keep{
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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        frame = CGRectMake(frame.origin.x, frame.origin.y + 20, frame.size.width, frame.size.height);
		[self setFrame:frame];
		
//		self.view.frame = frame;
		[self resetIfNeed];
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
        self.videoControl.closeButton.hidden = YES;
		self.originFrame = frame;
		[self configControlAction];
        self.autoplay = YES;
//		[self configObserver];
    }
    return self;
}

- (void)resetIfNeed{
	if (_durationTimer) {
		_durationTimer = nil;
	}
	if (_watchTimer) {
		_watchTimer = nil;
	}
	if (_bufferTimer) {
		_bufferTimer = nil;
	}
	if (_stallTimer) {
		_stallTimer = nil;
	}
	if (self.videoControl) {
		self.videoControl = nil;
	}
	self.watchVideoTimeDuration = 0;
}


#pragma mark - Override Method


- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    if(self.autoplay){
        [self play];
        
    }
    self.autoplay = YES;
}

- (void)setNavigationController:(UINavigationController*)navigationController{
    _navigationController = navigationController;
    if (!self.keepNavigationBar) {
        [_navigationController setNavigationBarHidden:YES animated:NO];
    }
}
- (void)setParentViewController:(UIViewController*)viewController{
    _parentViewController = viewController;
}



- (void)setLocalMp4:(NSString*)vid level:(int)level {
    NSString *plvPath = [[PolyvSettings sharedInstance] getDownloadDir];
    NSRange range = [vid rangeOfString:@"_"];
    if (range.location==NSNotFound) {
        return;
    }
    NSString*videoPoolId = [vid substringToIndex:range.location];
    
    NSString* localmp4 = [plvPath stringByAppendingString:[NSString stringWithFormat:@"/%@_%d.mp4",videoPoolId,level]];
    NSURL *contentURL = [NSURL fileURLWithPath:localmp4];
    [super setContentURL:contentURL];
    [self play];
}
- (void)setHeadTitle:(NSString*)headtitle{
    [self.videoControl setHeadTitle:headtitle];
}

- (void)setParam1:(NSString*)param1{
    self.param1 = param1;
}

#pragma mark - Public Method

- (void)showInWindow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:pVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    self.videoControl.closeButton.hidden = NO;
    self.videoControl.showInWindowMode = YES;
    self.videoControl.backButton.hidden = YES;
}

-(void)setLogo:(UIImage*)image location:(int)location size:(CGSize)size alpha:(CGFloat)alpha{
    [self.videoControl setLogoImage:image];
    [self.videoControl setLogoPosition:location];
    [self.videoControl setLogoSize:size];
    [self.videoControl setLogoAlpha:alpha];
    [self.videoControl logoImageView];
}

- (void)enableDanmu:(BOOL)enable{
    self.danmuEnabled  = enable;
	CGRect dmFrame;
	dmFrame = self.view.bounds;
	self.danmuManager = [[PVDanmuManager alloc] initWithFrame:dmFrame withVid:self.vid inView:self.view underView:self.videoControl durationTime:1];
    if(self.danmuEnabled){
        [self.videoControl setDanmuButtonColor:[UIColor yellowColor]];
    }else{
        [self.videoControl setDanmuButtonColor:[UIColor whiteColor]];
    }
}

- (void)enableTeaser:(BOOL)enable{
    self.teaserEnabled = enable;
}

- (void)dismiss
{
    [self stopDurationTimer];
    [self stopBufferTimer];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:pVideoPlayerControllerAnimationTimeinterval animations:^{
        weakSelf.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf.view removeFromSuperview];
        if (weakSelf.dimissCompleteBlock) {
            // 回调结束闭包
            weakSelf.dimissCompleteBlock();
        }
    }];
    [_watchTimer invalidate];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)configObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vidAvailable) name:PLVSkinVideoViewControllerVidAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoInfoLoaded) name:@"NotificationVideoInfoLoaded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didReceiveImage:)
												 name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
											   object:self];
	
	[self addOrientationObserver];
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandler:)];
	pan.delegate                = self;
	[self.view addGestureRecognizer:pan];
}

-(void)videoInfoLoaded{
    NSMutableArray*buttons = [self.videoControl createBitRateButton:[super getLevel]];
    for (int i=0; i<buttons.count; i++) {
        UIButton*_button = [buttons objectAtIndex:i];
        [_button addTarget:self action:@selector(bitRateViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.videoControl videoInfoLoaded:self.videoInfo];
}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self removeOrientationObserver];
}

- (void)configControlAction
{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.danmuButton addTarget:self action:@selector(danmuButtonClick) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.rateButton addTarget:self action:@selector(rateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.sendDanmuButton addTarget:self action:@selector(sendDanmuButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.bitRateButton addTarget:self action:@selector(bitRateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.videoControl.slider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged | UIControlEventTouchDragInside];
	[self.videoControl.slider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
	[self.videoControl.slider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
	[self.videoControl.snapshotButton addTarget:self action:@selector(snapshot) forControlEvents:UIControlEventTouchUpInside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

-(void)setVid:(NSString *)vid{
	_vid = vid;
    [self setVid:vid level:0];
}

- (void)setVid:(NSString*)vid level:(int)level{
	__weak typeof(self)weakSelf = self;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
		_pvVideo = [PolyvSettings getVideo:vid];
		[weakSelf parseSubRip];
//		NSLog(@"%s - vid = %@ - [super getVid] = %@", __FUNCTION__, weakSelf.vid, [super getVid]);
		dispatch_sync(dispatch_get_main_queue(), ^(void) {
			if (_cancel) {
				return;
			}
			if (_pvVideo.teaser_url!=nil && [_pvVideo.teaser_url hasSuffix:@"mp4"] && weakSelf.teaserEnabled && _pvVideo.teaserShow) {
				_pvPlayMode = PvTeaserMode;
				weakSelf.contentURL = [NSURL URLWithString:_pvVideo.teaser_url];
				[weakSelf.videoControl disableControl:YES];
			}else{
				[super stop];
				if (level==0) {
					[super setVid:vid];
				}else{
					[super setVid:vid level:level];
				}
			}

			[[NSNotificationCenter defaultCenter] postNotificationName:PLVSkinVideoViewControllerVidAvailable object:self];

		});
	});
}

- (void)vidAvailable{
//	NSLog(@"%s - vid = %@", __FUNCTION__, self.vid);
	[self stopCountWatchTime];
	self.watchVideoTimeDuration = 0;
	[self setEnableExam:self.enableExam];
	if(!(_pvVideo.seed == 1 || _pvVideo.fullmp4 == 1) && !self.enableSnapshot){
		self.videoControl.enableSnapshot = NO;
	}else{
		self.videoControl.enableSnapshot = YES;
	}
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
	[self syncPlayButtonState];
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        [self.videoControl.indicatorView stopAnimating];
        [self startDurationTimer];
        [self starBufferTimer];
        [self.videoControl autoFadeOutControlBar];

        [self startCountWatchTime];
        
    } else{
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
//			NSLog(@"%s - MPMoviePlaybackStateStopped", __FUNCTION__);
            [self.videoControl animateShow];
        }
        [self stopCountWatchTime];
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{

    [self syncPlayButtonState];
    
    if (self.watchStartTime>0 && _pvPlayMode == PvVideoMode && self.playbackState != MPMoviePlaybackStateStopped) {
        //NSLog(@"%f",self.watchStartTime);
        [self setCurrentPlaybackTime:self.watchStartTime];
        
        self.watchStartTime = -1;
    }
    
    if (self.loadState & MPMovieLoadStateStalled) {
        [self stopCountWatchTime];
        [self.videoControl.indicatorView startAnimating];
    }
    if (self.loadState & MPMovieLoadStatePlaythroughOK) {
        [self.videoControl.indicatorView stopAnimating];
        [self startCountWatchTime];
        _isPrepared = YES;
        
//		NSLog(@"MPMovieLoadStatePlaythroughOK");
	}else{
//		NSLog(@"state = %@", @(self.loadState));
	}
}

- (void)syncPlayButtonState{
    
    if (self.loadState & MPMovieLoadStatePlayable
        && self.loadState & MPMovieLoadStatePlayable
        && self.playbackState == MPMoviePlaybackStatePlaying
        && self.playbackState)
    {
        self.videoControl.playButton.hidden = YES;
        self.videoControl.pauseButton.hidden = NO;
    }else
    {
        self.videoControl.playButton.hidden = NO;
        self.videoControl.pauseButton.hidden = YES;
    }
}

-(void)searchSubtitles{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K <= %f AND %K >= %f", @"from", self.currentPlaybackTime, @"to",self.currentPlaybackTime];
        
        NSArray* values = [_parsedSrt allValues];
        if ([values count]>0) {
            NSArray*search = [values filteredArrayUsingPredicate:predicate];
            if ([search count]>0) {
                NSDictionary* result =  [search objectAtIndex:0];
                NSString* text = [result objectForKey:@"text"];
                self.videoControl.subtitleLabel.text = text;
            }else{
                self.videoControl.subtitleLabel.text = @"";
            }
        }
    }
}

-(void)parseSubRip{
    _parsedSrt = [NSMutableDictionary new];
    
    NSString * val = nil;
    NSArray *values = [_pvVideo.videoSrts allValues];
    
    if ([values count] != 0){
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
            
            NSString *textString;
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

-(void)startCountWatchTime{
    [_watchTimer invalidate];
    _watchTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                   target:self
                                                 selector:@selector(watchTimer_tick:)
                                                 userInfo:nil
                                                  repeats:YES];
}

-(void)stopCountWatchTime{
    [_watchTimer invalidate];
}

- (void) watchTimer_tick:(NSObject *)sender {
    self.watchVideoTimeDuration++;
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}

-(void)onMPMoviePlayerPlaybackDidFinishNotification:(NSNotification *)notification{
//	NSLog(@"%s", __FUNCTION__);
    
	[self.videoControl.indicatorView stopAnimating];
    if (_pvPlayMode == PvTeaserMode) {
         _pvPlayMode = PvVideoMode;
        [super setVid:_pvVideo.vid];
        [self.videoControl disableControl:NO];
		self.videoControl.slider.progressValue = 0;
        [self setTimeLabelValues:0 totalTime:0];
       
    }else{
		self.videoControl.slider.progressValue = self.duration;
        double totalTime = floor(self.duration);
        [self setTimeLabelValues:totalTime totalTime:totalTime];
        //====error report
        NSDictionary *notificationUserInfo = [notification userInfo];
        NSNumber *resultValue = [notificationUserInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
        
        MPMovieFinishReason reason = [resultValue intValue];
        
        if (fabs(self.duration-self.currentPlaybackTime) <1) {
            NSLog(@"观看完毕");
        }else{
            NSLog(@"没有看完视频");
        }
        if (reason == MPMovieFinishReasonPlaybackError)
        {
            NSError *mediaPlayerError = [notificationUserInfo objectForKey:@"error"];
            
            NSString*errorstring = @"";
            if (mediaPlayerError)
            {
                errorstring = [NSString stringWithFormat:@"%@",[mediaPlayerError localizedDescription]];
                
            }
            else
            {
                errorstring = @"playback failed without any given reason";
            }
            [PvReportManager reportError:[super getPid] uid:PolyvUserId vid:self.vid error:errorstring param1:self.param1 param2:@"" param3:@"" param4:@"" param5:@"polyv-ios-sdk"];
            
        }
        //NSLog(@"done");
        [self stopCountWatchTime];
    }
}

- (void)onMPMovieDurationAvailableNotification
{
    [self setProgressSliderMaxMinValues];
}

- (void)bitRateViewButtonClick:(UIButton *)button
{
    self.watchStartTime = [super currentPlaybackTime];
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

- (void)playButtonClick
{
    if (self.playButtonClickBlock) {
        self.playButtonClickBlock();
    }
    
    [self play];
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)pauseButtonClick
{
    if (self.pauseButtonClickBlock) {
        self.pauseButtonClickBlock();
    }
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
}

- (void)sendDanmuButtonClick{
    if (self.danmuSendV != nil) {
        self.danmuSendV = nil;
    }
    self.danmuSendV = [[PvDanmuSendView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.danmuSendV];
    self.danmuSendV.deleagte = self;
    [self.danmuSendV showAction:self.view];
    [super pause];
    [self.danmuManager pause];
}

- (void)danmuButtonClick{
    if (self.danmuEnabled) {
        [self enableDanmu:false];
        self.videoControl.sendDanmuButton.hidden=YES;
    }else{
        [self enableDanmu:true];
        self.videoControl.sendDanmuButton.hidden=NO;
    }
}

- (void)rateButtonClick:(UIButton *)sender{
//	NSLog(@"%s", __FUNCTION__);
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
 
- (void)closeButtonClick
{
    [self dismiss];
}

-(void)bitRateButtonClick
{
    if (!self.isBitRateViewShowing) {
        self.videoControl.bitRateView.hidden = NO;
        [self.videoControl animateHide];
        self.isBitRateViewShowing = YES;
        
    }else{
        self.videoControl.bitRateView.hidden = YES;
        self.isBitRateViewShowing = NO;
    }
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
	self.videoControl.slider.progressMinimumValue = .0f;
	self.videoControl.slider.progressMaximumValue = duration;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
//	[_stallTimer]
//	self.videoControl.timeLabel
}

- (void)progressSliderValueChanged:(UISlider *)slider {
	//	NSLog(@"slider: %f", slider.value);
	_isSeeking = YES;
	double currentTime = floor(slider.value);
	double totalTime = floor(self.duration);
	[self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
//	NSLog(@"%s", __FUNCTION__);
	[self.videoControl autoFadeOutControlBar];
	[self setCurrentPlaybackTime:floor(slider.value)];
	[self play];
	[self.videoControl.indicatorView stopAnimating];
	_isSeeking = NO;
}

- (void)snapshot{
	NSTimeInterval currentTime = self.currentPlaybackTime;
	[self requestThumbnailImagesAtTimes:@[@(currentTime)] timeOption:MPMovieTimeOptionNearestKeyFrame];
}

- (void)didReceiveImage:(NSNotification *)notification{
//	NSLog(@"notification = %@", notification);
	UIImage *image =[notification.userInfo objectForKey: @"MPMoviePlayerThumbnailImageKey"];
//	NSLog(@"image = %@", image);
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:),nil);
}

-  (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if (error == nil) {
		NSLog(@"截图保存成功");
		[self.videoControl.indicator showMessage:@"保存成功"];
	} else {
		NSLog(@"截图保存失败");
		[self.videoControl.indicator showMessage:@"保存失败"];
	}
}

-(void)showExam:(PvExam*)exam{
    [self.videoControl.pvExamView setExam:exam];
    __weak typeof(self)weakSelf = self;
    self.videoControl.pvExamView.closedBlock = ^(int seekto) {
        weakSelf.videoControl.pvExamView.hidden = YES;
        if (seekto!=-1) {
             //NSLog(@"%d",seekto);
            [weakSelf setCurrentPlaybackTime:seekto];
        }
       
        
        [weakSelf play];
    };
    self.videoControl.pvExamView.hidden = NO;
}

- (void)monitorVideoPlayback
{
	if (_isSeeking) YES;
	double currentTime = floor(self.currentPlaybackTime);
	double totalTime = floor(self.duration);
	[self setTimeLabelValues:currentTime totalTime:totalTime];
	self.videoControl.slider.progressValue = ceil(currentTime);
	
	
	[self searchSubtitles];
    if (self.danmuEnabled) {
		[_danmuManager rollDanmu:currentTime];
    }
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if(self.enableExam){
		PvExam * examShouldShow;
		for(PvExam* exam in _videoExams){
			if (exam.seconds<currentTime && ![[userDefaults stringForKey:[NSString stringWithFormat:@"exam_%@",exam.examId]] isEqualToString:@"Y"]) {
//				NSLog(@"%sYYY", __FUNCTION__);
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

-(void)trackBuffer{
    CGFloat buffer = (CGFloat)self.playableDuration/self.duration;
    if (!isnan(buffer)) {
//        self.videoControl.progressView.progress = buffer;
		self.videoControl.slider.loadValue = buffer;
    }
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    self.videoControl.timeLabel.text = [self getTimeLabelValues:currentTime totalTime:totalTime];
}

- (NSString *)getTimeLabelValues:(double)currentTime totalTime:(double)totalTime{
	double minutesElapsed = floor(currentTime / 60.0);
	double secondsElapsed = fmod(currentTime, 60.0);
	NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
	
	double minutesRemaining = floor(totalTime / 60.0);;
	double secondsRemaining = floor(fmod(totalTime, 60.0));;
	NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
	
	return [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

- (void)startDurationTimer
{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
}

- (void)starBufferTimer
{
    self.bufferTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(trackBuffer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopBufferTimer
{
    [self.bufferTimer invalidate];
}

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property
- (SkinVideoViewControllerView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[SkinVideoViewControllerView alloc] init];
		_videoControl.translatesAutoresizingMaskIntoConstraints = YES;
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView
{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame
{
	_frame = frame;
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}



#pragma mark - QHDanmuSendViewDelegate
- (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (void)sendDanmu:(PvDanmuSendView *)danmuSendV info:(NSString *)info {
    NSTimeInterval currentTime = [super currentPlaybackTime];
//	NSLog(@"info = %@", info);
    [self.danmuManager sendDanmu:self.vid msg:info time:[self timeFormatted:currentTime] fontSize:@"24" fontMode:@"roll" fontColor:@"0xFFFFFF"];
    [super play];
    
//    [self.danmuManager rollDanmu:0];
    //f=1 画框焦点
    [self.danmuManager insertDanmu:@{@"c":info, @"t":@"1", @"m":@"l",@"color":@"0xFFFFFF",@"f":@"1"}];
    [self.danmuManager resume:currentTime];

    
}

- (void)closeSendDanmu:(PvDanmuSendView *)danmuSendV {
    [super play];
    [self.danmuManager resume:[super currentPlaybackTime]];
}

-(void)rollInfo:(NSString *)info font:(UIFont *)font color:(UIColor *)color withDuration:(NSTimeInterval)duration{
//	NSLog(@"%s", __FUNCTION__);
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
					 }
	 ];
}

- (void)dealloc{

	NSLog(@"%s", __FUNCTION__);
}

@end




@implementation SkinVideoViewController (RotateFullScreen)
/// 旋转按钮事件
- (void)fullScreenAction:(UIButton *)sender{
//	NSLog(@"%s", __FUNCTION__);
	
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
	switch (interfaceOrientation) {
			
		case UIInterfaceOrientationPortraitUpsideDown:{ // 电池栏在下
//			NSLog(@"fullScreenAction第3个旋转方向---电池栏在下");
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		}
			break;
		case UIInterfaceOrientationPortrait:{ // 电池栏在上
//			NSLog(@"fullScreenAction第0个旋转方向---电池栏在上");
			[self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
		}
			break;
		case UIInterfaceOrientationLandscapeLeft:{ // 电池栏在右
//			NSLog(@"fullScreenAction第2个旋转方向---电池栏在右");
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		}
			break;
		case UIInterfaceOrientationLandscapeRight:{ // 电池栏在左
//			NSLog(@"fullScreenAction第1个旋转方向---电池栏在左");
			[self interfaceOrientation:UIInterfaceOrientationPortrait];
		}
			break;
			
		default:
			[self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
			break;
	}
	
//	if (self.videoControl.showInWindowMode) {
//		if (self.fullscreen) {
//			[self shrinkScreenStyle];
//		}else{
//			[self fullScreenStyle];
//		}
//	}
}


/// 强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation{
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
- (void)backButtonAction{
	if (self.isFullscreenMode) { // 全屏模式
		[self fullScreenAction:self.videoControl.shrinkScreenButton];
	}else{ // 非全屏模式
		if (_navigationController) {
//			NSLog(@"导航控制器");
			[_navigationController popViewControllerAnimated:YES];
			[_navigationController setNavigationBarHidden:NO animated:YES];
		}else if(_parentViewController){
//			NSLog(@"present 控制器");
			[_parentViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
		}
	}
}

- (void)addOrientationObserver{
	UIDevice *device = [UIDevice currentDevice];
	[device beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
//	NSLog(@"%s", __FUNCTION__);
}

- (void)removeOrientationObserver{
	UIDevice *device = [UIDevice currentDevice];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
}

- (void)orientationChanged:(NSNotification *)note{
//	NSLog(@"%s", __FUNCTION__);
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIInterfaceOrientationPortrait && self.isFullscreenMode) {
		// NSLog(@"竖屏");
		[self shrinkScreenStyle];
	}else if((orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft) && !self.isFullscreenMode){
		// NSLog(@"横屏");
		[self fullScreenStyle];
	}else if(!self.isFullscreenMode){
		// [self fullScreenStyle];
	}
}

/// 全屏样式
- (void)fullScreenStyle{
	if (self.videoControl.showInWindowMode) { // 窗口模式
		[UIApplication sharedApplication].statusBarHidden = YES;
		__block UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//		NSLog(@"show in window");
//		return;
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
			}else if (orientation == UIInterfaceOrientationLandscapeRight){
				[self.view setTransform:CGAffineTransformIdentity];
				[self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
			}
			
			
		} completion:^(BOOL finished) {
			self.isFullscreenMode = YES;
			self.videoControl.fullScreenButton.hidden = YES;
			self.videoControl.shrinkScreenButton.hidden = NO;
		}];
	}else{ // 视图模式
//		NSLog(@"视图模式");
//		self.originFrame = self.view.frame;
		_parentViewController.view.frame = _parentViewController.view.superview.bounds;
//		self.frame = self.view.superview.bounds;
//		self.view.frame =self.view.superview.bounds;
		CGRect frame = _parentViewController.view.frame;
		self.frame = self.view.frame = frame;
		self.isFullscreenMode = YES;
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
		if (self.fullscreenBlock) {
			self.fullscreenBlock();
		}
	}
}

/// 非全屏样式
- (void)shrinkScreenStyle{
	if (self.videoControl.showInWindowMode) {
//		NSLog(@"show in window");
//		return;
		[UIView animateWithDuration:0.3f animations:^{
			[self.view setTransform:CGAffineTransformIdentity];
			self.frame = self.originFrame;
			[UIApplication sharedApplication].statusBarHidden = NO;
		} completion:^(BOOL finished) {
			self.isFullscreenMode = NO;
			self.videoControl.fullScreenButton.hidden = NO;
			self.videoControl.shrinkScreenButton.hidden = YES;
		}];
	}else{
//		NSLog(@"%s - show in view", __FUNCTION__);
		[self.danmuSendV backAction];
		if (self.keepNavigationBar) {
			[_navigationController setNavigationBarHidden:NO];
			self.videoControl.backButton.hidden = YES;
		}else{
			_parentViewController.view.frame = _parentViewController.view.superview.bounds;
		}
		
		self.frame = self.originFrame;
//		NSLog(@"self.originFrame = %@", NSStringFromCGRect(self.originFrame));
		self.view.frame = self.originFrame;
		self.isFullscreenMode = NO;
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
		if (self.shrinkscreenBlock) {
			self.shrinkscreenBlock();
		}
	}
}


@end



@implementation SkinVideoViewController (Gesture)

#pragma mark - 平移手势方法

- (void)panHandler:(UIPanGestureRecognizer *)recognizer{
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
			else if (x < y){ // 垂直移动
				self.panHandler = panHandlerverticalPan;
				if (locationPoint.x > self.frame.size.width / 2) {
					self.volumeEnable = YES;
				}else {
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
				case panHandlerverticalPan:{
					// 垂直移动结束后，把状态改为不再控制音量
					self.volumeEnable = NO;
//					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//						self.horizontalLabel.hidden = YES;
//					});
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

- (void)verticalPan:(CGFloat)value{
	if (self.volumeEnable) {
		CGFloat volume = [[MPMusicPlayerController applicationMusicPlayer] volume];
		volume -= value / 10000;
		[[MPMusicPlayerController applicationMusicPlayer] setVolume:volume];
	}else {
		[UIScreen mainScreen].brightness -= value / 10000;
	}
}

#pragma mark - pan水平移动的方法
- (CGFloat)getMoveToTime:(CGFloat)move{
	CGFloat current = self.currentPlaybackTime;
	CGFloat duration = self.duration;
	CGFloat moveToValue = move / kPanPrecision + current;
	if (moveToValue >= duration) {
		moveToValue = duration;
	}else if (moveToValue <= 0){
		moveToValue = 0;
	}
	return moveToValue;
}

- (void)horizontalPan:(CGFloat)value{
	double currentTime = floor([self getMoveToTime:value]);
	double totalTime = floor(self.duration);
	[self setTimeLabelValues:currentTime totalTime:totalTime];
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	CGPoint point = [touch locationInView:self.view];
	if ((point.y > self.frame.size.height-40)) {
		return NO;
	}
	return YES;
}

@end
