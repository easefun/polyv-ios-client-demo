//
//  MPMoviePlayerController+plv.h
//  hlsplay
//
//  Created by seanwong on 4/14/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MPMoviePlayerController(plv)



/**传递vid并初始化一个播放器*/
-(id)initWithVid:(NSString*)vid;
/**播放器设置vid*/
- (void)setVid:(NSString*)vid;

/**传递vid和播放的码率，并初始化一个播放器*/
-(id)initWithVid:(NSString*)vid level:(int)level;

/**播放器设置vid和播放的码率*/
- (void)setVid:(NSString*)vid level:(int)level;

/**获取当前视频的码率数*/
-(int)getLevel;

@end
