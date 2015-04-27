//
//  PolyvSettings.h
//  hlsplay
//
//  Created by seanwong on 3/27/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PolyvSettings : NSObject

extern NSString *PolyvPrivatekey;
extern NSString *PolyvReadtoken;
extern NSString *PolyvWritetoken;
extern NSString *PolyvUserId;


+(NSDictionary*)loadVideoJson:(NSString*)vid;
+(BOOL)isVideoAvailable:(NSDictionary*)videoInfo;
+(NSString*)getVideoPoolId:(NSString*)vid;

-(void)initVideoSettings:(NSString*)privateKey Readtoken:(NSString*)readtoken Writetoken:(NSString*)writetoken UserId:(NSString*)userId;

@end
