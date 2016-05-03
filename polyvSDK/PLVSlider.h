//
//  PLVSlider.h
//  polyvSDK
//
//  Created by LinBq on 16/4/19.
//  Copyright © 2016年 POLV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLVSlider : UIControl
@property (nonatomic, assign) CGFloat loadValue; /* From 0 to 1 */
@property (nonatomic, assign) CGFloat progressValue; /* From 0 to 1 */
@property (nonatomic, strong) UIImage* thumbImage;
@property (nonatomic, assign) CGFloat progressMaximumValue;
@property (nonatomic, assign) CGFloat progressMinimumValue;
@end
