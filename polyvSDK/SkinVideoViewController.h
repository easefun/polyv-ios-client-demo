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
@property (nonatomic, assign) CGRect frame;
@property int watchVideoTimeDuration;
@property int watchStartTime;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;
- (void)setLocalMp4:(NSString*)vid level:(int)level __deprecated;
//- (void)enableDanmu:(BOOL)enable;
- (void)enableTeaser:(BOOL)enable;
- (void)keepNavigationBar:(BOOL)keep;
- (void)setHeadTitle:(NSString*)headtitle;
- (void)setNavigationController:(UINavigationController*)navigationController;
- (void)setParentViewController:(UIViewController*)viewController;
-(void)stop;
- (void)setVid:(NSString*)vid;
- (void)setVid:(NSString*)vid level:(int)level;
//设置播放器logo
-(void)setLogo:(UIImage*)image location:(int)location size:(CGSize)size alpha:(CGFloat)alpha;
- (void)configObserver;
- (void)cancelObserver;
- (void)cancel;

//额外参数，用来跟踪出错用户
- (void)setParam1:(NSString*)param1;
@end