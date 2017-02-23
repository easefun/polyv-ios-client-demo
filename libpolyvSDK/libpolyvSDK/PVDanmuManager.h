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

- (instancetype)initWithFrame:(CGRect)frame withVid:(NSString*)vid inView:(UIView *)view underView:(UIView*)underView durationTime:(NSUInteger)time;
- (void)resetDanmuWithFrame:(CGRect)frame data:(NSArray *)infos inView:(UIView *)view durationTime:(NSUInteger)time;
- (void)resetDanmuWithFrame:(CGRect)frame;
- (void)initStart;
- (void)rollDanmu:(NSTimeInterval)startTime;
- (void)pause;
- (void)resume:(NSTimeInterval)nowTime;
-(void)sendDanmu:(NSString*)vid msg:(NSString*)msg time:(NSString*)time fontSize:(NSString*)fontSize fontMode:(NSString*)fontMode fontColor:(NSString*)fontColor;
- (void)insertDanmu:(NSDictionary *)info;

@end
