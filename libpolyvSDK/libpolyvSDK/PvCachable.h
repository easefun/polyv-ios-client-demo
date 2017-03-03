//
//  PvCachable.h
//  polyvSDK
//
//  Created by seanwong on 1/29/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PvCachable : NSObject

@property (nonatomic, copy) NSDictionary *videoJson;
@property NSTimeInterval cacheTime;

@end
