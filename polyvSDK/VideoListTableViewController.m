//
//  VideoListTableViewController.m
//  polyvSDK
//
//  Created by seanwong on 8/16/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import "VideoListTableViewController.h"
#import "Video.h"
#import "PolyvSettings.h"
#import "SkinVideoViewController.h"
#import "FMDBHelper.h"
#import "DetailViewController.h"
#import "DetailViewController2.h"



@interface VideoListTableViewController (){
    
    NSMutableArray *_videolist;
    Video*_video;
    FMDBHelper *_fmdb;
}
@property (nonatomic, strong) SkinVideoViewController *videoPlayer;

@end



@implementation VideoListTableViewController


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.navigationController.navigationBarHidden = NO;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}


- (void)viewDidLoad {
    NSLog(@"download dir:%@",[[PolyvSettings sharedInstance]getDownloadDir]);
    
    _videolist = [NSMutableArray array];
    _fmdb = [FMDBHelper sharedInstance];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://v.polyv.net/uc/services/rest?method=getNewList&readtoken=%@&pageNum=1&numPerPage=20",PolyvReadtoken]]];
    [request setURL:[NSURL URLWithString:@"http://demo.polyv.net/data/video.js"]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(data!=nil){
            NSDictionary * jsondata = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&error];
            
            NSMutableArray *videos = [jsondata objectForKey:@"data"];
            for(int i=0;i<videos.count;i++){
                NSDictionary*item = [videos objectAtIndex:i];
                Video *video = [[Video alloc] init];
                video.title = [item objectForKey:@"title"];
                video.desc = [item objectForKey:@"context"];
                video.vid = [item objectForKey:@"vid"];
                video.duration = [item objectForKey:@"duration"];
                video.piclink = [item objectForKey:@"first_image"];
                video.df = [[item objectForKey:@"df"] intValue];
                video.seed = [[item objectForKey:@"seed"] intValue];
                video.allfilesize = [item objectForKey:@"filesize"];
                
                [_videolist addObject:video];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        
        
        
        
    }] resume];
    
    
    /*Video *v = [[Video alloc] initWithVid:@"sl8da4jjbxc29d633ebb53ba79ded0f4_s"];
    NSLog(@"%@",[v.allfilesize objectAtIndex:0]); */
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCellIdentifier"];

    Video*video = [_videolist objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:103];
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:video.piclink]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        imageView.image = [UIImage imageWithData:data];
    }];
    

    UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
    titleLabel.text = video.title;
    
    UILabel *descLabel = (UILabel *)[cell viewWithTag:102];
    descLabel.text = video.desc;
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:105];
    if (video.seed == 1) {
        typeLabel.text = @"加密";
    }else{
        typeLabel.text = @"";
    }
    
    
    
    
    UIButton * btn = (UIButton *)[cell viewWithTag:104];
    btn.tag = indexPath.row;
    
    //NSLog(@"%d - %@",indexPath.row,video.title);
    [btn addTarget:self action:@selector(downloadClick:) forControlEvents:UIControlEventTouchDown];

    
    return cell;
}

-(void)downloadClick:(UIButton*)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    _video = [_videolist objectAtIndex:indexPath.row];
    switch (_video.allfilesize.count) {
        case 1:
            [[[UIAlertView alloc] initWithTitle:@"选择要下载的码率"
                                        message:@"您要下载哪个清晰度的视频?"
                                       delegate:self
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"流畅", nil] show];
            break;
        case 2:
            [[[UIAlertView alloc] initWithTitle:@"选择要下载的码率"
                                        message:@"您要下载哪个清晰度的视频?"
                                       delegate:self
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"流畅", @"高清", nil] show];
            break;
            
        default:
            [[[UIAlertView alloc] initWithTitle:@"选择要下载的码率"
                                        message:@"您要下载哪个清晰度的视频?"
                                       delegate:self
                              cancelButtonTitle:@"取消"
                              otherButtonTitles:@"流畅", @"高清", @"超清",nil] show];
            break;
    }
    
    
    
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
    }
    else if(buttonIndex == 1)
    {
        _video.level = 1;
        _video.filesize = [[_video.allfilesize objectAtIndex:0]longLongValue];
        [_fmdb addDownloadVideo:_video];
        
    }
    else if(buttonIndex == 2)
    {
        _video.level = 2;
        _video.filesize = [[_video.allfilesize objectAtIndex:1]longLongValue];

        [_fmdb addDownloadVideo:_video];
    }else{
        _video.level = 3;
        _video.filesize = [[_video.allfilesize objectAtIndex:2]longLongValue];
        [_fmdb addDownloadVideo:_video];
    }
    //NSLog(@"%lld",_video.filesize);
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Video *video = [_videolist objectAtIndex:indexPath.row];
    /*if (!self.videoPlayer) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(0, 0, width, width*(9.0/16.0))];
        __weak typeof(self)weakSelf = self;
        [self.videoPlayer setDimissCompleteBlock:^{
            [weakSelf.videoPlayer stop];
            weakSelf.videoPlayer = nil;
        }];
        
    }
    [self.videoPlayer setHeadTitle:@"陕西高校舞蹈女教师夜跑失踪 尸体已被找到陕西高校舞蹈女教师夜跑失踪 尸体已被找到陕西高校舞蹈女教师夜跑失踪 尸体已被找到"];
    [self.videoPlayer showInWindow];
    [self.videoPlayer setVid:video.vid];
    
   */
    
    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:[NSBundle mainBundle]];
    
    //去除navigationBar
//    DetailViewController *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailViewController"];
	
    //保留navigationBar
    DetailViewController2 *detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"detailViewController2"];
	
    detailViewController.video = video;
    
    detailViewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    

    
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
- (BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}



@end
