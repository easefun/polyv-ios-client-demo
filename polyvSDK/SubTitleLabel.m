//
//  SubTitleLabel.m
//  polyvSDK
//
//  Created by seanwong on 2/17/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import "SubTitleLabel.h"

@implementation SubTitleLabel


- (void)drawTextInRect:(CGRect)rect
{
    
        CGFloat height = [self sizeThatFits:rect.size].height;
        
        rect.origin.y += rect.size.height - height;
        rect.size.height = height;
    
    
    [super drawTextInRect:rect];
}


@end
