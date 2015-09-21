#import "SkinVideoViewController.h"
#import "SkinVideoViewControllerView.h"
#import "PolyvSettings.h"
#import "PLVMoviePlayerController.h"

static const CGFloat pVideoPlayerControllerAnimationTimeinterval = 0.3f;

@interface SkinVideoViewController ()

@property (nonatomic, strong) SkinVideoViewControllerView *videoControl;

@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) BOOL isBitRateViewShowing;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;



@end

@implementation SkinVideoViewController{
    int _levelNum;
    NSString* _pid;
    NSString*_vid;
    NSTimer *_pollPlayerTimer;
    int _watchTimeDuration;
    int _stayTimeDuration;
    int _position;
}




NSDictionary* _videoInfo;
int _seed;

- (void)dealloc
{
    [self cancelObserver];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControl];
        self.videoControl.frame = self.view.bounds;
        [self configObserver];
        [self configControlAction];
        self.videoControl.closeButton.hidden = YES;
    }
    return self;
}

#pragma mark - Override Method

- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    [self play];
}
- (void)setVid:(NSString *)vid
{
    [super setVid:vid];
    
}
#pragma mark - Publick Method

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
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)dismiss
{
    [self stopDurationTimer];
    [UIView animateWithDuration:pVideoPlayerControllerAnimationTimeinterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)configObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
}

- (void)cancelObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction
{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.bitRateButton addTarget:self action:@selector(bitRateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        [self startDurationTimer];
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
        if (_position>0) {
            [super setCurrentPlaybackTime:_position];
            _position = 0;
        }
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControl animateShow];
        }
        
    }
    NSMutableArray*buttons = [self.videoControl createBitRateButton:[super getLevel]];
    for (int i=0; i<buttons.count; i++) {
        UIButton*_button = [buttons objectAtIndex:i];
        [_button addTarget:self action:@selector(bitRateViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    
}
-(void)onMPMoviePlayerPlaybackDidFinishNotification{
    
    self.videoControl.progressSlider.value = self.duration;
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:totalTime totalTime:totalTime];
    
}
- (void)onMPMovieDurationAvailableNotification
{
    [self setProgressSliderMaxMinValues];
}
- (void)bitRateViewButtonClick:(UIButton *)button
{
    _position = [super currentPlaybackTime];
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
    [self play];
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)pauseButtonClick
{
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES;
}

- (void)closeButtonClick
{
    [self dismiss];
}
-(void)bitRateButtonClick
{
    if (!self.isBitRateViewShowing) {
        self.videoControl.bitRateView.hidden = NO;
        self.isBitRateViewShowing = YES;
        
    }else{
        self.videoControl.bitRateView.hidden = YES;
        self.isBitRateViewShowing = NO;
    }
    
    
}
- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
    }];
    
}

- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton.hidden = YES;
    }];
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = duration;
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback
{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
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

- (void)fadeDismissControl
{
    [self.videoControl animateHide];
}

#pragma mark - Property

- (SkinVideoViewControllerView *)videoControl
{
    if (!_videoControl) {
        _videoControl = [[SkinVideoViewControllerView alloc] init];
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
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}



@end

