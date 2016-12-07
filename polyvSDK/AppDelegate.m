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
//#import "DetailViewController.h"
#import "PolyvUtil.h"


@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 配置sdk加密串
    // NSString *appKey1 = @"你的app sdk加密串";
    NSString *appKey1 = @"iPGXfu3KLEOeCW4KXzkWGl1UYgrJP7hRxUfsJGldI6DEWJpYfhaXvMA+32YIYqAOocWd051v5XUAU17LoVlgZCSEVNkx11g7CxYadcFPYPozslnQhFjkxzzjOt7lUPsWF/CO2xt5xZemQCBkkSKLGA==";         // 本地
    NSData *data = [appKey1 dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *config =[PolyvUtil decryptUserConfig:data];
    [[PolyvSettings sharedInstance] setDownloadDir:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/plvideo/a"]];
    [[PolyvSettings sharedInstance] initVideoSettings:[config objectAtIndex:1] Readtoken:[config objectAtIndex:2] Writetoken:[config objectAtIndex:3] UserId:[config objectAtIndex:0]];
    
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
    
    return YES;
}
-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(nonnull void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
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
