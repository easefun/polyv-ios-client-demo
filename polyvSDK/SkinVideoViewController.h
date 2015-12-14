//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVMoviePlayerController.h"


enum PvGestureType {
    PvUnknown = 0,
    PvBrightness,
    PvVoice,
    PvProgress,
};

typedef enum PvGestureType PvGestureType;


@import MediaPlayer;

@interface SkinVideoViewController : PLVMoviePlayerController



@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;


- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindow;
- (void)dismiss;
- (void)setLocalMp4:(NSString*)vid level:(int)level __deprecated;
- (void)enableDanmu:(BOOL)enable;
- (void)setHeadTitle:(NSString*)headtitle;
- (void)setNavigationController:(UINavigationController*)navigationController;
- (void)setParentViewController:(UIViewController*)viewController;

//额外参数，用来跟踪出错用户
- (void)setParam1:(NSString*)param1;
@end