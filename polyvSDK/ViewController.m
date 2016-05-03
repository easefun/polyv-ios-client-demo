//
//  ViewController.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)buttonOnTouched:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonOnTouched:(id)sender {
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    //NSLog(@"before present %d",[UIApplication sharedApplication].statusBarOrientation);
    //[self presentViewController:[SecondViewController new] animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    //NSLog(@"root preferredInterfaceOrientationForPresentation");
    return UIInterfaceOrientationPortrait;
}
@end
