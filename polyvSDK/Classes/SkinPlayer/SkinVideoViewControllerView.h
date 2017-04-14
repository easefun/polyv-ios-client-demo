//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PvExamView.h"
#import "PLVSlider.h"
#import "PLVIndicator.h"

/// 图标位置
typedef NS_ENUM(NSInteger, PvLogoLocation) {
	PvLogoLocationTopLeft = 0,
	PvLogoLocationTopRight = 1,
	PvLogoLocationBottomLeft = 2,
	PvLogoLocationBottomRight = 3
};

@interface SkinVideoViewControllerView : UIView

/// 顶部工具栏
@property (nonatomic, strong, readonly) UIView *topBar;
/// 底部工具栏
@property (nonatomic, strong, readonly) UIView *bottomBar;
/// 播放按钮
@property (nonatomic, strong, readonly) UIButton *playButton;
/// 暂停按钮
@property (nonatomic, strong, readonly) UIButton *pauseButton;
/// 返回按钮
@property (nonatomic, strong, readonly) UIButton *backButton;
/// 关闭按钮
@property (nonatomic, strong, readonly) UIButton *closeButton;
/// 全屏按钮
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
/// 小屏按钮
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
/// 码率切换按钮
@property (nonatomic, strong, readonly) UIButton *bitRateButton;
/// 码率列表
@property (nonatomic, strong, readonly) UIView *bitRateView;
/// 弹幕开启按钮
@property (nonatomic, strong, readonly) UIButton *danmuButton;
/// 发送弹幕按钮
@property (nonatomic, strong, readonly) UIButton *sendDanmuButton;
/// 变速按钮
@property (nonatomic, strong, readonly) UIButton *rateButton;
/// 截图按钮
@property (nonatomic, strong, readonly) UIButton *snapshotButton;
/// 启用截图功能
@property (nonatomic, assign) BOOL enableSnapshot;
/// 启用发送弹幕按钮
@property (nonatomic, assign) BOOL enableDanmuButton;
/// 进度滑块
@property (nonatomic, strong, readonly) PLVSlider *slider;
/// 手势滑动指示器
@property (nonatomic, strong, readonly) PLVIndicator *indicator;
/// 时间标签
@property (nonatomic, strong, readonly) UILabel *timeLabel;
/// 字幕
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;
/// 缓冲菊花
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;
/// 问答视图
@property (nonatomic, strong, readonly) PvExamView *pvExamView;
/// 窗口模式
@property (nonatomic, assign) BOOL showInWindowMode;
/// logo设置
@property (nonatomic, assign) PvLogoLocation logoPosition;
@property (nonatomic, strong) UIImageView *logoImageView;
/// 设置头标题
@property (nonatomic, copy) NSString *headTitle;

/// 渐变隐藏显示工具条
- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;
/// 创建码率按钮
- (NSMutableArray *)createBitRateButton:(int)dfnum;
/// 全屏/小屏时所进行的UI操作
- (void)changeToFullsreen;
- (void)changeToSmallsreen;
/// 设置弹幕按钮颜色
- (void)setDanmuButtonColor:(UIColor *)color;
/// 禁用播放控制
- (NSString *)videoImageName:(NSString *)name;
@end
