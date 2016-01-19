//
//  DetailViewController.m
//  polyvSDK
//
//  Created by seanwong on 10/23/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import "DetailViewController2.h"
#import "SkinVideoViewController.h"

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

-(void)viewDidDisappear:(BOOL)animated {
    self.isPresented = YES;
    [self.videoPlayer pause];
    
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    self.isPresented = NO;
    
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.videoPlayer play];
}


- (void)viewDidLoad {
    //
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat width = self.view.bounds.size.width;
    self.videoPlayer = [[SkinVideoViewController alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, width, width*(9.0/16.0))];
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer setParentViewController:self];
    //需要保留导航栏
    [self.videoPlayer keepNavigationBar:YES];
    [self.videoPlayer setNavigationController:self.navigationController];
    [self.videoPlayer setVid:self.video.vid level:1];
    
    [self.videoPlayer setFullscreenBlock:^{
        NSLog(@"should hide toolbox in this viewcontroller if needed");
    }];
    [self.videoPlayer setShrinkscreenBlock:^{
        NSLog(@"show toolbox back if needed");
    }];
    
    
    
    
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
