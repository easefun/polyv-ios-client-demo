//
//  SkinVideoViewController.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVMoviePlayerController.h"

@import MediaPlayer;

@interface SkinVideoViewController : PLVMoviePlayerController

@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;


- (instancetype)initWithFrame:(CGRect)frame
;
- (void)showInWindow;
- (void)dismiss;
- (void)setVid:(NSString *)vid;

@end