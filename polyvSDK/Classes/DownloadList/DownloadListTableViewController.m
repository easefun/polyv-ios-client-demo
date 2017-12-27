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
#import "PLVDownloadItemCell.h"

@interface DownloadListTableViewController (){
	///是否已经开始下载
	BOOL _started;
}

@property (nonatomic, strong) SkinVideoViewController *videoPlayer;
@property (nonatomic, strong) UIBarButtonItem *startButton;

@property (nonatomic, strong) NSMutableArray<Video *> *videos;
@property (nonatomic, strong) NSMutableDictionary<NSString *, Video *> *videoDic;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PLVDownloadItemCell *> *downloadItemCellDic;

@property (nonatomic, strong) NSMutableDictionary *downloaderDic;

@property (nonatomic, strong) NSDate *lastTime;

@end

@implementation DownloadListTableViewController

- (void)dealloc {
	for (Video *video in self.videos) {
		[[FMDBHelper sharedInstance] updateDownloadPercent:video.vid percent:@(video.percent)];
	}
}

#pragma mark - property

- (NSMutableDictionary *)downloaderDic {
    if (!_downloaderDic) {
        _downloaderDic = [NSMutableDictionary dictionary];
    }
    return _downloaderDic;
}

- (NSDate *)lastTime {
	if (!_lastTime) {
		_lastTime = [NSDate date];
	}
	return _lastTime;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	self.startButton = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStylePlain target:self action:@selector(startAll)];
	self.navigationItem.rightBarButtonItem = self.startButton;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBackgroundSession:) name:PLVBackgroundSessionUpdateNotification object:nil];
}

- (void)reloadData {
	self.videos = [[FMDBHelper sharedInstance] listDownloadVideo];
	self.videoDic = [NSMutableDictionary dictionary];
	self.downloadItemCellDic = [NSMutableDictionary dictionary];
	for (int i = 0;i < self.videos.count;  i++) {
		Video *video = self.videos[i];
		self.videoDic[video.vid] = video;
		
		//只加入新增下载任务
		if (!self.downloaderDic[video.vid]) {
			PvUrlSessionDownload *downloader = [[PvUrlSessionDownload alloc] initWithVid:video.vid level:video.level];
			//设置下载代理为自身，需要实现四个代理方法download delegate
			[downloader setDownloadDelegate:self];
			self.downloaderDic[video.vid] = downloader;
		}
		
		// 配置cell
		static NSString *CellIdentifier = @"downloadItemCell";
		PLVDownloadItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		cell.video = video;
		self.downloadItemCellDic[video.vid] = cell;
	}
	[self.tableView reloadData];
}

- (void)handleBackgroundSession:(NSNotification *)notification {
	// AppDelegate 执行 -application:handleEventsForBackgroundURLSession:completionHandler: 才把 block 属性赋值
	for (PvUrlSessionDownload *downloader in self.downloaderDic.allValues) {
		if ([notification.userInfo[PLVSessionIdKey] isEqualToString:downloader.sessionId]) {
			downloader.completeBlock = notification.userInfo[PLVBackgroundSessionCompletionHandlerKey];
		}
	}
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self reloadData];
}

#pragma mark -

- (void)startAll {
    if(_started) {
        for (NSString *aKey in [self.downloaderDic allKeys]) {
            PvUrlSessionDownload *downloader = self.downloaderDic[aKey];
            [downloader stop];
        }
        [self.startButton setTitle:@"全部开始"];
    } else {
        for (NSString *aKey in [self.downloaderDic allKeys]) {
            PvUrlSessionDownload *downloader = self.downloaderDic[aKey];
            [downloader start];
        }
        [self.startButton setTitle:@"全部停止"];
    }
    _started = !_started;
	
	// 更新进度到数据库
	for (Video *video in self.videos) {
		[[FMDBHelper sharedInstance] updateDownloadPercent:video.vid percent:@(video.percent)];
	}
}

- (void)updateCellWithVid:(NSString *)vid {
	Video *video = self.videoDic[vid];
	PLVDownloadItemCell *cell = self.downloadItemCellDic[vid];
	if (!video || !cell) return;
	cell.video = video;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.videos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.downloadItemCellDic[self.videos[indexPath.row].vid];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Video *video = [self.videos objectAtIndex:indexPath.row];
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
	Video *video = [self.videos objectAtIndex:indexPath.row];
	
	PvUrlSessionDownload *downloader = self.downloaderDic[video.vid];
	if(downloader!=nil) {
		[downloader stop];
		//删除任务需要执行清理下载URLSession，不然会再次加入任务的时候会报告session已经存在错误
		[downloader cleanSession];
		
		[self.downloaderDic removeObjectForKey:video.vid];
	}
	
	//删除文件
	[PvUrlSessionDownload deleteVideo:video.vid level:video.level];
	
	[[FMDBHelper sharedInstance] removeDownloadVideo:video];
	[self.videos removeObject:video];
	[self.tableView reloadData];
}

//设置表格的编辑风格
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}
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
- (void)dataDownloadAtPercent:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid percent:(NSNumber *)aPercent {
	// !!!: 频繁写入数据库会造成UI卡顿风险，因此此处是隔3秒更新一次数据库
	NSTimeInterval timeDiff = [[NSDate date] timeIntervalSinceDate:self.lastTime];
	if (timeDiff > 3) {
		[[FMDBHelper sharedInstance] updateDownloadPercent:vid percent:aPercent];
		self.lastTime = [NSDate date];
	}
	
	Video *video = self.videoDic[vid];
	video.percent = aPercent.floatValue;
	[self updateCellWithVid:vid];
}

// 实时下载速率回调
- (void)dataDownloadAtRate:(PvUrlSessionDownload *)downloader withVid:(NSString *)vid rate:(NSNumber *)aRate {
	Video *video = self.videoDic[vid];
	video.rate = aRate.floatValue;
	[self updateCellWithVid:vid];
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
