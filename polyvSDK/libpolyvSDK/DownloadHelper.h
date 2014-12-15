//
//  DownloadHelper.h
//  polyvSDK
//
//  Created by seanwong on 8/14/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadHelperDelegate <NSObject>
@optional
- (void) downloadDidFinished: (NSString *) aName;
- (void) didReceiveFilename: (NSString *) aName;
- (void) dataDownloadFailed: (NSString *) reason;
- (void) dataDownloadAtPercent: (NSNumber *) aPercent;
@end

@interface DownloadHelper : NSObject
{
    //NSMutableData *data;
    NSOutputStream *stream;
    NSString *urlString;
    NSURLConnection *urlconnection;
    id <DownloadHelperDelegate> delegate;
    BOOL isDownloading;
    NSString*vid;
    NSString*filePath;
    BOOL encodefile;
    
    int df;
    NSFileHandle *downloadingFileHandle;
    
    long long downloadProgress;
    
    long long downloadFileSize;
    
}
@property (retain) NSURLResponse *response;
@property (retain) NSURLConnection *urlconnection;
@property (retain) NSOutputStream *stream;
@property (retain) NSString *urlString;
@property (retain) NSString *vid;
@property (retain) NSString *filePath;
@property (retain) id delegate;
@property (assign) BOOL isDownloading;
@property(atomic, retain) NSFileHandle *downloadingFileHandle;

/**
 * 初始化下载器，参数vid为视频vid，encode：是否下载加密，df：清晰度 delegate：回调代理
 */

- (id)initWithVid:(NSString *)vid encode:(BOOL)encode delegate:(id<DownloadHelperDelegate>)polyvdelegate;
- (id)initWithVid:(NSString *)vid encode:(BOOL)encode withDf:(int)df delegate:(id<DownloadHelperDelegate>)polyvdelegate;


- (void) download;
//下载文件总大小
- (long long) getDownloadFileSize;
//当前下载大小
- (long long) downloadProgress;
//取消下载，可以断点恢复
- (void) cancel;
//删除当前下载文件
- (void) deleteVideo;
/**
 设置下载的视频文件属性为不备份,NSURLIsExcludedFromBackupKey=YES
 */
- (BOOL) addSkipBackupAttributeToDownloadedVideos;
@end
