//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVMoviePlayerController.h"
#import "SkinVideoViewControllerView.h"

@interface SkinVideoViewController : PLVMoviePlayerController

/// 播放器销毁回调
@property (nonatomic, copy) void(^dimissCompleteBlock)(void);
/// 全屏回调
@property (nonatomic, copy) void(^fullscreenBlock)(void);
/// 退出全屏回调
@property (nonatomic, copy) void(^shrinkscreenBlock)(void);
/// 播放按钮点击回调
@property (nonatomic, copy) void(^playButtonClickBlock)(void);
/// 暂停按钮点击回调
@property (nonatomic, copy) void(^pauseButtonClickBlock)(void);
/// 观看结束回调
@property (nonatomic, copy) void(^watchCompletedBlock)(void);

@property (nonatomic, assign) CGRect frame;
/// 开始播放时间
@property (nonatomic, assign) NSTimeInterval watchStartTime;
@property (nonatomic, assign) BOOL autoContinue;         // 继续上一次的视频。如果设置为YES,视频将从上次播放停止的位置继续播放
@property (nonatomic, assign) BOOL isWatchCompleted;    // 播放是否完成

/// 是否显示弹幕按钮，默认显示
@property (nonatomic, assign) BOOL enableDanmuDisplay;
/// 是否显示播放速率按钮，默认显示
@property (nonatomic, assign) BOOL enableRateDisplay;
/// 问答开关，默认为关闭
@property (nonatomic, assign) BOOL enableExam;
/// 截图开关，默认为关闭
@property (nonatomic, assign) BOOL enableSnapshot;

/// 初始化
- (instancetype)initWithFrame:(CGRect)frame;
/// 窗口模式
- (void)showInWindow;

/// 启用弹幕
- (void)enableDanmu:(BOOL)enable;
/// 保留导航栏
- (void)keepNavigationBar:(BOOL)keep;
/// 设置播放器标题
- (void)setHeadTitle:(NSString *)headtitle;
- (void)setNavigationController:(UINavigationController *)navigationController;
- (void)setParentViewController:(UIViewController *)viewController;

/// 设置播放器logo
- (void)setLogo:(UIImage *)image location:(int)location size:(CGSize)size alpha:(CGFloat)alpha;
/// 注册监听
- (void)configObserver;
/// 移除监听
- (void)cancelObserver;
/// 销毁
- (void)cancel;
- (void)dismiss;

/// 发送跑马灯
- (void)rollInfo:(NSString *)info font:(UIFont *)font color:(UIColor *)color withDuration:(NSTimeInterval)duration;

// 自动续播，建议根据实际项目需求实现记录的存储
- (void)setAutoContinue:(BOOL)autoContinue;

// 监控播放器状态  刷新播放器状态(进度条、时间显示器等) 默认为自动调用
- (void)monitorVideoPlayback;

- (void)setFullscreen:(BOOL)fullscreen;

//额外参数，用来跟踪出错用户
- (void)setParam1:(NSString *)param1;

@end
