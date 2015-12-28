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

@interface DownloadListTableViewController (){
    NSMutableArray *_videolist;
    FMDBHelper *_fmdb;
    NSTimer *updateTimer;
    UIBarButtonItem *btnstart;
    BOOL started;
    int _currentTask;
    PvUrlSessionDownload * _downloader;
}

@property (nonatomic, strong) SkinVideoViewController *videoPlayer;

@end

@implementation DownloadListTableViewController



-(void)startNext{
    
   
    
    if(started){
        [_downloader stop];
        [btnstart setTitle:@"全部开始"];
    }else{
        if ([_videolist count]>0 && _currentTask<[_videolist count]) {
            Video*video = [_videolist objectAtIndex:_currentTask];
            [_downloader startNewDownlaodVideo:video.vid level:video.level];
        }else{
            NSLog(@"所有任务已经完成");
            
        }
        [btnstart setTitle:@"全部停止"];
    }
    started = !started;

    
    
    
    

   
    
    
}
-(void)updateTable{
    _fmdb = [FMDBHelper sharedInstance];
    _videolist = [_fmdb listDownloadVideo];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [self updateTable];
    _currentTask = 0;
    btnstart = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStyleBordered target:self action:@selector(startNext)];
    self.navigationItem.rightBarButtonItem = btnstart;
    [updateTimer invalidate];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTable) userInfo:nil repeats:YES];

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    _downloader=[PvUrlSessionDownload sharedInstance];
    [_downloader setDownloadDelegate:self];
    
    
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma download delegate

- (void) downloadDidFinished:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid{
    NSLog(@"finished %@",vid);
    [_fmdb updateDownloadPercent:vid percent:[NSNumber numberWithInt:100]];
    [_fmdb updateDownloadStatic:vid status:1];
    _currentTask++;
    started = false;
    [self startNext];
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
