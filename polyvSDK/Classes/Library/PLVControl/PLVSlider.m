//
//  PLVSlider.m
//  polyvSDK
//
//  Created by LinBq on 16/4/19.
//  Copyright © 2016年 POLV. All rights reserved.
//

#import "PLVSlider.h"
#import <objc/message.h>
#define POINT_OFFSET    (2)
#define PLVColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@interface UIImage (YDSlider)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
@end

@implementation UIImage (YDSlider)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
	UIImage *image = nil;
	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context,color.CGColor);
	CGContextFillRect(context, rect);
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}
@end

@interface PLVSlider ()
@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@end

@implementation PLVSlider{
	UISlider*       _slider;
	UIProgressView* _progressView;
}

- (CGFloat)progressValue{
	return _slider.value;
}

- (void)setProgressValue:(CGFloat)progressValue{
	_slider.value = progressValue;
}

- (CGFloat)loadValue{
	return _progressView.progress;
}

- (void)setLoadValue:(CGFloat)loadValue{
	_progressView.progress = loadValue;
}

- (UIImage* )thumbImage {
	return _slider.currentThumbImage;
}

- (void)setThumbImage:(UIImage *)thumbImage{
	[_slider setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (CGFloat)progressMaximumValue{
	return _slider.maximumValue;
}
- (void)setProgressMaximumValue:(CGFloat)progressMaximumValue{
	_slider.maximumValue = progressMaximumValue;
}

- (CGFloat)progressMinimumValue{
	return _slider.minimumValue;
}
- (void)setProgressMinimumValue:(CGFloat)progressMinimumValue{
	_slider.minimumValue = progressMinimumValue;
}

- (void)loadSubView {
	if (self.isLoaded) return;
	self.loaded = YES;
	
	self.backgroundColor = [UIColor clearColor];
	
	_slider = [[UISlider alloc] initWithFrame:self.bounds];
	_slider.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self addSubview:_slider];
	
	CGRect rect = _slider.bounds;
	
	rect.origin.x += POINT_OFFSET;
	rect.size.width -= POINT_OFFSET*2;
	_progressView = [[UIProgressView alloc] initWithFrame:rect];
	_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	_progressView.center = _slider.center;
	_progressView.userInteractionEnabled = NO;
	
	[_slider addSubview:_progressView];
	[_slider sendSubviewToBack:_progressView];
	_slider.continuous = NO;
	
	_slider.minimumTrackTintColor = PLVColor(220, 48, 47, 1);
	_progressView.progressTintColor = PLVColor(75, 75, 75, 1);
	_progressView.trackTintColor = PLVColor(50, 50, 50, 0.8);
	_slider.maximumTrackTintColor = [UIColor clearColor];
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self loadSubView];
}

- (id)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		[self loadSubView];
	}
	return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
	[_slider addTarget:target action:action forControlEvents:controlEvents];
}

@end
