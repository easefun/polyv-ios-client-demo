//
//  PLVIndicator.m
//  polyvSDK
//
//  Created by LinBq on 16/4/20.
//  Copyright © 2016年 easefun. All rights reserved.
//

#import "PLVIndicator.h"
#define backwardIcon [UIImage imageNamed:@"pl-video-player-backward"]
#define kHeight 50.0
#define kRate 0.5
#define kMargin 8.0

@interface PLVIndicator ()
@property (nonatomic, assign) BOOL isForward;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *contentView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *messageView;

@end
@implementation PLVIndicator

- (UIImageView *)iconView{
	if (!_iconView) {
		_iconView = [[UIImageView alloc] initWithImage:backwardIcon];
		[_iconView sizeToFit];
		CGFloat height = self.contentView.frame.size.height;
		_iconView.frame = CGRectMake(0, 0, height, height);
	}
	return _iconView;
}

- (UILabel *)contentView{
	if (!_contentView) {
		_contentView = [[UILabel alloc] init];
		_contentView.text = @"中00:00中";
		_contentView.textColor = [UIColor whiteColor];
		[_contentView sizeToFit];
		_contentView.textAlignment = NSTextAlignmentCenter;
	}
	return _contentView;
}

- (UIView *)containerView{
	if (!_containerView) {
		CGFloat width = CGRectGetWidth(self.iconView.bounds) + kMargin + CGRectGetWidth(self.contentView.bounds);
		CGFloat height = CGRectGetHeight(self.iconView.bounds);
		_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
		[_containerView addSubview:self.iconView];
		[_containerView addSubview:self.contentView];
		self.iconView.center = self.contentView.center = CGPointMake(width/2, height/2);
	}
	return _containerView;
}

- (UILabel *)messageView{
	if (!_messageView) {
		_messageView = [[UILabel alloc] init];
		_messageView.textAlignment = NSTextAlignmentCenter;
		_messageView.textColor = [UIColor whiteColor];
	}
	return _messageView;
}

- (void)setIsForward:(BOOL)isForward{
	if (_isForward == isForward) return;
	_isForward = isForward;
	[UIView animateWithDuration:.2 animations:^{
		[self setUpSubView];
	}];
}

- (instancetype)initWithFrame:(CGRect)frame{
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.frame = CGRectMake(0, 0, kHeight * 2.5, kHeight);
		self.userInteractionEnabled = NO;
		self.clipsToBounds = YES;
		[self addSubview:self.containerView];
		[self addSubview:self.messageView];
		[self setUpSubView];
	}
	return self;
}

- (void)setUpSubView{
	if (self.isForward) {
		self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
		self.iconView.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) + kMargin, self.iconView.frame.origin.y, self.iconView.frame.size.width, self.iconView.frame.size.height);
		self.iconView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
	}else{
		self.iconView.frame = CGRectMake(0, self.iconView.frame.origin.y, self.iconView.frame.size.width, self.iconView.frame.size.height);
		self.iconView.transform = CGAffineTransformIdentity;
		self.contentView.frame = CGRectMake(CGRectGetWidth(self.iconView.bounds) + kMargin, self.contentView.frame.origin.y, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
	}
	CGSize boundSize = self.frame.size;
	self.containerView.center = CGPointMake(boundSize.width/2, boundSize.height/2);
	[self.messageView sizeThatFits:self.frame.size];
}

- (void)layoutSubviews{
	[self setUpSubView];
	
}

- (void)forward:(BOOL)isForward time:(NSString *)content{
	if (self.containerView.hidden) {
		self.containerView.hidden = NO;
		self.messageView.hidden = YES;
	}
	self.contentView.text = content;
	self.isForward = isForward;
	self.alpha = 1;
	[UIView animateWithDuration:1 delay:1 options:0 animations:^{
		self.alpha = 0;
	} completion:nil];
}

- (void)showMessage:(NSString *)message{
	self.containerView.hidden = YES;
	self.messageView.hidden = NO;
	self.messageView.text = message;
	self.messageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	self.alpha = 1;
	[UIView animateWithDuration:1 delay:1 options:0 animations:^{
		self.alpha = 0;
	} completion:nil];
}

- (void)drawRect:(CGRect)rect{
	CGFloat width = rect.size.width;
	CGFloat height = rect.size.height;
	CGFloat radius = (width + height) * 0.05;
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextMoveToPoint(context, radius, 0);
	CGContextAddLineToPoint(context, width - radius, 0);
	CGContextAddArc(context, width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
	CGContextAddLineToPoint(context, width, height - radius);
	CGContextAddArc(context, width - radius, height - radius, radius, 0.0, 0.5 * M_PI, 0);
	CGContextAddLineToPoint(context, radius, height);
	CGContextAddArc(context, radius, height - radius, radius, 0.5 * M_PI, M_PI, 0);
	CGContextAddLineToPoint(context, 0, radius);
	CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
	CGContextClosePath(context);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.5);
	CGContextDrawPath(context, kCGPathFill);
}
@end
