//
//  PvVideo.h
//  polyvSDK
//
//  Created by seanwong on 1/21/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, PvLevel) {
	/// 自动码率/清晰度
	PvLevelAuto,
	/// 标清
	PvLevelStandard = 1,
	/// 高清
	PvLevelHigh,
	/// 超清
	PvLevelUltra
};
NSString *NSStringFromPvLevel(PvLevel level);

@interface PvVideo : NSObject

/// 视频 id
@property (nonatomic, copy) NSString *vid;
/// 可用码率/清晰度数量
@property (nonatomic, assign) int df_num;
/// 视频标题
@property (nonatomic, copy) NSString *title;
/// 视频描述
@property (nonatomic, copy) NSString *desc;
/// 视频首图
@property (nonatomic, copy) NSString *piclink;
/// 视频时长
@property (nonatomic, assign) double duration;
/// 各码率视频大小
@property (nonatomic, strong) NSArray<NSNumber *> *filesize;
/// 是否为可交互视频
@property (nonatomic, assign) BOOL isInteractiveVideo;
/// 视频字幕
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *videoSrts;

- (instancetype)initWithVid:(NSString *)vid dict:(NSDictionary *)dict;
+ (instancetype)videoWithVid:(NSString *)vid dict:(NSDictionary *)dict;
/// 视频是否可用
- (BOOL)available;
/// 视频是否为 MP4
- (BOOL)isMP4;
@end
