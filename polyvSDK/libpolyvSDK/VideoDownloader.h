//
//  M3U8Downloader.h
//  hlsplay
//
//  Created by seanwong on 4/9/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadDelegate.h"
@interface VideoDownloader : NSObject

/**停止或暂停下载*/
-(void)stop;
/**开始下载*/
- (void)start:(NSString*)vid level:(int)level;
/**设置下载代理回调*/
-(void)setDownloadDelegate:(id<DownloadDelegate>)delegate;
/**删除某个码率视频文件*/
-(void)deleteVideo:(NSString*)vid level:(int)level;
/**删除某个视频所有码率文件*/
-(void)deleteVideo:(NSString *)vid;
/**设置视频下载目录不备份到icloud*/
-(BOOL)addSkipBackupAttributeToDownloadedVideos;
/**删除所有下载文件*/
-(void)cleanDownload;
-(BOOL)isVideoExists;
@end
