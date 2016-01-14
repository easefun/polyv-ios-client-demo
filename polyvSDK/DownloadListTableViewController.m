//
//  DownloadListTableViewController.m
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import "DownloadListTableViewController.h"
#import "FMDBHelper.h"
#import "Video.h"
#import "SkinVideoViewController.h"
#import "PolyvSettings.h"

@interface DownloadListTableViewController (){
    NSMutableArray *_videolist;
    NSMutableDictionary *_downloaderDictionary;
    FMDBHelper *_fmdb;
    UIBarButtonItem *btnstart;
    BOOL started;
    NSTimer *_updateTimer;
    NSString* currentVid;
}

@property (nonatomic, strong) SkinVideoViewController *videoPlayer;

@end

@implementation DownloadListTableViewController



-(void)startAll{
    //从数据库列表获取下载任务
    _fmdb = [FMDBHelper sharedInstance];
    _videolist = [_fmdb listDownloadVideo];
    for (int i=0;i<_videolist.count;  i++) {
        Video*video = [_videolist objectAtIndex:i];
        //只加入新增任务
        if ([_downloaderDictionary objectForKey:video.vid]==nil) {
            PvUrlSessionDownload* downloader = [[PvUrlSessionDownload alloc]initWithVid:video.vid level:video.level];
            [_downloaderDictionary setObject:downloader forKey:video.vid];
            [downloader setDownloadDelegate:self];
        }
        
        
    }
    
    
    if(started){
        for (NSString *aKey in [_downloaderDictionary allKeys]) {
            PvUrlSessionDownload*downloader=[_downloaderDictionary objectForKey:aKey];
            [downloader stop];
        }
        [_updateTimer invalidate];
        [btnstart setTitle:@"全部开始"];
    }else{
        for (NSString *aKey in [_downloaderDictionary allKeys]) {
            PvUrlSessionDownload*downloader=[_downloaderDictionary objectForKey:aKey];
            [downloader start];
        }
        [_updateTimer invalidate];
        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTable) userInfo:nil repeats:YES];
        [btnstart setTitle:@"全部停止"];
    }
    started = !started;
 
    
}
-(void)updateTable{
    _videolist = [_fmdb listDownloadVideo];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [self updateTable];
}
- (void)viewDidLoad {
    _downloaderDictionary = [NSMutableDictionary new];

    btnstart = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStyleBordered target:self action:@selector(startAll)];
    self.navigationItem.rightBarButtonItem = btnstart;
   
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    _fmdb = [FMDBHelper sharedInstance];
    _videolist = [_fmdb listDownloadVideo];
    
    
    [super viewDidLoad];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_videolist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Video*video = [_videolist objectAtIndex:indexPath.row];
    
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
        label_filesize.text = [NSString stringWithFormat:@"大小:%lld",video.filesize ];
        [cell.contentView addSubview:label_filesize];
        //percent
        UILabel *label_percent =[[UILabel alloc] initWithFrame:CGRectMake(220, 10, 120, 20)] ;
        label_percent.tag = 103;
        label_percent.font = [UIFont systemFontOfSize:12];
        label_percent.text = [NSString stringWithFormat:@"进度:%d%%",video.percent];
        
        [cell.contentView addSubview:label_percent];

        
        
        
    }else{
        UILabel *label_title = (UILabel*)[cell viewWithTag:101];
        label_title.text = video.title;
        
        UILabel *label_percent =(UILabel*)[cell viewWithTag:103];
        label_percent.text = [NSString stringWithFormat:@"进度:%d%%",video.percent];
        
        UILabel *label_filesize =(UILabel*)[cell viewWithTag:102];
        label_filesize.text = [NSString stringWithFormat:@"大小:%lld",video.filesize ];
        
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
     __weak typeof(self)weakSelf = self;
     [self.videoPlayer setDimissCompleteBlock:^{
     [weakSelf.videoPlayer stop];
     weakSelf.videoPlayer = nil;
     }];
     
     }
     [self.videoPlayer setHeadTitle:video.title];
     [self.videoPlayer showInWindow];
     [self.videoPlayer setVid:video.vid level:video.level];

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *video = [_videolist objectAtIndex:indexPath.row];

    [_fmdb removeDownloadVideo:video];
    PvUrlSessionDownload * downloader = [_downloaderDictionary objectForKey:video.vid];
    if(downloader!=nil){
        [_downloaderDictionary removeObjectForKey:video.vid];
        [downloader stop];
        //删除任务需要执行清理下载URLSession，不然会再次加入任务的时候会报告session已经存在错误
        [downloader cleanSession];
    }
    
    
    
    //删除文件
    [PvUrlSessionDownload deleteVideo:video.vid level:video.level];
    
    [self updateTable];

}

    
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma download delegate

- (void) downloadDidFinished:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid{
    NSLog(@"finished %@",vid);
    
    [_fmdb updateDownloadPercent:vid percent:[NSNumber numberWithInt:100]];
    [_fmdb updateDownloadStatic:vid status:1];
    
    
    

   
}
- (void) dataDownloadStop:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid{
    
}
- (void) dataDownloadFailed:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid reason:(NSString *) reason{
    [_fmdb updateDownloadStatic:vid status:-1];
}
- (void) dataDownloadAtPercent:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid percent: (NSNumber *) aPercent{
     [_fmdb updateDownloadPercent:vid percent:aPercent];

}



@end
