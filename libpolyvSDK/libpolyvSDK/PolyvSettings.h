//
//  PolyvSettings.h
//  hlsplay
//
//  Created by seanwong on 3/27/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PvVideo.h"

extern NSString *PolyvPrivatekey;
extern NSString *PolyvReadtoken;
extern NSString *PolyvWritetoken;
extern NSString *PolyvUserId;
/// 多账号
extern BOOL mutilAccount;
/// 启用Airplay
extern BOOL enableAirplay;

// 后台下载会话完成通知名称及其userInfo键
static NSString * const PLVBackgroundSessionUpdateNotification = @"PLVBackgroundSessionUpdateNotification";
static NSString * const PLVSessionIdKey = @"sessionId";
static NSString * const PLVBackgroundSessionCompletionHandlerKey = @"backgroundSessionCompletionHandler";

typedef NS_OPTIONS(NSUInteger, PLVLogLevel) {
	PLVLogLevelNone		= 0,		// 禁用日志输出
	PLVLogLevelError	= 1 << 0,	// 只输出错误日志
	PLVLogLevelWarn		= 1 << 1,	// 只输出警告日志
	PLVLogLevelInfo		= 1 << 2,	// 只输出信息日志
	PLVLogLevelDebug	= 1 << 3,	// 只输出调试日志
	PLVLogLevelWithoutDebug = PLVLogLevelError | PLVLogLevelWarn | PLVLogLevelInfo,
	PLVLogLevelAll		= 0xFFFFFFFF,
};

#define LOG_ERROR	[PolyvSettings.sharedInstance logLevel] & PLVLogLevelError
#define LOG_WARN	[PolyvSettings.sharedInstance logLevel] & PLVLogLevelWarn
#define LOG_INFO	[PolyvSettings.sharedInstance logLevel] & PLVLogLevelInfo
#define LOG_DEBUG	[PolyvSettings.sharedInstance logLevel] & PLVLogLevelDebug

#define PLVErrorLog(fmt, ...)	if (LOG_ERROR) NSLog((@"[PLV_SDK_ERROR] " fmt), ##__VA_ARGS__);
#define PLVWarnLog(fmt, ...)	if (LOG_WARN) NSLog((@"[PLV_SDK_WARN] " fmt), ##__VA_ARGS__);
#define PLVInfoLog(fmt, ...)	if (LOG_INFO) NSLog((@"[PLV_SDK_INFO] " fmt), ##__VA_ARGS__);
#define PLVDebugLog(fmt, ...)	if (LOG_DEBUG) NSLog((@"[PLV_SDK_DEBUG] " fmt), ##__VA_ARGS__);


@interface PolyvSettings : NSObject

/// 下载载目录路径
@property (nonatomic, copy, getter=getDownloadDir) NSString *downloadDir;
/// 日志输出级别，默认为 PLVLogLevelWithoutDebug
@property (nonatomic, assign) PLVLogLevel logLevel;
/// 是否开启 HttpDNS，开启后必须允许 http 访问
@property (nonatomic, assign) BOOL httpDNSEnable;

/**初始化Polyv设置，需要在AppDelegate.m的didFinishLaunchingWithOptions方法里面添加*/
- (void)initVideoSettings:(NSString *)privateKey Readtoken:(NSString *)readtoken Writetoken:(NSString *)writetoken UserId:(NSString *)userId;

/**只初始化上传功能设置*/
- (void)initUploadSettings:(NSString *)privateKey Readtoken:(NSString *)readtoken Writetoken:(NSString *)writetoken UserId:(NSString *)userId;

+ (id)sharedInstance;

//+(void)stat:(NSString*)pid vid:(NSString*)vid flow:(long)flow pd:(int)pd sd:(int)sd cts:(int)cts duration:(int)duration;
//+(void)reportError:(NSString*)pid vid:(NSString*)vid error:(NSString*)error param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3 param4:(NSString*)param4 param5:(NSString*)param5;

/**
 *  同步获取视频相关元数据
 *
 *  @param vid 视频id
 *
 *  @return 视频元数据
 */
+ (NSDictionary *)loadVideoJson:(NSString *)vid;

/**
 *  从指定主机同步获取视频相关元数据
 *
 *  @param host 主机域名
 *  @param vid  视频id
 *
 *  @return 视频元数据
 */
+ (NSDictionary *)loadVideoJsonWithHost:(NSString *)host vid:(NSString *)vid;

/**
 *  该视频是否可用（账号是否超流量、视频是否完成转码）
 *
 *  @param videoInfo 视频元数据
 *
 *  @return 视频可用性
 */
+ (BOOL)isVideoAvailable:(NSDictionary *)videoInfo;

/**
 *  生成 videoPoolId
 *
 *  @param vid 视频id
 *
 *  @return videoPoolId
 */
+ (NSString *)getVideoPoolId:(NSString *)vid;

/**
 *  获取pid（用户id）
 *
 *  @return pid
 */
+ (NSString *)getPid;

/**
 *  获取问答数据
 *
 *  @param vid 视频id
 *
 *  @return 问答数据
 */
+ (NSMutableArray *)getVideoExams:(NSString *)vid;

/**
 *  设置本地服务端口
 *
 *  @param port 本地服务端口
 */
+ (void)setPort:(int)port;

/**
 *  获取本地服务端口
 *
 *  @return 本地服务端口
 */
+ (int)getPort;

/**
 *  获取本地主机域名
 *
 *  @return 本地主机域名
 */
+ (NSString *)getHost;

/**
 *  获取 PvVideo 对象
 *
 *  @param vid 视频id
 *
 *  @return PvVideo 对象
 */
+ (PvVideo *)getVideo:(NSString *)vid;

/**
 *  重新载入配置
 */
- (void)reloadSettings;

/**
 *  获取 SDK 版本
 *
 *  @return SDK 版本
 */
- (NSString *)sdkVersion;

@end
