//
//  DownloadListTableViewController.m
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import "DownloadListTableViewController.h"
#import "FMDBHelper.h"///数据库处理
#import "Video.h"///单个视频的信息
#import "SkinVideoViewController.h"///播放器皮肤
#import "PolyvSettings.h"///sdk设置API
#import "AppDelegate.h"

@interface DownloadListTableViewController (){
    NSMutableArray *_videolist;
    NSMutableDictionary *_downloaderDictionary;
    UIBarButtonItem *btnstart;
    BOOL started;///是否已经开始下载
    NSString *currentVid;
}

@property (nonatomic, strong) SkinVideoViewController *videoPlayer;

@end

@implementation DownloadListTableViewController

- (void)startAll{
    //从数据库列表获取下载任务
   // _fmdb = [FMDBHelper sharedInstance];
   // _videolist = [_fmdb listDownloadVideo];
    
    if(started){
        for (NSString *aKey in [_downloaderDictionary allKeys]) {
            PvUrlSessionDownload *downloader = [_downloaderDictionary objectForKey:aKey];
            [downloader stop];
        }
        [btnstart setTitle:@"全部开始"];
    }else{
        for (NSString *aKey in [_downloaderDictionary allKeys]) {
            PvUrlSessionDownload *downloader = [_downloaderDictionary objectForKey:aKey];
            [downloader start];
        }
        [btnstart setTitle:@"全部停止"];
    }
    started = !started;
}

//更新下载百分比
- (void)updateVideo:(NSString *)vid percent:(float)percent{
    
    for (int i = 0; i < _videolist.count; ++i) {
        Video *video = [_videolist objectAtIndex:i];
        if ([video.vid isEqualToString:vid]) {
            video.percent = percent;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

//更新视频下载的速率
- (void)updateVideo:(NSString *)vid rate:(long)rate {
    
    for (int i = 0; i < _videolist.count; ++i) {
        Video *video = [_videolist objectAtIndex:i];
        if ([video.vid isEqualToString:vid]) {
            if (video.rate != rate) {   //和之前速率不相等时更新cell
                video.rate = rate;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if (_downloaderDictionary == nil) {
        _downloaderDictionary = [NSMutableDictionary new];
    }
    _videolist = [[FMDBHelper sharedInstance] listDownloadVideo];
    for (int i = 0;i < _videolist.count;  i++) {
        Video *video = [_videolist objectAtIndex:i];
        
        //只加入新增下载任务
        if ([_downloaderDictionary objectForKey:video.vid]==nil) {
            PvUrlSessionDownload *downloader = [[PvUrlSessionDownload alloc] initWithVid:video.vid level:video.level];
            //设置下载代理为自身，需要实现四个代理方法download delegate
            [downloader setDownloadDelegate:self];
            // 后台下载时完成回调
            [downloader setCompleteBlock:^{   
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if (appDelegate.backgroundSessionCompletionHandler) {
                    //need to copy the completion handler
                    void (^handler)() = appDelegate.backgroundSessionCompletionHandler;
                    appDelegate.backgroundSessionCompletionHandler = nil;
                    handler();  //执行代码块
                }
            }];
            
            [_downloaderDictionary setObject:downloader forKey:video.vid];
        }
    }
    [self.tableView reloadData];
	[super viewDidAppear:animated];
}

- (void)viewDidLoad {
    btnstart = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStyleBordered target:self action:@selector(startAll)];
    self.navigationItem.rightBarButtonItem = btnstart;
   
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    //_fmdb = [FMDBHelper sharedInstance];
    //_videolist = [_fmdb listDownloadVideo];
    
    [super viewDidLoad];

}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_videolist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Video *video = [_videolist objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //title
        UILabel *label_title =[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 20)] ;
        label_title.font = [UIFont systemFontOfSize:12];
        label_title.tag = 101;
        label_title.text = video.title;
        [cell.contentView addSubview:label_title];
        //filesize
        UILabel *label_filesize =[[UILabel alloc] initWithFrame:CGRectMake(120, 10, 100, 20)] ;
        label_filesize.tag = 102;
        label_filesize.font = [UIFont systemFontOfSize:12];
        label_filesize.text = [NSString stringWithFormat:@"大小:%@", [NSByteCountFormatter stringFromByteCount:video.filesize countStyle:NSByteCountFormatterCountStyleFile]];
        [cell.contentView addSubview:label_filesize];
        //percent
        UILabel *label_percent =[[UILabel alloc] initWithFrame:CGRectMake(220, 10, 120, 20)] ;
        label_percent.tag = 103;
        label_percent.font = [UIFont systemFontOfSize:12];
        label_percent.text = [NSString stringWithFormat:@"%.1f%%, %ldkb/s", video.percent, video.rate];
        
        [cell.contentView addSubview:label_percent];
        
    }else{
        UILabel *label_title = (UILabel *)[cell viewWithTag:101];
        label_title.text = video.title;
        
        UILabel *label_percent =(UILabel *)[cell viewWithTag:103];
        label_percent.text = [NSString stringWithFormat:@"%.1f%%, %ldkb/s", video.percent, video.rate];
        
        UILabel *label_filesize =(UILabel *)[cell viewWithTag:102];

        label_filesize.text = [NSString stringWithFormat:@"大小:%@", [NSByteCountFormatter stringFromByteCount:video.filesize countStyle:NSByteCountFormatterCountStyleFile]];
    }
    // Configure the cell...
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *video = [_videolist objectAtIndex:indexPath.row];
    if (!self.videoPlayer) {
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
		self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(0, 0, width, width*(9.0/16.0))];
		[self.videoPlayer configObserver];
		__weak typeof(self)weakSelf = self;
		[self.videoPlayer setDimissCompleteBlock:^{
			[weakSelf.videoPlayer stop];
			[weakSelf.videoPlayer cancel];
			[weakSelf.videoPlayer cancelObserver];
			weakSelf.videoPlayer = nil;
		}];
     }
     [self.videoPlayer setHeadTitle:video.title];
     [self.videoPlayer showInWindow];
      [self.videoPlayer setVid:video.vid level:0];
     //[self.videoPlayer setCurrentPlaybackRate:1.5f];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//删除视频
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *video = [_videolist objectAtIndex:indexPath.row];

    PvUrlSessionDownload *downloader = [_downloaderDictionary objectForKey:video.vid];
    if(downloader!=nil){
        [downloader stop];
        //删除任务需要执行清理下载URLSession，不然会再次加入任务的时候会报告session已经存在错误
        [downloader cleanSession];
        
        [_downloaderDictionary removeObjectForKey:video.vid];
    }
    
    //删除文件
    [PvUrlSessionDownload deleteVideo:video.vid level:video.level];
    
    [[FMDBHelper sharedInstance] removeDownloadVideo:video];
    [_videolist removeObject:video];
    [self.tableView reloadData];
}

//设置表格的编辑风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//表格是否能被编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark  download delegate

//下载完成
- (void)downloadDidFinished:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid{
    NSLog(@"finished %@", vid);
    
    [[FMDBHelper sharedInstance] updateDownloadPercent:vid percent:[NSNumber numberWithInt:100]];
    [[FMDBHelper sharedInstance] updateDownloadStatic:vid status:1];
}

//下载被停止
- (void)dataDownloadStop:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid{
	NSLog(@"stop - %@", vid);
}

//下载失败
- (void)dataDownloadFailed:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid reason:(NSString *)reason{
    [[FMDBHelper sharedInstance] updateDownloadStatic:vid status:-1];
     NSLog(@"dataDownloadFailed %@ - %@", vid, reason);
}

//实时获取下载进度百分比
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent: (NSNumber *)aPercent{
     [[FMDBHelper sharedInstance] updateDownloadPercent:vid percent:aPercent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateVideo:vid percent:[aPercent floatValue]];
        //NSLog(@"dataDownloadAtPercent%@", aPercent);
     });
}

//实时获取下载速率(下载开始之后此方法会一直被调用直到当前下载任务结束)
- (void)dataDownloadAtRate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid rate:(NSNumber *)aRate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateVideo:vid rate:[aRate longLongValue]];
    });
}

- (void)downloadTaskDidCreate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid{
	NSLog(@"%@ 任务创建", vid);
}

- (void)downloadDidStart:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid{
	NSLog(@"%@ 任务开始", vid);
}

#pragma mark - 页面旋转
- (BOOL)shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}
@end
