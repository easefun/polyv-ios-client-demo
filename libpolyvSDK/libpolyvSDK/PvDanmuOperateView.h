//
//  PvDanmuOperateView.h
//  PvDanumuDemo
//
//  Copyright (c) 2015年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PvDanmuOperateViewDelegate <NSObject>

- (void)closeDanmu:(UIButton *)btn;
- (void)sendDanmu:(NSString*)danmu;

@end

@interface PvDanmuOperateView : UIView

@property (nonatomic, strong, readonly) UITextField *editContentTF;

@property (nonatomic, strong, readonly) UIButton *sendBtn;

@property (nonatomic, weak) id<PvDanmuOperateViewDelegate> deleagte;

//- (void)setOperateHeight:(CGFloat)h;
//
//- (void)setEditHeight:(CGFloat)h;

@end
