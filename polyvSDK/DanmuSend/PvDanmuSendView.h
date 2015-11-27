//
//  PvDanmuSendView.h
//  PvDanumuDemo
//
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PvDanmuSendView;

@protocol PvDanmuSendViewDelegate <NSObject>

@optional

- (void)sendDanmu:(PvDanmuSendView *)danmuSendV info:(NSString *)info;

- (void)closeSendDanmu:(PvDanmuSendView *)danmuSendV;

@end

@interface PvDanmuSendView : UIView

@property (nonatomic, weak) id<PvDanmuSendViewDelegate> deleagte;

- (void)showAction:(UIView *)superView;

- (void)backAction;

@end
