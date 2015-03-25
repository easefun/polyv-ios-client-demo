polyv-ios-client-demo
=====================

初始化设置
--
在AppDelegate.m里面

修改对应用户的配置信息：

`privateKey`,`Readtoken`,`Writetoken`,`UserId`,`DownloadId`,`Downloadsecretkey`

其中`privateKey`,`Readtoken`,`Writetoken`,`UserId`在polyv后台系统设置的api选项可以找到

`DownloadId`,`Downloadsecretkey`需要申请。


```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    // Override point for customization after application launch.
    
    [libpolyvSDK initConfigWithPrivateKey:@"DFZhoOnkQf" Readtoken:@"nsJ7ZgQMN0-QsVkscukWt-qLfodxoDFm" Writetoken:@"Y07Q4yopIVXN83n-MPoIlirBKmrMPJu0" UserId:@"sl8da4jjbx" DownloadId:@"testdownload" Downloadsecretkey:@"f24c67d9bc0940b69ad8c0ebd6341730"];
    return YES;
}

```

调用播放器播放视频 
--
在线播放，下载，本地播放视频的相关演示在`ViewController.m`可以找到

上传视频
--

上传视频的演示在`PLVDemoViewController.m`

该演示从相册找到视频，点击上传，支持断点续传。

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



上传（断点续传）演示：

![alt tag](https://cloud.githubusercontent.com/assets/3022663/3977402/5104140a-2838-11e4-8a68-93ac90772790.jpg)


播放器，视频下载，本地加密演示

![alt tag](https://cloud.githubusercontent.com/assets/3022663/3977407/5b9bcd72-2838-11e4-8a76-b97cc7d2451e.jpg)
