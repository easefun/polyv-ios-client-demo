
#import <Foundation/Foundation.h>
#import "PvUrlSessionDownloadDelegate.h"

@interface PvUrlSessionDownload : NSObject<NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSDictionary *videoInfo;
@property (nonatomic, copy)void(^completeBlock)(void);


@property int level;

+ (id)sharedInstance;
//- (instancetype)initWithVid:(NSString*)vid level:(int)level;
- (void)setBackgroundMode:(BOOL)isBackground;

/**停止或暂停下载*/
-(void)stop;

/** 是否已经停止下载 **/
-(BOOL)isStoped;

/**开始下载*/
//- (void)start;
/**设置下载代理回调*/
-(void)setDownloadDelegate:(id<PvUrlSessionDownloadDelegate>)delegate;
/**删除某个码率视频文件*/
+(void)deleteVideo:(NSString*)vid;
/**删除某个视频所有码率文件*/
+(void)deleteVideo:(NSString*)vid level:(int)level;
/**设置视频下载目录不备份到icloud*/
-(BOOL)addSkipBackupAttributeToDownloadedVideos;
/**删除所有下载文件*/
-(void)cleanDownload;

+(BOOL)isVideoExists:(NSString*)vid level:(int)level;

// 开始新的下载
-(void)startNewDownlaodVideo:(NSString *)vid level:(int)level;



@end

