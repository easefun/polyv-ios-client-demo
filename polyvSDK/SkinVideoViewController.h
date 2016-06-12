//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVMoviePlayerController.h"

enum PvLogoLocation {
    PvLogoLocationTopLeft = 0,
    PvLogoLocationTopRight = 1,
    PvLogoLocationBottomLeft = 2,
    PvLogoLocationBottomRight = 3
};

/*enum PvGestureType {
    PvUnknown = 0,
    PvBrightness,
    PvVoice,
    PvProgress
};*/

enum PvPlayMode {
    PvVideoMode = 0,
    PvTeaserMode = 1,
    PvAdMode = 2
};


//typedef enum PvGestureType PvGestureType;


@import MediaPlayer;

@interface SkinVideoViewController : PLVMoviePlayerController



@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, copy)void(^fullscreenBlock)(void);
@property (nonatomic, copy)void(^shrinkscreenBlock)(void);
@property (nonatomic, copy)void(^playButtonClickBlock)(void);
@property (nonatomic, copy)void(^pauseButtonClickBlock)(void);
@property (nonatomic, copy)void(^watchCompletedBlock)(void);
@property (nonatomic, assign) CGRect frame;
@property int watchVideoTimeDuration;
@property NSTimeInterval watchStartTime;
@property (nonatomic ,assign)BOOL autoplay;             // auto play video. 如果设置为NO, 初始化视频时将不会自动开始播放，默认为YES
@property (nonatomic, assign)BOOL autoContinue;         // 继续上一次的视频。如果设置为YES,视频将从上次播放停止的位置继续播放
@property (nonatomic, assign) BOOL isWatchCompleted;    // 播放是否完成

/// 问答开关，默认为关闭
@property (nonatomic, assign) BOOL enableExam;
/// 截图开关，默认为关闭
@property (nonatomic, assign) BOOL enableSnapshot;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;
- (void)setLocalMp4:(NSString*)vid level:(int)level __deprecated;
- (void)enableDanmu:(BOOL)enable;
- (void)enableTeaser:(BOOL)enable;
- (void)keepNavigationBar:(BOOL)keep;
- (void)setHeadTitle:(NSString*)headtitle;
- (void)setNavigationController:(UINavigationController*)navigationController;
- (void)setParentViewController:(UIViewController*)viewController;
- (void)stop;
- (void)setVid:(NSString*)vid;
- (void)setVid:(NSString*)vid level:(int)level;



//设置播放器logo
-(void)setLogo:(UIImage*)image location:(int)location size:(CGSize)size alpha:(CGFloat)alpha;
- (void)configObserver;
- (void)cancelObserver;
- (void)cancel;

//额外参数，用来跟踪出错用户
- (void)setParam1:(NSString*)param1;
// 发送跑马灯
-(void)rollInfo:(NSString *)info font:(UIFont *)font color:(UIColor *)color withDuration:(NSTimeInterval)duration;

- (void)setAutoContinue:(BOOL)autoContinue;

@end