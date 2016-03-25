//
//  DetailViewController.m
//  polyvSDK
//
//  Created by seanwong on 10/23/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import "DetailViewController.h"
#import "SkinVideoViewController.h"

@interface DetailViewController ()

@property (nonatomic, strong)  SkinVideoViewController*videoPlayer;

@end


@implementation DetailViewController

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

-(void)viewDidDisappear:(BOOL)animated {
    self.isPresented = YES;
    [self.videoPlayer stop];
    [self.videoPlayer cancelObserver];
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    self.isPresented = NO;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.videoPlayer configObserver];
    
    [self.videoPlayer play];
	[super viewWillAppear:animated];
}


- (void)viewDidLoad {
    
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    CGFloat width = self.view.bounds.size.width;
    if (!self.videoPlayer) {
        self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(0, 0, width, width*(9.0/16.0))];
    }
    [self.videoPlayer setHeadTitle:self.video.title];
    UIImage*logo = [UIImage imageNamed:@"pvlogo.png"];
    [self.videoPlayer setLogo:logo location:PvLogoLocationTopLeft size:CGSizeMake(70,30) alpha:0.8];
    
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer setParentViewController:self];
    [self.videoPlayer setNavigationController:self.navigationController];
    [self.videoPlayer setVid:self.video.vid];
    [self.videoPlayer play];
    //直接跳到上一次播放位置
    //[self.videoPlayer setWatchStartTime:30];
    
    
    
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
