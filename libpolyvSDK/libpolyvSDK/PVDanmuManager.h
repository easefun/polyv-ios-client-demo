//
//  PVDanmuManager.h
//  polyvSDK
//
//  Created by seanwong on 10/15/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PVDanmuManager : NSObject

/**
 *  初始化弹幕视图管理者
 *
 *  @param frame     frame
 *  @param vid       视频id
 *  @param view      所在视图
 *  @param underView 上方视图
 *  @param time      出现时间
 *
 *  @return PVDanmuManager 对象
 */
- (instancetype)initWithFrame:(CGRect)frame withVid:(NSString *)vid inView:(UIView *)view underView:(UIView *)underView durationTime:(NSUInteger)time;

/**
 *  重置弹幕视图
 *
 *  @param frame frame
 *  @param infos 弹幕信息
 *  @param view  所在视图
 *  @param time  出现时间
 */
- (void)resetDanmuWithFrame:(CGRect)frame data:(NSArray *)infos inView:(UIView *)view durationTime:(NSUInteger)time;

/**
 *  重置弹幕视图
 *
 *  @param frame frame
 */
- (void)resetDanmuWithFrame:(CGRect)frame;

- (void)initStart;

/**
 *  滚动弹幕
 *
 *  @param startTime 出现时间
 */
- (void)rollDanmu:(NSTimeInterval)startTime;

/**
 *  暂停
 */
- (void)pause;

/**
 *  恢复弹幕
 *
 *  @param nowTime 当前时间
 */
- (void)resume:(NSTimeInterval)nowTime;

/**
 *  发送弹幕
 *
 *  @param vid       视频id
 *  @param msg       弹幕信息
 *  @param time      出现时间
 *  @param fontSize  字体大小
 *  @param fontMode  弹幕模式
 *  @param fontColor 字体颜色
 */
- (void)sendDanmu:(NSString *)vid msg:(NSString *)msg time:(double)seconds fontSize:(int)fontSize fontMode:(NSString *)fontMode fontColor:(NSString *)fontColor;

/**
 *  插入弹幕
 *
 *  @param info 弹幕信息
 */
- (void)insertDanmu:(NSDictionary *)info;
@end

