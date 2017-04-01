//
//  Video.h
//  polyvSDK
//
//  Created by seanwong on 8/16/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//
// 视频模型，用于记录服务器返回的json视频项，与 PvVideo 无关
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

/// 视频标题
@property (nonatomic, copy) NSString *title;

/// 视频描述
@property (nonatomic, copy) NSString *desc;

/// 视频的vid
@property (nonatomic, copy) NSString *vid;

/// 视频首图地址
@property (nonatomic, copy) NSString *piclink;

/// 视频的总时长
@property (nonatomic, copy) NSString *duration;

/// 视频大小
@property long long filesize;

/// 同一个视频各个不同清晰度的视频大小
@property (nonatomic, strong) NSArray* allfilesize;

/// 视频清晰度，1：流畅, 2：高清, 3：超清
@property (nonatomic, assign) int level;

/// 视频码率数
@property (nonatomic, assign) int df;

/// 加密方式，1为加密，0为非加密
@property (nonatomic, assign) BOOL seed;

/// 下载状态
@property (nonatomic, assign) int status;

/// 下载进度，百分比
@property (nonatomic, assign) float percent;

/// 下载速率，单位kb/s
@property (nonatomic, assign)long rate;

/// 从 json 解析的字段中初始化
- (instancetype)initWithDict:(NSDictionary *)jsonDict;


@end
