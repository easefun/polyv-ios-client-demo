//
//  DetailViewController.m
//  polyvSDK
//
//  Created by seanwong on 10/23/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import "DetailViewController2.h"
#import "SkinVideoViewController.h"
#import "PvVideo.h"
#import "PolyvSettings.h"
@interface DetailViewController2 ()

@property (nonatomic, strong)  SkinVideoViewController*videoPlayer;

@end


@implementation DetailViewController2

/*- (BOOL)shouldAutorotate {
 return NO;
 }
 
 - (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
 return UIInterfaceOrientationPortrait;
 }
 */


-(BOOL)shouldAutorotate{
    return NO;
}
-(NSInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    //return YES;
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification{
    NSLog(@"finished");
}

-(void)movieLoadStateDidChange:(NSNotification *)notification{
    
}

-(void)viewDidDisappear:(BOOL)animated {
    self.isPresented = YES;
    [self.videoPlayer stop];
    [self.videoPlayer cancel];
    [self.videoPlayer cancelObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}


- (void) showConfirmationAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"流量提示"
                                                   message:@"3G网络下继续播放?"
                                                  delegate:self
                                         cancelButtonTitle:@"停止播放"
                                         otherButtonTitles:@"继续播放",nil];
    [alert show];
    
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 0 = Tapped yes
    if (buttonIndex == 0)
    {
        // ....
        [self.videoPlayer stop];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.isPresented = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.videoPlayer configObserver];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoadStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
}


- (void)viewDidLoad {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = self.view.bounds.size.width;
    
    
    if (!self.videoPlayer) {
        self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, width*(9.0/16.0))];
        //self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, 100)];
    }
    
    
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer setParentViewController:self];
    //需要保留导航栏
    [self.videoPlayer keepNavigationBar:YES];
    [self.videoPlayer setHeadTitle:self.video.title];
    //开启片头播放
    //[self.videoPlayer enableTeaser:YES];
    [self.videoPlayer setNavigationController:self.navigationController];
    [self.videoPlayer setVid:self.video.vid];
    //直接跳到上一次播放位置
    //[self.videoPlayer setWatchStartTime:380];
    [self.videoPlayer play];
    //UIImage*logo = [UIImage imageNamed:@"pvlogo.png"];
    
    //[self.videoPlayer setLogo:logo location:PvLogoLocationTopLeft size:CGSizeMake(70,30) alpha:0.8];
    

    
    [self.videoPlayer setFullscreenBlock:^{
        NSLog(@"should hide toolbox in this viewcontroller if needed");
    }];
    [self.videoPlayer setShrinkscreenBlock:^{
        NSLog(@"show toolbox back if needed");
    }];
    
    
    //[self showConfirmationAlert];

    
    
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
