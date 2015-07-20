polyv-ios-client-demo
=====================

初始化设置
--
加入

`MobileCoreServices.framework`
`SystemConfiguration.framework`
`libz.dylib`
到项目.

在AppDelegate.m里面

修改对应用户的配置信息：

`privateKey`,`Readtoken`,`Writetoken`,`UserId`

其中`privateKey`,`Readtoken`,`Writetoken`,`UserId`在polyv后台系统设置的api选项可以找到



```objective-c
@interface AppDelegate (){
    PolyvSettings* _polyvSettings;
}

...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    // Override point for customization after application launch.
    //设置离线缓存目录
    [PolyvSettings setDownloadDir:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/plvideo/a"]];

    _polyvSettings = [[PolyvSettings alloc] init];
    [_polyvSettings initVideoSettings:@"" Readtoken:@"" Writetoken:@"" UserId:@""];
    return YES;
}

...


//从后台切回需要重载设置
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [_polyvSettings reloadSettings];
}
```

调用播放器播放视频 
--
在线播放，下载，本地播放视频的相关演示在`PolyvPlayerDemoViewController.m`可以找到


```objective-c
#import "PLVMoviePlayerController.h"
...
//跟MPMoviePlayerController操作一样 

self.videoPlayer = [[PLVMoviePlayerController alloc]initWithVid:_vid];

//播放指定码率的视频
 self.videoPlayer = [[PLVMoviePlayerController alloc]initWithVid:vid level:1];


```


上传视频
--

上传视频的演示在`PLVDemoViewController.m`

该演示从相册找到视频，点击上传，支持断点续传。
```objective-c
- (void)uploadVideoFromAsset:(NSDictionary*)info
{
    NSURL *assetUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSString *fingerprint = [assetUrl absoluteString];

    [[self assetsLibrary] assetForURL:assetUrl
                          resultBlock:^(ALAsset* asset) {
                              self.imageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
                              self.imageView.alpha = .5;
                              PLVAssetData* uploadData = [[PLVAssetData alloc] initWithAsset:asset];
                             
                              
                              PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:[self endpoint] data:uploadData fingerprint:fingerprint];
                              NSString * surl = [assetUrl absoluteString];
                              NSString * ext = [surl substringFromIndex:[surl rangeOfString:@"ext="].location + 4];
                              NSMutableDictionary* extraInfo = [[NSMutableDictionary alloc]init];
                              [extraInfo setValue:ext forKey:@"ext"];
                              [extraInfo setValue:@"polyvsdk" forKey:@"title"];
                              [extraInfo setValue:@"polyvsdk upload demo video" forKey:@"desc"];
                              [upload setExtraInfo:extraInfo];
                              upload.progressBlock = [self progressBlock];
                              upload.resultBlock = [self resultBlock];
                              upload.failureBlock = [self failureBlock];
                              [upload start];
                          }
                         failureBlock:^(NSError* error) {
                             NSLog(@"Unable to load asset due to: %@", error);
                         }];
}

```


如果需要指定视频地址，参考如下代码例子:
```objective-c
//视频文件所在地址
NSURL *url = [[NSBundle mainBundle]URLForResource:@"video.mp4" withExtension:nil]
PLVData*uploadData = [[PLVData alloc] initWithData:[NSData dataWithContentsOfURL:url]];
PLVResumableUpload *upload = [[PLVResumableUpload alloc] initWithURL:@"http://v.polyv.net:1080/files/" data:uploadData fingerprint:[url absoluteString]];
NSString * surl = [assetUrl absoluteString];
NSString * ext = [surl substringFromIndex:[surl rangeOfString:@"ext="].location + 4];
NSMutableDictionary* extraInfo = [[NSMutableDictionary alloc]init];
[extraInfo setValue:ext forKey:@"ext"];
[extraInfo setValue:@"polyvsdk" forKey:@"title"];
[extraInfo setValue:@"polyvsdk upload demo video" forKey:@"desc"];
[upload setExtraInfo:extraInfo];

```




上传界面
--

![alt tag](https://cloud.githubusercontent.com/assets/3022663/3977402/5104140a-2838-11e4-8a68-93ac90772790.jpg)


播放器，视频下载，本地加密演示
--

![alt tag](https://cloud.githubusercontent.com/assets/3022663/3977407/5b9bcd72-2838-11e4-8a76-b97cc7d2451e.jpg)
