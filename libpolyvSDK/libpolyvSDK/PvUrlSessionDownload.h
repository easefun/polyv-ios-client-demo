//
//  PLVURLSessionDownloader.h
//  Demo
//
//  Created by seanwong on 3/17/16.
//  Copyright © 2016 expai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PvUrlSessionDownloadDelegate.h"
#import "PvVideo.h"

@interface PvUrlSessionDownload : NSObject

/// 视频元数据
@property (nonatomic, strong) NSDictionary *videoInfo __deprecated;

/// 当前码率
@property (nonatomic, assign, readonly) PvLevel level;

/// 设置下载是否使用后台会话
@property (nonatomic, assign) BOOL backgroundMode;

/// 后台下载会话标识符
@property (nonatomic, copy, readonly) NSString *sessionId;

/// 后台完成回调
@property (nonatomic, copy) void(^completeBlock)(void);

/**
 *  初始化下载器
 *
 *  @param vid   视频 id
 *  @param level 码率
 *
 *  @return PvUrlSessionDownload 对象
  */
- (instancetype)initWithVid:(NSString *)vid level:(PvLevel)level;

/**
 *  初始化下载器
 *
 *  @param video 视频模型
 *  @param level 码率
 *
 *  @return PvUrlSessionDownload 对象
 */
- (instancetype)initWithVideo:(PvVideo *)video level:(PvLevel)level;

/**
 *  开始下载
 */
- (void)start;

/**
 *  停止下载
 */
- (void)stop;

/**
 *  是否已停止下载
 *
 *  @return 是否已停止下载
 */
- (BOOL)isStoped;

/**
 *  取消下载会话
 */
- (void)cleanSession;

/**
 *  设置下载代理回调
 *
 *  @param delegate 代理
 */
- (void)setDownloadDelegate:(id<PvUrlSessionDownloadDelegate>)delegate;

/**
 *  删除指定 vid 的视频
 *
 *  @param vid 视频 id
 */
+ (void)deleteVideo:(NSString *)vid;

/**
 *  删除指定码率、vid 的视频
 *
 *  @param vid   视频 id
 *  @param level 码率
 */
+ (void)deleteVideo:(NSString *)vid level:(int)level;

/**
 *  删除所有下载文件
 */
+ (void)cleanDownload;

/**
 *  设置视频下载目录不备份到icloud
 *
 *  @return 设置是否成功
 */
+ (BOOL)addSkipBackupAttributeToDownloadedVideos;

/**
 *  指定码率、vid 的视频是否已下载
 *
 *  @param vid   视频 id
 *  @param level 视频码率
 *
 *  @return 该视频是否已存在
 */
+ (BOOL)isVideoExists:(NSString *)vid level:(int)level;

@end
