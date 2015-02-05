//
//  PLVURLProtocol.h
//  polyvSDK
//
//  Created by seanwong on 11/17/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVURLProtocol : NSURLProtocol
+ (void) register;
+ (void) injectURL:(NSString*) urlString cookie:(NSString*)cookie;
@end
