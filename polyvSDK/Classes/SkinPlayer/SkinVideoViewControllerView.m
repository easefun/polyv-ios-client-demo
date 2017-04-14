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
#import "PolyvSettings.h"

static const CGFloat pVideoControlBarHeight = 50.0;
static const CGFloat pVideoControlAnimationTimeinterval = 0.5;
static const CGFloat pVideoControlTimeLabelFontSize = 10.0;
static const CGFloat pVideoControlTitleLabelFontSize = 16.0;
static const CGFloat pVideoControlBarAutoFadeOutTimeinterval = 5.0;
static const CGFloat pVideoControlBarItemAlpha = 0.7;

@interface SkinVideoViewControllerView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *rateButton;
@property (nonatomic, strong) UIButton *danmuButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIView *bitRateView;
@property (nonatomic, strong) UIButton *sendDanmuButton;
@property (nonatomic, strong) PLVIndicator *indicator;
@property (nonatomic, strong) UIButton *snapshotButton;
@property (nonatomic, strong) PvExamView *pvExamView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) PLVSlider *slider;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *bitRateButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;

@property (nonatomic, strong) NSMutableArray *bitRateButtons;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, assign) int currentBitRate;
@property (nonatomic, assign) BOOL isFullscreenMode;

@end

@implementation SkinVideoViewControllerView

#pragma mark - init & dealloc
- (instancetype)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		[self addSubview:self.logoImageView];
		[self addSubview:self.contentView];
		
		[self.contentView addSubview:self.subtitleLabel];
		[self addSubview:self.bitRateView];
		
		// 顶部工具栏
		[self.contentView addSubview:self.topBar];
		[self.topBar addSubview:self.titleLabel];
		[self.topBar addSubview:self.backButton];
		[self.topBar addSubview:self.danmuButton];
		[self.topBar addSubview:self.rateButton];
		[self.topBar addSubview:self.closeButton];
		
		// 底部工具栏
		[self.contentView addSubview:self.bottomBar];
		[self.bottomBar addSubview:self.playButton];
		[self.bottomBar addSubview:self.pauseButton];
		self.pauseButton.hidden = YES;
		[self.bottomBar addSubview:self.slider];
		[self.bottomBar addSubview:self.timeLabel];
		[self.bottomBar addSubview:self.bitRateButton];
		[self.bottomBar addSubview:self.fullScreenButton];
		[self.bottomBar addSubview:self.shrinkScreenButton];
		self.shrinkScreenButton.hidden = YES;
		
		[self.contentView addSubview:self.sendDanmuButton];
		[self.contentView addSubview:self.indicator];
		[self.contentView addSubview:self.snapshotButton];
		
		[self.contentView addSubview:self.indicatorView];
		[self.indicatorView startAnimating];
		
		[self addSubview:self.pvExamView];
		self.pvExamView.hidden = YES;
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
		[self addGestureRecognizer:tapGesture];
	}
	return self;
}

- (void)dealloc{
	PLVDebugLog(@"%s", __FUNCTION__);
}

- (void)didMoveToSuperview{
	[super didMoveToSuperview];
	self.isBarShowing = YES;
}

#pragma mark - 外部接口
- (void)animateHide{
	if (!self.isBarShowing) return;
	[UIView animateWithDuration:pVideoControlAnimationTimeinterval animations:^{
//		self.topBar.alpha = 0.0;
//		self.bottomBar.alpha = 0.0;
//		self.sendDanmuButton.alpha = 0.0;
//		self.snapshotButton.alpha = 0.0;
		self.contentView.alpha = 0;
	} completion:^(BOOL finished) {
		self.isBarShowing = NO;
	}];
}

- (void)animateShow{
	if (self.isBarShowing) return;
	//	self.sendDanmuButton.hidden = self.snapshotButton.hidden = !_isFullscreenMode;
	[UIView animateWithDuration:pVideoControlAnimationTimeinterval animations:^{
//		self.topBar.alpha = 1.0;
//		self.bottomBar.alpha = 1.0;
//		if (_isFullscreenMode) {
//			self.sendDanmuButton.alpha = 1.0;
//			if(self.enableSnapshot) self.snapshotButton.alpha = 1.0;
//		}
		self.contentView.alpha = 1;
	} completion:^(BOOL finished) {
		self.isBarShowing = YES;
		[self autoFadeOutControlBar];
	}];
}

- (void)autoFadeOutControlBar{
	if (!self.isBarShowing) return;
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
	[self performSelector:@selector(animateHide) withObject:nil afterDelay:pVideoControlBarAutoFadeOutTimeinterval];
}

- (void)cancelAutoFadeOutControlBar{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

- (NSMutableArray *)createBitRateButton:(int)dfnum{
	[self.bitRateView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	self.bitRateButtons = [NSMutableArray new];
	
	for (int i = 0;i<=dfnum;i++) {
		UIButton *_button = [UIButton buttonWithType:UIButtonTypeSystem];
		_button.tintColor = [UIColor whiteColor];
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

- (void)changeToFullsreen{
	_topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:pVideoControlBarItemAlpha];
	_titleLabel.hidden = NO;
	self.rateButton.hidden = NO;
	_danmuButton.hidden = NO;
//	_sendDanmuButton.hidden = NO;
	if (self.enableSnapshot) self.snapshotButton.hidden = NO;
    if (self.enableDanmuButton) self.sendDanmuButton.hidden = NO;
	self.isFullscreenMode = YES;
}
- (void)changeToSmallsreen{
	_topBar.backgroundColor = [UIColor clearColor];
	_titleLabel.hidden = YES;
	_danmuButton.hidden = YES;
	self.rateButton.hidden = YES;
	self.sendDanmuButton.hidden = YES;
	self.snapshotButton.hidden = YES;
	self.isFullscreenMode = NO;
}

- (void)setDanmuButtonColor:(UIColor *)color{
	self.danmuButton.layer.borderColor = [color CGColor];
	[self.danmuButton setTitleColor:color forState:UIControlStateNormal];
}

#pragma mark - layoutSubviews
- (void)layoutSubviews{
	[super layoutSubviews];
	self.contentView.frame = self.bounds;
	// top bar
	self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), pVideoControlBarHeight);
	
	self.backButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.backButton.bounds), CGRectGetHeight(self.backButton.bounds));
	
	self.closeButton.frame = CGRectMake(CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.closeButton.bounds), CGRectGetMinX(self.topBar.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
	CGFloat titleLabelX = CGRectGetWidth(self.backButton.bounds);
	CGFloat titleLabelW = CGRectGetWidth(self.topBar.bounds) - titleLabelX - CGRectGetWidth(self.closeButton.bounds);
	self.titleLabel.frame = CGRectMake(titleLabelX, 0, titleLabelW, CGRectGetHeight(self.topBar.bounds));
	
	self.danmuButton.frame = CGRectMake(CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.closeButton.bounds) - CGRectGetWidth(self.danmuButton.bounds), (CGRectGetHeight(self.topBar.bounds) - CGRectGetHeight(self.danmuButton.bounds))/2, CGRectGetWidth(self.danmuButton.bounds), CGRectGetHeight(self.danmuButton.bounds));
	
	self.rateButton.frame = CGRectMake(CGRectGetWidth(self.topBar.bounds) - CGRectGetWidth(self.danmuButton.bounds) * 2 - CGRectGetWidth(self.rateButton.bounds) - 10 ,
									   (CGRectGetHeight(self.topBar.bounds) - CGRectGetHeight(self.rateButton.bounds))/2,
									   CGRectGetWidth(self.rateButton.bounds),
									   CGRectGetHeight(self.rateButton.bounds));
	
	
	self.sendDanmuButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.sendDanmuButton.bounds) - 20, (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.sendDanmuButton.bounds))/2, CGRectGetWidth(self.sendDanmuButton.bounds), CGRectGetHeight(self.sendDanmuButton.bounds));
	self.snapshotButton.frame = CGRectMake(20, (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.snapshotButton.bounds))/2, CGRectGetWidth(self.snapshotButton.bounds), CGRectGetHeight(self.snapshotButton.bounds));
	self.bitRateView.frame = CGRectMake(2*CGRectGetWidth(self.bounds)/3, CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds)/3 ,  CGRectGetHeight(self.bounds));
	self.subtitleLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
	self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	self.indicator.center = CGPointMake(self.center.x, self.center.y *.5);
	
	
	// bottom bar
	self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - pVideoControlBarHeight, CGRectGetWidth(self.bounds), pVideoControlBarHeight);
	
	self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
	self.pauseButton.frame = self.playButton.frame;
	
	self.bitRateButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds) - CGRectGetWidth(self.bitRateButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.bitRateButton.bounds)/2, CGRectGetWidth(self.bitRateButton.bounds), CGRectGetHeight(self.bitRateButton.bounds));
	
	self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
	self.shrinkScreenButton.frame = self.fullScreenButton.frame;
	
	self.slider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame),
									  CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.slider.bounds)/2,
									  CGRectGetMinX(self.bitRateButton.frame) - CGRectGetMaxX(self.playButton.frame),
									  CGRectGetHeight(self.slider.bounds));
	
	self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.slider.frame), CGRectGetHeight(self.bottomBar.bounds)-1 - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.slider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
	
	//logo 位置
	CGRect logoFrame = self.logoImageView.frame;
	switch (self.logoPosition) {
		case PvLogoLocationTopLeft: {
			logoFrame.origin = CGPointMake(0, 0);
			break;
		}
		case PvLogoLocationTopRight: {
			logoFrame.origin = CGPointMake(self.frame.size.width - logoFrame.size.width, 0);
			break;
		}
		case PvLogoLocationBottomLeft: {
			logoFrame.origin = CGPointMake(0, self.frame.size.height - logoFrame.size.height);
			break;
		}
		case PvLogoLocationBottomRight: {
			logoFrame.origin = CGPointMake(self.frame.size.width - logoFrame.size.width, self.frame.size.height - logoFrame.size.height);
			break;
		}
	}
	self.logoImageView.frame = logoFrame;
	self.pvExamView.frame = self.frame;
	//editContent.frame = self.sendDanmuButton.frame;
	[self arrangeBitRateButtons];
}


/// 排列码率按钮
- (void)arrangeBitRateButtons{
	int buttonWidth = 100;
	int buttonsize = (int)self.bitRateButtons.count*30;
	int initHeight =(CGRectGetHeight(self.bitRateView.bounds)-buttonsize)/2;
	
	if (self.bitRateButtons!=nil) {
		for (int i = 0; i < self.bitRateButtons.count; i++) {
			UIButton *_button = [self.bitRateButtons objectAtIndex:i];
			_button.bounds = CGRectMake(0, 0, pVideoControlBarHeight, 30);
			_button.frame = CGRectMake((CGRectGetWidth(self.bitRateView.bounds)-buttonWidth)/2, initHeight, buttonWidth, 30);
			initHeight+=30;
		}
	}
}

- (NSArray<UIButton *> *)createRouteLineButton{
	[self.bitRateView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	NSMutableArray *buttons = [NSMutableArray array];
	for (int i = 0; i < 2; i++) {
		UIButton *lineButton = [UIButton buttonWithType:UIButtonTypeSystem];
		lineButton.tintColor = [UIColor whiteColor];
		lineButton.titleLabel.font = [UIFont systemFontOfSize:14];
		[lineButton setTitle:[NSString stringWithFormat:@"线路 %zd", i+1] forState:UIControlStateNormal];
		[buttons addObject:lineButton];
	}
	return buttons;
}



#pragma touch events
- (void)onTap:(UITapGestureRecognizer *)gesture{
	self.bitRateView.hidden = YES;
	if (gesture.state == UIGestureRecognizerStateRecognized) {
		if (self.isBarShowing) {
			[self animateHide];
		} else {
			[self animateShow];
		}
	}
}



#pragma mark - 存取器
#pragma mark views
- (UIView *)contentView{
	if (!_contentView) {
		_contentView = [[UIView alloc] initWithFrame:self.bounds];
		_contentView.backgroundColor = [UIColor clearColor];
//		_contentView.backgroundColor = [UIColor redColor];
	}
	return _contentView;
}
#pragma mark top bar
- (UIView *)topBar{
	if (!_topBar) {
		_topBar = [UIView new];
		_topBar.backgroundColor = [UIColor clearColor];
//		_topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//		_topBar.hidden = YES;
	}
	return _topBar;
}

- (UIButton *)backButton{
	if (!_backButton) {
		_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_backButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-back"]] forState:UIControlStateNormal];
		_backButton.alpha = pVideoControlBarItemAlpha;
		_backButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _backButton;
}

- (UILabel *)titleLabel{
	if (!_titleLabel) {
		_titleLabel = [UILabel new];
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.font = [UIFont systemFontOfSize:pVideoControlTitleLabelFontSize];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.textAlignment = NSTextAlignmentLeft;
		[_timeLabel sizeToFit];
//		_titleLabel.bounds = CGRectMake(0, 0, pVideoControlTitleLabelFontSize, pVideoControlTitleLabelFontSize);
		// vm
		_titleLabel.hidden = YES;
	}
	return _titleLabel;
}

- (UIButton *)rateButton{
	if (!_rateButton) {
		_rateButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[_rateButton setTitle:@"1X" forState:UIControlStateNormal];
		_rateButton.tintColor = [UIColor whiteColor];
		_rateButton.titleLabel.font = [UIFont systemFontOfSize:14];
		[_rateButton.layer setMasksToBounds:YES];
		[_rateButton.layer setCornerRadius:3];
		[_rateButton.layer setBorderWidth:1.0];
		_rateButton.layer.borderColor = [[UIColor whiteColor] CGColor];
		_rateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		_rateButton.bounds = CGRectMake(0, 0, 50, 30);
		// vm
		_rateButton.hidden = YES;
	}
	return _rateButton;
}

- (UIButton *)danmuButton{
	if (!_danmuButton) {
		_danmuButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_danmuButton.tintColor = [UIColor whiteColor];
		[_danmuButton setTitle:@" 弹幕 " forState:UIControlStateNormal];
		_danmuButton.titleLabel.font = [UIFont systemFontOfSize:14];
		[_danmuButton.layer setMasksToBounds:YES];
		[_danmuButton.layer setCornerRadius:3];
		[_danmuButton.layer setBorderWidth:1.0];
		_danmuButton.layer.borderColor = [[UIColor whiteColor] CGColor];
		_danmuButton.bounds = CGRectMake(0, 0, 50, 30);
		// vm
		_danmuButton.hidden = YES;
	}
	return _danmuButton;
}

- (UIButton *)closeButton{
	if (!_closeButton) {
		_closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_closeButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-close"]] forState:UIControlStateNormal];
		_closeButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _closeButton;
}

#pragma mark masks
- (UIView *)bitRateView{
	if (!_bitRateView) {
		_bitRateView = [UIView new];
		_bitRateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:pVideoControlBarItemAlpha];
		_bitRateView.hidden = YES;
	}
	return _bitRateView;
}

- (UIButton *)sendDanmuButton{
	if (!_sendDanmuButton) {
		_sendDanmuButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_sendDanmuButton setImage:[UIImage imageNamed:@"pl-video-player-danmu.png"] forState:UIControlStateNormal];
		_sendDanmuButton.contentMode = UIViewContentModeScaleAspectFit;
		_sendDanmuButton.tintColor = [UIColor whiteColor];
		_sendDanmuButton.titleLabel.font = [UIFont systemFontOfSize:14];
		_sendDanmuButton.bounds = CGRectMake(0, 0, 44, 44);
		_sendDanmuButton.hidden = YES;
	}
	return _sendDanmuButton;
}

- (PLVIndicator *)indicator{
	if (!_indicator) {
		_indicator = [[PLVIndicator alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
		_indicator.alpha = 0;
	}
	return _indicator;
}

- (UIButton *)snapshotButton{
	if (!_snapshotButton) {
		_snapshotButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_snapshotButton setImage:[UIImage imageNamed:@"pl-video-player-snapshot"] forState:UIControlStateNormal];
		_snapshotButton.contentMode = UIViewContentModeScaleAspectFill;
		_snapshotButton.frame = CGRectMake(0, 0, 44, 44);
		_snapshotButton.alpha = pVideoControlBarItemAlpha;
		_snapshotButton.hidden = YES;
	}
	return _snapshotButton;
}

- (UILabel *)subtitleLabel{
	if (!_subtitleLabel) {
		_subtitleLabel = [SubTitleLabel new];
		_subtitleLabel.userInteractionEnabled = NO;
		_subtitleLabel.backgroundColor = [UIColor clearColor];
		_subtitleLabel.font = [UIFont systemFontOfSize:pVideoControlTitleLabelFontSize];
		_subtitleLabel.textColor = [UIColor whiteColor];
		_subtitleLabel.numberOfLines = 0;
		_subtitleLabel.textAlignment = NSTextAlignmentCenter;
		//_subtitleLabel.bounds = CGRectMake(0, 0, pVideoControlTitleLabelFontSize, pVideoControlTitleLabelFontSize);
		//_subtitleLabel.hidden = TRUE;
		_subtitleLabel.shadowColor = [UIColor blackColor];
		_subtitleLabel.shadowOffset = CGSizeMake(0, 1);
		[_subtitleLabel sizeToFit];
	}
	return _subtitleLabel;
}

- (UIActivityIndicatorView *)indicatorView{
	if (!_indicatorView) {
		_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		_indicatorView.hidesWhenStopped = YES;
	}
	return _indicatorView;
}

// X
//- (PvExamView *) pvExamView{
//	if (!_pvExamView) {
//		_pvExamView = [[PvExamView alloc] initWithFrame:self.frame];
//	}
//	return _pvExamView;
//}

#pragma mark bottom bar
- (UIView *)bottomBar{
	if (!_bottomBar) {
		_bottomBar = [UIView new];
		_bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:pVideoControlBarItemAlpha];
	}
	return _bottomBar;
}


- (UIButton *)playButton{
	if (!_playButton) {
		_playButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_playButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-play"]] forState:UIControlStateNormal];
		_playButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _playButton;
}

- (UIButton *)pauseButton{
	if (!_pauseButton) {
		_pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_pauseButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-pause"]] forState:UIControlStateNormal];
		_pauseButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _pauseButton;
}

- (PLVSlider *)slider{
	if (!_slider) {
		_slider = [[PLVSlider alloc] initWithFrame:CGRectMake(10, 10, 10, 10)];
		_slider.thumbImage = [UIImage imageNamed:[self videoImageName:@"pl-video-player-point"]];
	}
	return _slider;
}

- (UILabel *)timeLabel{
	if (!_timeLabel) {
		_timeLabel = [UILabel new];
		_timeLabel.userInteractionEnabled = NO;
		_timeLabel.backgroundColor = [UIColor clearColor];
		_timeLabel.font = [UIFont systemFontOfSize:pVideoControlTimeLabelFontSize];
		_timeLabel.textColor = [UIColor whiteColor];
		_timeLabel.textAlignment = NSTextAlignmentRight;
		_timeLabel.bounds = CGRectMake(0, 0, pVideoControlTimeLabelFontSize, pVideoControlTimeLabelFontSize);
	}
	return _timeLabel;
}

- (UIButton *)bitRateButton{
	if (!_bitRateButton) {
		_bitRateButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_bitRateButton.tintColor = [UIColor whiteColor];
		[_bitRateButton setTitle:@"自动" forState:UIControlStateNormal];
		_bitRateButton.titleLabel.font = [UIFont systemFontOfSize:14];
		_bitRateButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _bitRateButton;
}

- (UIButton *)fullScreenButton{
	if (!_fullScreenButton) {
		_fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_fullScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-fullscreen"]] forState:UIControlStateNormal];
		_fullScreenButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton{
	if (!_shrinkScreenButton) {
		_shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_shrinkScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"pl-video-player-shrinkscreen"]] forState:UIControlStateNormal];
		_shrinkScreenButton.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	}
	return _shrinkScreenButton;
}



- (UIImageView *)logoImageView{
	if (!_logoImageView) {
		_logoImageView = [[UIImageView alloc] init];
		_logoImageView.userInteractionEnabled = NO;
	}
//	[_logoImageView setAlpha:self.logoAlpha];
	//_logoImageView.bounds = CGRectMake(0, 0, pVideoControlBarHeight, pVideoControlBarHeight);
	return _logoImageView;
}



- (NSString *)videoImageName:(NSString *)name{
	return name;
}
- (void)setEnableDanmuButton:(BOOL)enableDanmuButton {
    _enableDanmuButton = enableDanmuButton;
    self.sendDanmuButton.hidden = YES;
}

- (void)setEnableSnapshot:(BOOL)enableSnapshot{
	_enableSnapshot = enableSnapshot;
	self.snapshotButton.hidden = YES;
}

- (void)setHeadTitle:(NSString *)headtitle{
	dispatch_async(dispatch_get_main_queue(), ^{
		self.titleLabel.text = headtitle;
	});
}

@end
