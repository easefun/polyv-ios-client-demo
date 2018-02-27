//
//  PvReportManager.h
//  liveplayer
//
//  Created by seanwong on 10/27/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PvReportManager : NSObject

+ (NSString *)getPid;
+ (void)stat:(NSString *)pid uid:(NSString *)uid vid:(NSString *)vid flow:(long)flow pd:(int)pd sd:(int)sd cts:(NSTimeInterval)cts duration:(int)duration;

+ (void)reportLoading:(NSString *)pid uid:(NSString *)uid vid:(NSString *)vid time:(double)time param1:(NSString *)param1 param2:(NSString *)param2 param3:(NSString *)param3 param4:(NSString *)param4 param5:(NSString *)param5;
+ (void)reportBuffer:(NSString *)pid uid:(NSString *)uid vid:(NSString *)vid time:(double)time param1:(NSString *)param1 param2:(NSString *)param2 param3:(NSString *)param3 param4:(NSString *)param4 param5:(NSString *)param5;
+ (void)reportError:(NSString *)pid uid:(NSString *)uid vid:(NSString *)vid error:(NSString *)error param1:(NSString *)param1 param2:(NSString *)param2 param3:(NSString *)param3 param4:(NSString *)param4 param5:(NSString *)param5;


/**
 发送 viewlog 日志

 @param pid 播放ID，全局唯一
 @param vid 视频ID
 @param currentPlaybackTime 当前播放时间
 @param videoDuration 视频时长
 @param watchDuration 观看时长
 @param stayDuration 停留时长
 @param sessionId 场次ID
 */
+ (void)viewlogWithPid:(NSString *)pid vid:(NSString *)vid currentPlaybackTime:(NSInteger)currentPlaybackTime videoDuration:(NSInteger)videoDuration watchDuration:(NSInteger)watchDuration stayDuration:(NSInteger)stayDuration sessionId:(NSString *)sessionId;

@end
