//
//  PLVIndicator.h
//  polyvSDK
//
//  Created by LinBq on 16/4/20.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVIndicator : UIView
- (void)forward:(BOOL)isForward time:(NSString *)content;
- (void)showMessage:(NSString *)message;
@end
