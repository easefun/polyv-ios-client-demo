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
#import "ShareDownloader.h"
@interface DownloadListTableViewController (){
    NSMutableArray *_videolist;
    FMDBHelper *_fmdb;
    NSTimer *updateTimer;
    UIBarButtonItem *btnstart;
    BOOL started;
}

@end

@implementation DownloadListTableViewController

-(void)startall{
    
    ShareDownloader* manager = [ShareDownloader sharedInstance];
    for (int i=0;i<[_videolist count]; i++) {
        Video*video = [_videolist objectAtIndex:i];
        VideoDownloader*downloader=[manager getDownloader:video.vid withLevel:video.level];
        if(!started){
            [downloader start:video.vid level:video.level];
        }else{
            [downloader stop];
        }
        
    }
    started = !started;
    if(started){
        [btnstart setTitle:@"全部停止"];
    }else{
        [btnstart setTitle:@"全部开始"];
    }
    
}
-(void)updateTable{
    _fmdb = [FMDBHelper sharedInstance];
    _videolist = [_fmdb listDownloadVideo];
    //NSLog(@"update timer");
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [self updateTable];
    
    btnstart = [[UIBarButtonItem alloc] initWithTitle:@"全部开始" style:UIBarButtonItemStyleBordered target:self action:@selector(startall)];
    self.navigationItem.rightBarButtonItem = btnstart;
    [updateTimer invalidate];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTable) userInfo:nil repeats:YES];

    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
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

@end
