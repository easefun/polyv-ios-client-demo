polyv-ios-client-demo
=====================

初始化设置
--
加入

`MobileCoreServices.framework`

`SystemConfiguration.framework`

`libz.dylib`

`libsqlite3.0.dylib`

到项目.

在AppDelegate.m里面

修改对应用户的配置信息：

`privateKey`,`Readtoken`,`Writetoken`,`UserId`

其中`privateKey`,`Readtoken`,`Writetoken`,`UserId`在polyv后台系统设置的api选项可以找到



```objective-c
@interface AppDelegate ()

...

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    // Override point for customization after application launch.
    //设置离线缓存目录
      [[PolyvSettings sharedInstance] setDownloadDir:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/plvideo/a"]];
    [[PolyvSettings sharedInstance] initVideoSettings:@"" Readtoken:@"" Writetoken:@"" UserId:@""];
    return YES;
}

...


//从后台切回需要重载设置
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [[PolyvSettings sharedInstance] reloadSettings];
}
```

播放器
--
演示中使用了两种视频播放器，PLVMoviePlayerController以及SkinVideoViewController

SkinVideoViewController有自定义播放器皮肤，全屏旋转，以及切换码率等功能。


调用播放器播放视频 
--
播放器PLVMoviePlayerController继承了iOS的MPMoviePlayerController，有MPMoviePlayerController所有属性和方法，可以直接当MPMoviePlayerController来使用。

播放Polyv的视频，只增加了如下接口：
```objective-c
/**传递vid并初始化一个播放器*/
-(id)initWithVid:(NSString*)vid;
/**播放器设置vid*/
- (void)setVid:(NSString*)vid;

/**传递vid和播放的码率，并初始化一个播放器*/
-(id)initWithVid:(NSString*)vid level:(int)level;

/**播放器设置vid和播放的码率*/
- (void)setVid:(NSString*)vid level:(int)level;

/**获取当前视频的有多少个码率*/
-(int)getLevel;

/**切换码率*/
-(void)switchLevel:(int)level;

//非加密视频专用
-(id)initWithLocalMp4:(NSString*)vid level:(int)level;
```

在线播放，下载，本地播放视频的相关演示在`PolyvPlayerDemoViewController.m`可以找到。

播放离线视频，跟播放在线视频的调用方式一致，但离线播放需要指定下载好的视频码率，不能用自适应播放。
码率参数level可指定为1，2，3分别代表"流畅"，"高清"和"超清"

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
