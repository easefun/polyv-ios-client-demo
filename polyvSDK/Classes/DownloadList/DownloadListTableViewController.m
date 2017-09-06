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

@interface DownloadListTableViewController (){
	///是否已经开始下载
	BOOL _started;
}

@property (nonatomic, strong) SkinVideoViewController *videoPlayer;

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, strong) NSMutableDictionary *downloaderDictionary;
@property (nonatomic, strong) UIBarButtonItem *startButton;

@end

@implementation DownloadListTableViewController

#pragma mark - property

- (NSMutableDictionary *)downloaderDictionary {
    if (!_downloaderDictionary) {
        _downloaderDictionary = [NSMutableDictionary dictionary];
    }
    return _downloaderDictionary;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	self.startButton = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStylePlain target:self action:@selector(startAll)];
	self.navigationItem.rightBarButtonItem = self.startButton;
	
	//_fmdb = [FMDBHelper sharedInstance];
	//_videolist = [_fmdb listDownloadVideo];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleBackgroundSession:)
												 name:PLVBackgroundSessionUpdateNotification
											   object:nil];	
}



- (void)handleBackgroundSession:(NSNotification *)notification {
	// AppDelegate 执行 -application:handleEventsForBackgroundURLSession:completionHandler: 才把 block 属性赋值
	for (PvUrlSessionDownload *downloader in self.downloaderDictionary.allValues) {
		if ([notification.userInfo[PLVSessionIdKey] isEqualToString:downloader.sessionId]) {
			downloader.completeBlock = notification.userInfo[PLVBackgroundSessionCompletionHandlerKey];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
    self.videoList = [[FMDBHelper sharedInstance] listDownloadVideo];
    for (int i = 0;i < self.videoList.count;  i++) {
        Video *video = [self.videoList objectAtIndex:i];
        
        //只加入新增下载任务
        if (!self.downloaderDictionary[video.vid]) {
            PvUrlSessionDownload *downloader = [[PvUrlSessionDownload alloc] initWithVid:video.vid level:video.level];
            //设置下载代理为自身，需要实现四个代理方法download delegate
            [downloader setDownloadDelegate:self];
            self.downloaderDictionary[video.vid] = downloader;
        }
    }
    [self.tableView reloadData];
    [super viewDidAppear:animated];
}

#pragma mark -

- (void)startAll {
    //从数据库列表获取下载任务
    // _fmdb = [FMDBHelper sharedInstance];
    // _videolist = [_fmdb listDownloadVideo];
    
    if(_started) {
        for (NSString *aKey in [self.downloaderDictionary allKeys]) {
            PvUrlSessionDownload *downloader = self.downloaderDictionary[aKey];
            [downloader stop];
        }
        [self.startButton setTitle:@"全部开始"];
    } else {
        for (NSString *aKey in [self.downloaderDictionary allKeys]) {
            PvUrlSessionDownload *downloader = self.downloaderDictionary[aKey];
            [downloader start];
        }
        [self.startButton setTitle:@"全部停止"];
    }
    _started = !_started;
}

//更新下载百分比
- (void)updateVideo:(NSString *)vid percent:(float)percent {
    for (int i = 0; i < self.videoList.count; ++i) {
        Video *video = [self.videoList objectAtIndex:i];
        if ([video.vid isEqualToString:vid]) {
            video.percent = percent;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
}

//更新视频下载的速率
- (void)updateVideo:(NSString *)vid rate:(long)rate {
    for (int i = 0; i < self.videoList.count; ++i) {
        Video *video = [self.videoList objectAtIndex:i];
        if ([video.vid isEqualToString:vid]) {
            if (video.rate != rate) {   //和之前速率不相等时更新cell
                video.rate = rate;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.videoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"downloadItemCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	Video *video = [self.videoList objectAtIndex:indexPath.row];
	
	UILabel *label_title = (UILabel *)[cell viewWithTag:101];
	label_title.text = video.title;
	
	UILabel *label_percent =(UILabel *)[cell viewWithTag:103];
	label_percent.text = [NSString stringWithFormat:@"%.1f%%, %ldkb/s", video.percent, video.rate];
	
	UILabel *label_filesize =(UILabel *)[cell viewWithTag:102];
	
	label_filesize.text = [NSString stringWithFormat:@"大小:%@", [NSByteCountFormatter stringFromByteCount:video.filesize countStyle:NSByteCountFormatterCountStyleFile]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Video *video = [self.videoList objectAtIndex:indexPath.row];
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
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//删除视频
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	Video *video = [self.videoList objectAtIndex:indexPath.row];
	
	PvUrlSessionDownload *downloader = self.downloaderDictionary[video.vid];
	if(downloader!=nil) {
		[downloader stop];
		//删除任务需要执行清理下载URLSession，不然会再次加入任务的时候会报告session已经存在错误
		[downloader cleanSession];
		
		[self.downloaderDictionary removeObjectForKey:video.vid];
	}
	
	//删除文件
	[PvUrlSessionDownload deleteVideo:video.vid level:video.level];
	
	[[FMDBHelper sharedInstance] removeDownloadVideo:video];
	[self.videoList removeObject:video];
	[self.tableView reloadData];
}

//设置表格的编辑风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

//表格是否能被编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

#pragma mark  download delegate

// 下载失败回调
- (void)dataDownloadFailed:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid reason:(NSString *)reason {
	[[FMDBHelper sharedInstance] updateDownloadStatic:vid status:-1];
	NSLog(@"dataDownloadFailed %@ - %@", vid, reason);
}

// 实时获取下载进度百分比回调
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent: (NSNumber *)aPercent {
	[[FMDBHelper sharedInstance] updateDownloadPercent:vid percent:aPercent];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateVideo:vid percent:[aPercent floatValue]];
		//NSLog(@"dataDownloadAtPercent%@", aPercent);
	});
}

// 实时下载速率回调
- (void)dataDownloadAtRate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid rate:(NSNumber *)aRate {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateVideo:vid rate:[aRate longLongValue]];
	});
}

// 下载状态回调
- (void)downloader:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid didChangeDownloadState:(PLVDownloadState)state {
    switch (state) {
        case PLVDownloadStatePreparing:{
            
        }break;
        case PLVDownloadStateReady:{
            NSLog(@"%@ 任务创建", vid);
        }break;
        case PLVDownloadStateRunning:{
            NSLog(@"%@ 任务开始", vid);
        }break;
        case PLVDownloadStateStopping:{
            NSLog(@"%@ 正在停止", vid);
        }break;
        case PLVDownloadStateStopped:{
            NSLog(@"%@ 任务停止", vid);
        }break;
        case PLVDownloadStateSuccess:{
           NSLog(@"%@ 任务完成", vid);
            
            [[FMDBHelper sharedInstance] updateDownloadPercent:vid percent:[NSNumber numberWithInt:100]];
            [[FMDBHelper sharedInstance] updateDownloadStatic:vid status:1];
        }break;
        case PLVDownloadStateFailed:{
            
        }break;
        default:{}break;
    }
}

#pragma mark - 页面旋转
- (BOOL)shouldAutorotate {
	return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return UIInterfaceOrientationPortrait;
}
@end
