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
在线播放，下载，本地播放视频的相关演示在`PolyvPlayerDemoViewController.m`可以找到

```objective-c
/**
 点击播放按钮执行创建一个PolyvPlayerViewController实例，设置播放器大小为320x180，位置在左上角0，0坐标
 */
- (IBAction)playAction:(id)sender {
    //用vid初始化播放器
    player = [[PolyvPlayerViewController alloc] initWithVid:vid delegate:self];
    [player setFrame: CGRectMake(0, 0, 320, 180)];
    [player setPlayerControlStyle:MPMovieControlStyleDefault];
    [self.view addSubview:player.view];
    //启动播放器
    [player startPlayer];
}


/**
 播放器切换另外一个视频
 */
- (IBAction)switchVid:(id)sender {
    [player stopPlayer];
    [player changeVideo:@"sl8da4jjbx2d77fa6b3588b379f33289_s"];
    [player startPlayer];
}
/**
 暂停播放器
 **/
- (IBAction)pauseAction:(id)sender {
    [player pausePlayer];
}
/**
 启动下载器
 **/
- (IBAction)downloadAction:(id)sender {
    [downloder download];
}


/**
 播放本地视频，要事先下载好视频之后，如果本地文件不存在则无法播放
 [Helper getDownloadFilePath:vid]用vid获取到本地文件所在路径
 */
- (IBAction)playLocalAction:(id)sender {
    player = [[PolyvPlayerViewController alloc] initPlayerWithLocalPath:[Helper getDownloadFilePath:vid] encoded:YES delegate:self];
    NSLog(@"play local file:%@",[Helper getDownloadFilePath:vid]);
    
    
    [player setFrame: CGRectMake(0, 0, 320, 240)];
    [player setPlayerControlStyle:MPMovieControlStyleDefault];
    
    [self.view addSubview:player.view];
    
    [player startPlayer];

}
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
