//
//  Video.h
//  polyvSDK
//
//  Created by seanwong on 8/16/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (nonatomic, copy) NSString *title;///标题
@property (nonatomic, copy) NSString *desc;///视频描述
@property (nonatomic,copy) NSString *vid;///视频的vid
@property (nonatomic,copy) NSString *piclink;///视频第一张图的链接
@property (nonatomic,copy) NSString *duration;///视频的总时长
@property long long filesize;///视频大小
@property NSArray* allfilesize;///同一个视频各个不同清晰度的视频大小
@property int level;///视频清晰度，1：流畅, 2：高清, 3：超清
@property int df;///视频码率数
@property int seed;///加密方式，1为加密，0为非加密
@property int status;///下载状态
@property float percent;///下载进度，百分比
@property long rate;///下载速率，单位kb/s

/**
 *  初始化vid
 *
 *  @param _vid 视频vid
 *
 *  @return 
 */
- (id)initWithVid:(NSString*)_vid;
@end
