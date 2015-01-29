//
//  PolyvPlayerViewController.h
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol PolyvPlayerDelegate <NSObject>

@optional
/**
 
 @abstract 播放器暂停后回调消息
 @discussion 检测播放器暂停状态时，回调此方法
 */

- (void)videoPlayerPaused;

/**
 
 @abstract 播放器开始后回调消息
 @discussion 检测播放器开始播放状态时，回调此方法
 */
- (void)videoPlayerStarted;

/**
 
 @abstract 播放器停止后回调消息
 @discussion 检测播放器播放完毕状态时，回调此方法
 */
- (void)videoPlayerStopped;

/**
 
 @abstract 播放器播放将要结束时回调消息
 @discussion 检测播放器将要结束状态时，回调此方法
 */
- (void)videoPlayerEnded;

/**
 
 @abstract 播放器出现错误回调消息
 @discussion 检测播放器出现错误状态时，回调此方法
 */
- (void)videoPlayerError;


@end




@interface PolyvPlayerViewController : UIViewController



- (id)initWithVid:(NSString *)vid delegate:(id<PolyvPlayerDelegate>)delegate;

/**
 @abstract 播放网络视频初始化
 @discussion 传入url参数初始化播放器，播放网络视频时用此方法
 @param urlString 视频URL
 @param delegate 视频播放器的代理类
 @return 返回播放器的实例
 */
- (id)initWithURLString:(NSString *)urlString delegate:(id<PolyvPlayerDelegate>)delegate;


/**
 @abstract 切换视频vid
 @discussion
 @param urlString 视频URL
 */
- (void)changeVideo:(NSString *)vid;


/**
 
 @abstract 播放本地视频初始化
 @discussion 传入path等参数初始化播放器，播放本地视频时用此方法
 @param path 本地视频的路径
 @param isEncoded 本地视频是否为加密过的视频 YES为是，NO为否。
 @param delegate 视频播放器的代理类
 @return 返回播放器的实例
 */

- (id)initPlayerWithLocalPath:(NSString *)path encoded:(BOOL)isEncoded delegate:(id<PolyvPlayerDelegate>)delegate;


/**
 
 @abstract 设置播放器的坐标长宽等
 @discussion 设置播放器在屏幕中显示的位置及大小等
 @param frame 视频的view坐标长宽等
 */
- (void)setFrame:(CGRect) frame;

/**
 @abstract 开始播放
 @discussion 调用此方法播放器会开始播放视频
 */
- (void)startPlayer;

/**
 
 @abstract 暂停播放
 @discussion 调用此方法播放器会暂停播放视频
 */

- (void)pausePlayer;


/**
 
 @abstract 停止播放
 @discussion 调用此方法播放器会停止播放视频
 */
- (void)stopPlayer;


/**
 
 @abstract 获取音量
 @discussion 调用此方法会返回当前播放器的音量大小
 @return 返回播放器的音量大小 0到1.0之间
 */
- (float)getVolume;
//设置播放器声音

/**
 
 @abstract 设置音量
 @discussion 调用此方法可以当前播放器的音量大小
 @param volume 播放器的音量大小 0到1.0之间
 */
- (void)setVolume:(float)volume;

/**
 
 @abstract 设置播放速率
 @discussion 调用此方法可以当前播放器的播放速度
 @param volume 播放器的音量大小 0到1.0之间
 */
- (void)setPlaybackRate:(float)playbackRate;

/**
 
 @abstract 设置播放器当前放时间
 @discussion 视频播放时调用此方法可以设置视频的当前播放位置
 @param value 播放器当前播放时间 单位是毫秒
 */
- (void)setCurrentTime:(float)value;

/**
 
 @abstract 设置播放器初始化播放放时间
 @discussion 视频播放器初始化的时候调用此方法，可以设置播放器的其实播放时间
 @param value 播放器起始播放时间 单位是毫秒
 */
- (void)setInitialTime:(float)value;


/**
 
 @abstract 获取播放器当前放时间
 @discussion 视频播放器播放的时候调用此方法，可以获取当前的播放时间
 @return 返回当前视频的播放时间 单位：毫秒
 */
- (float)getCurrentTime;


/**
 
 @abstract 获取播放总时间
 @discussion 视频播放器播放的时候调用此方法，可以获取当前的播放的视频的总时长
 @return 返回当前视频的播放总时长 单位：毫秒
 */
- (float)getTotalTime;

/**
 
 @abstract 改变全屏模式 默认为全屏拉伸
 @discussion 视频播放器播放的时候调用此方法，可以设置视频的全屏模式，有适应长、宽、拉伸等
 @param mode 全屏模式参数
 */

- (void)changeScalingMode:(MPMovieScalingMode)mode;

/**
 
 @abstract 检查全屏模式
 @discussion 视频播放器播放的时候调用此方法，可以检查视频的全屏模式，有适应长、宽、拉伸等
 @return   返回视频的全屏模式
 */
- (MPMovieScalingMode)checkScailingMode;

/**
 
 @abstract 设置播放器控制模式
 @discussion 视频播放器初始化的时候调用此方法，可以设置是否要用系统默认的控件等
 @param style 控制模式参数
 */
- (void)setPlayerControlStyle:(MPMovieControlStyle)style;


- (void)setFullscreen:(BOOL)isfull animated:(BOOL)animated;
-(MPMoviePlayerController*)getPlayer;
@end
