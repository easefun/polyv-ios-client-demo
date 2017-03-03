//
//  PLVURLSessionDownloaderDelegate.h
//  Demo
//
//  Created by seanwong on 3/17/16.
//  Copyright © 2016 expai. All rights reserved.
//

@class PvUrlSessionDownload;

@protocol PvUrlSessionDownloadDelegate <NSObject>

@optional

/// 视频任务创建成功
- (void)downloadTaskDidCreate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid;

/// 视频任务开始下载
- (void)downloadDidStart:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid;

/** 下载完成调用的方法*/
- (void)downloadDidFinished:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid;

/** 下载停止调用的方法*/
- (void)dataDownloadStop:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid;

/** 下载失败调用的方法*/
- (void)dataDownloadFailed:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid reason:(NSString *)reason;

/** 下载中调用的方法:获取下载百分比*/
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent:(NSNumber *)aPercent;

/** 下载中调用的方法:获取下载速率*/
- (void)dataDownloadAtRate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid rate:(NSNumber *)aRate;


@end