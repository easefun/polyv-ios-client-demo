//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//
#import "SkinVideoViewControllerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SubTitleLabel.h"

static const CGFloat pVideoControlBarHeight = 50.0;
static const CGFloat pVideoControlAnimationTimeinterval = 0.5;
static const CGFloat pVideoControlTimeLabelFontSize = 10.0;
static const CGFloat pVideoControlTitleLabelFontSize = 16.0;
static const CGFloat pVideoControlBarAutoFadeOutTimeinterval = 5.0;

enum PvLogoLocation {
    PvLogoLocationTopLeft = 0,
    PvLogoLocationTopRight = 1,
    PvLogoLocationBottomLeft = 2,
    PvLogoLocationBottomRight = 3
};

@interface SkinVideoViewControllerView ()

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIView *bitRateView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UIButton *bitRateButton;
@property (nonatomic, strong) UIButton *danmuButton;
@property (nonatomic, strong) UIButton *sendDanmuButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) PvExamView *pvExamView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) NSMutableArray *bitRateButtons;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, assign) int currentBitRate;
@property (nonatomic, assign) BOOL hideControl;


@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, assign) BOOL isFullscreenMode;



@end

@implementation SkinVideoViewControllerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.logoImageView];
        [self addSubview:self.subtitleLabel];

        [self addSubview:self.bitRateView];

        [self addSubview:self.topBar];
        [self.topBar addSubview:self.titleLabel];
        [self.topBar addSubview:self.backButton];
        //[self.topBar addSubview:self.danmuButton];

        [self.topBar addSubview:self.closeButton];
        
        //[self addSubview:self.sendDanmuButton];

        self.bitRateView.hidden = YES;

        [self addSubview:self.bottomBar];
        [self.bottomBar addSubview:self.playButton];
        [self.bottomBar addSubview:self.pauseButton];
        self.pauseButton.hidden = YES;
        [self.bottomBar addSubview:self.bitRateButton];
        [self.bottomBar addSubview:self.fullScreenButton];
        [self.bottomBar addSubview:self.shrinkScreenButton];
        self.shrinkScreenButton.hidden = YES;
        [self.bottomBar addSubview:self.progressView];
        [self.bottomBar addSubview:self.progressSlider];

        [self.bottomBar addSubview:self.timeLabel];
        [self addSubview:self.indicatorView];
        //self.sendDanmuButton.hidden = YES;
        
        
        //editContent = [[UITextField alloc] initWithFrame:CGRectMake(50, 50, 100, 20)];
        //[self addSubview:editContent];
        
        [self addSubview:self.pvExamView];
        self.pvExamView.hidden = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
        
        
       
        
        
    }
    return self;
}
- (void)disableControl:(BOOL)disabled{
    self.hideControl = disabled;
    self.isBarShowing = NO;
    if (disabled) {
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
        self.sendDanmuButton.alpha = 0.0;
    }else{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
        self.sendDanmuButton.alpha = 1.0;
    }
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), pVideoControlBarHeight);
    
    self.backButton.frame = CGRectMake(0, CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.backButton.bounds), CGRectGetHeight(self.backButton.bounds));
    self.titleLabel.frame = CGRectMake(CGRectGetWidth(self.backButton.bounds), CGRectGetMinX(self.topBar.bounds), 300, CGRectGetHeight(self.topBar.bounds));
    //NSLog(@"topBar: %@", NSStringFromCGRect(self.topBar.frame));

    //self.danmuButton.frame = CGRectMake(CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.closeButton.bounds) - CGRectGetWidth(self.danmuButton.bounds), (CGRectGetHeight(self.topBar.bounds) - CGRectGetHeight(self.danmuButton.bounds))/2, CGRectGetWidth(self.danmuButton.bounds), CGRectGetHeight(self.danmuButton.bounds));
    
    
    //self.sendDanmuButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.sendDanmuButton.bounds) - 20, (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.sendDanmuButton.bounds))/2, CGRectGetWidth(self.sendDanmuButton.bounds), CGRectGetHeight(self.sendDanmuButton.bounds));
    
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.closeButton.bounds), CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - pVideoControlBarHeight, CGRectGetWidth(self.bounds), pVideoControlBarHeight);
    self.bitRateView.frame = CGRectMake(2*CGRectGetWidth(self.bounds)/3, CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds)/3 ,  CGRectGetHeight(self.bounds));
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.pauseButton.frame = self.playButton.frame;
    
    self.bitRateButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds) - CGRectGetWidth(self.bitRateButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.bitRateButton.bounds)/2, CGRectGetWidth(self.bitRateButton.bounds), CGRectGetHeight(self.bitRateButton.bounds));
    
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    

    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.progressSlider.bounds)/2, CGRectGetMinX(self.bitRateButton.frame) - CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.progressSlider.bounds));
    //self.progressSlider.frame = CGRectMake(0, -17, CGRectGetWidth(self.bounds), CGRectGetHeight(self.progressSlider.bounds));
    
    self.progressView.frame = self.progressSlider.frame;
    self.progressView.center=self.progressSlider.center;

    
    self.subtitleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds)-1 - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    //logo 位置
    switch (_logoPosition) {
        case PvLogoLocationTopLeft:
            _logoImageView.frame = CGRectMake(0, 0, _logoSize.width,_logoSize.height);
            break;
        case PvLogoLocationTopRight:
            _logoImageView.frame = CGRectMake(self.frame.size.width-_logoSize.width, 0, _logoSize.width,_logoSize.height);
            break;
        case PvLogoLocationBottomLeft:
            _logoImageView.frame = CGRectMake(0, self.frame.size.height-_logoSize.height, _logoSize.width,_logoSize.height);
            break;
        default:
            _logoImageView.frame = CGRectMake(self.frame.size.width-_logoSize.width , self.frame.size.height-_logoSize.height, _logoSize.width, _logoSize.height);
            break;
    }
    self.pvExamView.frame = self.frame;
    //editContent.frame = self.sendDanmuButton.frame;
    [self arrangeBitRateButtons];
    
}
- (void)setHeadTitle:(NSString*)headtitle{
    [self.titleLabel setText:headtitle];
}
- (void)videoInfoLoaded:(NSDictionary*)videoInfo{
    
    
}
-(void)arrangeBitRateButtons{

    int buttonWidth = 100;
    int buttonsize = (int)self.bitRateButtons.count*30;
    int initHeight =(CGRectGetHeight(self.bitRateView.bounds)-buttonsize)/2;
    
    if (self.bitRateButtons!=nil) {
        for (int i=0; i<self.bitRateButtons.count; i++) {
            UIButton* _button = [self.bitRateButtons objectAtIndex:i];
            _button.bounds = CGRectMake(0, 0, pVideoControlBarHeight, 30);
            _button.frame = CGRectMake((CGRectGetWidth(self.bitRateView.bounds)-buttonWidth)/2, initHeight, buttonWidth, 30);
            initHeight+=30;
            
        }
    }
}
-(NSMutableArray*)createBitRateButton:(int)dfnum{

    [self.bitRateView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    self.bitRateButtons = [NSMutableArray new];

    for (int i=0;i<=dfnum;i++) {
        UIButton * _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.tag = i;
        switch (i) {
            case 0:
                [_button setTitle:@"自动" forState:UIControlStateNormal];
                break;
            case 1:
                [_button setTitle:@"流畅" forState:UIControlStateNormal];
                break;
            case 2:
                [_button setTitle:@"高清" forState:UIControlStateNormal];
                break;
            case 3:
                [_button setTitle:@"超清" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
        _button.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.bitRateButtons addObject:_button];
        [self.bitRateView addSubview:_button];
        //[_button addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];

    }
    [self arrangeBitRateButtons];
    return self.bitRateButtons;
    
}


- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}
- (void)setDanmuButtonColor:(UIColor*)color{
    self.danmuButton.layer.borderColor = [color CGColor];
    [self.danmuButton setTitleColor:color forState:UIControlStateNormal];



}
- (void)animateHide
{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:pVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
        self.sendDanmuButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
        
    }];
}

- (void)animateShow
{
    if (self.hideControl) {
        return;
    }
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:pVideoControlAnimationTimeinterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
        self.sendDanmuButton.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar
{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:pVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}
#pragma touch events
- (void)onTap:(UITapGestureRecognizer *)gesture
{
    self.bitRateView.hidden = YES;
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}


#pragma -
- (void)changeToFullsreen{
    _topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    
    _titleLabel.hidden = NO;
    _danmuButton.hidden = NO;
    _sendDanmuButton.hidden = YES;
    self.isFullscreenMode = YES;
    
}
- (void)changeToSmallsreen{
    _topBar.backgroundColor = [UIColor clearColor];
    _titleLabel.hidden = YES;
     _danmuButton.hidden = YES;
    self.isFullscreenMode = NO;
    self.sendDanmuButton.alpha = 0;
}



#pragma mark - Property

- (UIView *)topBar
{
    if (!_topBar) {
        _topBar = [UIView new];
        _topBar.backgroundColor = [UIColor clearColor];
        //_topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _topBar;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return _bottomBar;
}
- (UIView *)bitRateView
{
    if (!_bitRateView) {
        _bitRateView = [UIView new];
        _bitRateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return _bitRateView;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-play"]] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _playButton;
}

- (UIButton *)pauseButton
{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-pause"]] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _pauseButton;
}
- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-back"]] forState:UIControlStateNormal];
        _backButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _backButton;
}
- (UIButton *)danmuButton
{
    if (!_danmuButton) {
        _danmuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_danmuButton setTitle:@" 弹幕 " forState:UIControlStateNormal];
        _danmuButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_danmuButton.layer setMasksToBounds:YES];
        [_danmuButton.layer setCornerRadius:3];
        [_danmuButton.layer setBorderWidth:1.0];
        _danmuButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _danmuButton.bounds = CGRectMake(0, 0, 50, 30);
        _danmuButton.hidden = YES;
    }
    return _danmuButton;
}

-(PvExamView*) pvExamView{
    if (!_pvExamView) {
        _pvExamView = [[PvExamView alloc]initWithFrame:self.frame];
    }
    
    return _pvExamView;
    
    
}
- (UIButton *)sendDanmuButton
{
    if (!_sendDanmuButton) {
        _sendDanmuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendDanmuButton setTitle:@" 发射 " forState:UIControlStateNormal];
        _sendDanmuButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendDanmuButton.layer setMasksToBounds:YES];
        [_sendDanmuButton.layer setCornerRadius:10];
        [_sendDanmuButton.layer setBorderWidth:1.0];
        _sendDanmuButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _sendDanmuButton.bounds = CGRectMake(0, 0, 50, 50);
        //_sendDanmuButton.hidden = YES;
    }
    return _sendDanmuButton;
}

- (UIButton *)fullScreenButton
{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-fullscreen"]] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton
{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-shrinkscreen"]] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _shrinkScreenButton;
}
- (UIButton *)bitRateButton
{
    if (!_bitRateButton) {
        _bitRateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bitRateButton setTitle:@"自动" forState:UIControlStateNormal];
        _bitRateButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _bitRateButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _bitRateButton;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-point"]] forState:UIControlStateNormal];
        //[_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        UIColor * playedColor = [[UIColor alloc] initWithHue:229 saturation:40 brightness:75 alpha:1];
        [_progressSlider setMinimumTrackTintColor:playedColor];
        
        [_progressSlider setMaximumTrackTintColor:[UIColor clearColor]];//透明，以显示buffer
        //[_progressSlider setMaximumTrackTintColor:[UIColor lightGrayColor]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = NO;
    }
    return _progressSlider;
}
-(UIProgressView*)progressView
{
    if (!_progressView) {
        _progressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _progressView.progress=0;
        _progressView.trackTintColor=[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        _progressView.progressTintColor=[UIColor grayColor];
    }
    
    return _progressView;
    
    
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-close"]] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    }
    return _closeButton;
}

- (UIImageView *)logoImageView
{
    if (!_logoImageView) {
        
        _logoImageView = [[UIImageView alloc]initWithImage:_logoImage];
        
    }else{
        [_logoImageView setImage:_logoImage];
    }
        
    [_logoImageView setAlpha:self.logoAlpha];
    //_logoImageView.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
    return _logoImageView;
}

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:pVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, pVideoControlTimeLabelFontSize, pVideoControlTimeLabelFontSize);
    }
    return _timeLabel;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:pVideoControlTitleLabelFontSize];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.bounds = CGRectMake(0, 0, pVideoControlTitleLabelFontSize, pVideoControlTitleLabelFontSize);
        _titleLabel.hidden = TRUE;
        
    }
    return _titleLabel;
}
-(UILabel*)subtitleLabel{
    if (!_subtitleLabel) {
        _subtitleLabel = [SubTitleLabel new];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:pVideoControlTitleLabelFontSize];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        //_subtitleLabel.bounds = CGRectMake(0, 0, pVideoControlTitleLabelFontSize, pVideoControlTitleLabelFontSize);
        //_subtitleLabel.hidden = TRUE;
        _subtitleLabel.shadowColor = [UIColor blackColor];
        _subtitleLabel.shadowOffset = CGSizeMake(0,1);
        [_subtitleLabel sizeToFit];

    }
    return _subtitleLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}


- (NSString *)videoImageName:(NSString *)name
{
    
    return name;
}




@end
