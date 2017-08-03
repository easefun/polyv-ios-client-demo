//
//  PLVURLSessionDownloaderDelegate.h
//  Demo
//
//  Created by seanwong on 3/17/16.
//  Copyright © 2016 expai. All rights reserved.
//

typedef NS_ENUM(NSInteger, PLVDownloadState) {
    PLVDownloadStatePreparing,  // 准备
    PLVDownloadStateReady,		// 就绪
    PLVDownloadStateRunning,	// 正在下载
    PLVDownloadStateStopping,   // 正在停止
    PLVDownloadStateStopped,	// 停止下载
    PLVDownloadStateSuccess,	// 下载成功
    PLVDownloadStateFailed		// 下载失败
};

@class PvUrlSessionDownload;

@protocol PvUrlSessionDownloadDelegate <NSObject>

@optional

/// 视频任务创建成功，状态回调建议使用 `downloader:withVid:didChangeDownloadState:`。
- (void)downloadTaskDidCreate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid __deprecated;

/// 视频任务开始下载，状态回调建议使用 `downloader:withVid:didChangeDownloadState:`。
- (void)downloadDidStart:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid __deprecated;

/// 下载完成调用的方法，状态回调建议使用 `downloader:withVid:didChangeDownloadState:`。
- (void)downloadDidFinished:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid __deprecated;

/// 下载停止调用的方法，状态回调建议使用 `downloader:withVid:didChangeDownloadState:`。
- (void)dataDownloadStop:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid __deprecated;


/**
 下载失败回调
 
 @param downloader 下载器
 @param vid 视频 id
 @param reason 错误信息
 */
- (void)dataDownloadFailed:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid reason:(NSString *)reason;

/**
 下载进度回调
 
 @param downloader 下载器
 @param vid 视频 id
 @param aPercent 下载进度，取值 0-100
 */
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent:(NSNumber *)aPercent;

/**
 下载速率回调
 
 @param downloader 下载器
 @param vid 视频 id
 @param aRate 下载速率
 */
- (void)dataDownloadAtRate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid rate:(NSNumber *)aRate;

/**
 下载状态回调
 
 @param downloader 下载器
 @param vid 视频 id
 @param state 下载状态
 */
- (void)downloader:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid didChangeDownloadState:(PLVDownloadState)state;

@end
