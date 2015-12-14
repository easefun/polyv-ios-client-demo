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

/*
+(void)stat:(NSString*)pid vid:(NSString*)vid flow:(long)flow pd:(int)pd sd:(int)sd cts:(int)cts duration:(int)duration;
+(void)reportError:(NSString*)pid vid:(NSString*)vid error:(NSString*)error param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3 param4:(NSString*)param4 param5:(NSString*)param5;
*/
+(NSDictionary*)loadVideoJson:(NSString*)vid;
+(BOOL)isVideoAvailable:(NSDictionary*)videoInfo;
+(NSString*)getVideoPoolId:(NSString*)vid;
+(NSString*)getPid;
-(NSString*)getDownloadDir;
-(void)setDownloadDir:(NSString*)dir;

+(void)setPort:(int)port;
+(int)getPort;


-(void)reloadSettings;

/**初始化Polyv设置，需要在AppDelegate.m的didFinishLaunchingWithOptions方法里面添加*/
-(void)initVideoSettings:(NSString*)privateKey Readtoken:(NSString*)readtoken Writetoken:(NSString*)writetoken UserId:(NSString*)userId;

/**只初始化上传功能设置*/
-(void)initUploadSettings:(NSString*)privateKey Readtoken:(NSString*)readtoken Writetoken:(NSString*)writetoken UserId:(NSString*)userId;

+ (id)sharedInstance;
@end
