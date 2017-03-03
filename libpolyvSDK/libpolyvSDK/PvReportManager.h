//
//  PvReportManager.h
//  liveplayer
//
//  Created by seanwong on 10/27/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PvReportManager : NSObject

+(NSString*)getPid;
+(void)reportError:(NSString*)pid uid:(NSString*)uid vid:(NSString*)vid error:(NSString*)error param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3 param4:(NSString*)param4 param5:(NSString*)param5;
+(void)stat:(NSString*)pid uid:(NSString*)uid vid:(NSString*)vid flow:(long)flow pd:(int)pd sd:(int)sd cts:(NSTimeInterval)cts duration:(int)duration;
+(void)reportLoading:(NSString*)pid uid:(NSString*)uid vid:(NSString*)vid time:(double)time param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3 param4:(NSString*)param4 param5:(NSString*)param5;

+(void)reportBuffer:(NSString*)pid uid:(NSString*)uid vid:(NSString*)vid time:(double)time param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3 param4:(NSString*)param4 param5:(NSString*)param5;

@end
