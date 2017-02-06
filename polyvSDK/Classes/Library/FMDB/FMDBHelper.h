//
//  FMDBHelper.h
//  jkws
//
//  Created by seanwong on 13-7-18.
//
//

#import <Foundation/Foundation.h>
#import "Video.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
@interface FMDBHelper : NSObject
@property (retain, nonatomic) NSString *DBName;
@property (retain, nonatomic) FMDatabaseQueue *queue;

+ (id)sharedInstance;

#pragma mark download

/**
 *  添加下载视频
 *
 *  @param v 添加的视频
 */
-(void)addDownloadVideo:(Video*)v;

/**
 *  下载列表
 *
 *  @return  返回下载列表视频信息的数组
 */
-(NSMutableArray*)listDownloadVideo;

/**
 *  删除下载的视频
 *
 *  @param v 删除的视频
 */
-(void)removeDownloadVideo:(Video*)v;

/**
 *  更新下载的进度
 *
 *  @param vid     视频的vid
 *  @param percent 下载进度的百分比
 */
-(void)updateDownloadPercent:(NSString*)vid percent:(NSNumber*)percent;

/**
 *  更新下载状态
 *
 *  @param vid    视频的vid
 *  @param status 下载状态,1代表下载成功，-1代表下载失败
 */
-(void)updateDownloadStatic:(NSString*)vid status:(int)status;

#pragma mark -

@end
