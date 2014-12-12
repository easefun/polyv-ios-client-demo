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
    NSURLResponse *response;
    //NSMutableData *data;
    NSOutputStream *stream;
    NSString *urlString;
    NSURLConnection *urlconnection;
    id <DownloadHelperDelegate> delegate;
    BOOL isDownloading;
    NSInteger sizeCounter;
    NSString*vid;
    NSString*filePath;
    BOOL encodefile;
    
    
}
@property (retain) NSURLResponse *response;
@property (retain) NSURLConnection *urlconnection;
@property (retain) NSOutputStream *stream;
@property (retain) NSString *urlString;
@property (retain) NSString *vid;
@property (retain) NSString *filePath;
@property (retain) id delegate;
@property (assign) BOOL isDownloading;

+ (DownloadHelper *) sharedInstance;
- (void) download:(NSString *) vid encode:(BOOL)encode;
- (void) download:(NSString *) videoid withDf:(int) df encode:(BOOL)encode;
- (void) cancel;
/**
 设置下载的视频文件属性为不备份,NSURLIsExcludedFromBackupKey=YES
 */
- (BOOL) addSkipBackupAttributeToDownloadedVideos;
@end
