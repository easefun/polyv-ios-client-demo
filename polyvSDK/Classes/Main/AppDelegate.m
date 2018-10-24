//
//  AppDelegate.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import "PolyvSettings.h"
#import "PolyvUtil.h"
#import <AlicloudUtils/AlicloudReachabilityManager.h>
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 当前 SDK 版本
    NSLog(@"当前 SDK 版本：%@", [PolyvSettings sdkVersion]);
    
    // 监听SDK错误通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorDidOccur:) name:PLVErrorNotification object:nil];
    
    // 采用 AlicloudReachabilityManager 监听网络情况
    [AlicloudReachabilityManager shareInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusDidChange:) name:ALICLOUD_NETWOEK_STATUS_NOTIFY object:nil];
    
	// 配置下载目录
    [PolyvSettings sharedInstance].downloadDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/plvideo/a"];
	// 配置日志等级
    [PolyvSettings sharedInstance].logLevel = PLVLogLevelWarn | PLVLogLevelInfo;
	// 开启 HttpDNS 功能
    //[PolyvSettings sharedInstance].httpDNSEnable = YES;
	
	// 配置sdk加密串
	// NSString *appKey = @"你的app sdk加密串";
    
    NSString *appKey = @"iPGXfu3KLEOeCW4KXzkWGl1UYgrJP7hRxUfsJGldI6DEWJpYfhaXvMA+32YIYqAOocWd051v5XUAU17LoVlgZCSEVNkx11g7CxYadcFPYPozslnQhFjkxzzjOt7lUPsWF/CO2xt5xZemQCBkkSKLGA==";
    
	// 使用默认加密秘钥和加密向量解密 sdk加密串
	NSArray *config = [PolyvUtil decryptUserConfig:[appKey dataUsingEncoding:NSUTF8StringEncoding]];
	
	// 配置信息必须在初始化设置之前！
	[[PolyvSettings sharedInstance] initVideoSettings:[config objectAtIndex:1] Readtoken:[config objectAtIndex:2] Writetoken:[config objectAtIndex:3] UserId:[config objectAtIndex:0]];
    
    /// viewlog 支持传递终端用户的userid，昵称
    [PolyvSettings sharedInstance].viewerName = @"播放时需要统记的观看用户昵称";
    [PolyvSettings sharedInstance].viewerID = @"播放时需要统记的观看用户UID";
    
	// 配置sdk加密串示例(使用网络接口)
	/*
	NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://demo.polyv.net/demo/appkey.php"]];
	NSArray*config =[PolyvUtil decryptUserConfig:data];
	if ([config count]!=4) {
		NSLog(@"加载token失败");
	}else{
		[[PolyvSettings sharedInstance] setDownloadDir:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/plvideo/a"]];
		[[PolyvSettings sharedInstance] initVideoSettings:[config objectAtIndex:1] Readtoken:[config objectAtIndex:2] Writetoken:[config objectAtIndex:3] UserId:[config objectAtIndex:0]];
	}
	 */
	
	// 配置音频会话，忽略系统静音开关
	[self setupAudioSession];
	
	return YES;
}

/// 配置音量会话
- (void)setupAudioSession {
	NSError *categoryError = nil;
	if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&categoryError]){
		NSLog(@"音量会话类别设置错误：%@", categoryError);
	}
	
	NSError *activeError = nil;
	if (![[AVAudioSession sharedInstance] setActive:YES error:&activeError])	{
		NSLog(@"音量会话激活设置错误：%@", activeError);
	}
}

/// 错误通知响应
- (void)errorDidOccur:(NSNotification *)notificaiton {
    NSLog(@"%@ - error info = %@", notificaiton.object, notificaiton.userInfo[PLVErrorMessageKey]);
}

/// 网络情况通知响应
- (void)networkStatusDidChange:(NSNotification *)notification {
    if ([AlicloudReachabilityManager shareInstance].preNetworkStatus == [AlicloudReachabilityManager shareInstance].currentNetworkStatus) return;
    NSString *networkStatusString = @"nerwork status did change: ";
    switch ([AlicloudReachabilityManager shareInstance].currentNetworkStatus) {
        case AlicloudNotReachable:{
            networkStatusString = [networkStatusString stringByAppendingFormat:@"Not Reachable."];
        }break;
        case AlicloudReachableVia2G:{
            networkStatusString = [networkStatusString stringByAppendingFormat:@"2G."];
        }break;
        case AlicloudReachableVia3G:{
            networkStatusString = [networkStatusString stringByAppendingFormat:@"3G."];
        }break;
        case AlicloudReachableVia4G:{
            networkStatusString = [networkStatusString stringByAppendingFormat:@"4G."];
        }break;
        case AlicloudReachableViaWiFi:{
            networkStatusString = [networkStatusString stringByAppendingFormat:@"WiFi."];
        }break;
        default:{}break;
    }
    NSLog(@"%@", networkStatusString);
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(nonnull void (^)())completionHandler
{
	NSDictionary *userInfo = @{PLVSessionIdKey: identifier,
							   PLVBackgroundSessionCompletionHandlerKey: completionHandler};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLVBackgroundSessionUpdateNotification
														object:self
													  userInfo:userInfo];
}
/*
 
 -(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(nonnull NSString *)identifier completionHandler:(nonnull void (^)())completionHandler
 {
 self.backgroudSesstonCompletionHandler = completionHandler;
 }
*/

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 [[PolyvSettings sharedInstance]  reloadSettings];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end

//
////默认Portrait避免自动旋转
//@implementation UITabBarController (PolyvDemo)
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    if(toInterfaceOrientation == UIDeviceOrientationPortrait)
//        return YES;
//    return NO;
//}
//-(BOOL)shouldAutorotate{
//    return NO;
//}
//
//
//
//@end
//
//@implementation UINavigationController (PolyvDemo)
//-(BOOL)shouldAutorotate{
//    return NO;
//}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    if(toInterfaceOrientation == UIDeviceOrientationPortrait){
//        return YES;
//    }
//    
//    return NO;
//}
//@end
