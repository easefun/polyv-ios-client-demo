//
//  MPMoviePlayerController+plv.h
//  hlsplay
//
//  Created by seanwong on 4/14/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PLVMoviePlayerController: MPMoviePlayerController

@property (nonatomic, strong)NSDictionary* videoInfo;
@property int watchTimeDuration;
@property int stayTimeDuration;

/**传递vid并初始化一个播放器*/
-(id)initWithVid:(NSString*)vid;
/**播放器设置vid*/
- (void)setVid:(NSString*)vid;

/**传递vid和播放的码率，并初始化一个播放器*/
-(id)initWithVid:(NSString*)vid level:(int)level;

/**播放器设置vid和播放的码率*/
- (void)setVid:(NSString*)vid level:(int)level;

/**获取当前视频在本地的码率, 本地无该视频则返回0*/
- (int)isExistedTheLocalVideo:(NSString *)vid;

/**获取当前视频的有多少个码率*/
-(int)getLevel;

/**切换码率*/
-(void)switchLevel:(int)level;

-(void)cancel;

-(id)initWithLocalMp4:(NSString*)vid level:(int)level __deprecated;



-(NSString*)getPid;
-(NSString*)getVid;

@end
