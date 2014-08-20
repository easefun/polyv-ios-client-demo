//
//  ViewController.m
//  polyvSDK
//
//  Created by seanwong on 7/10/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "ViewController.h"
#import "PolyvPlayerDemoViewController.h"
#import "PolyvPlayerViewController.h"

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
    PolyvPlayerDemoViewController *playerController = [[PolyvPlayerDemoViewController alloc] init];
    //PolyvPlayerViewController *playerController = [[PolyvPlayerViewController alloc] initWithReadtoken:@"" andVid:@"sl8da4jjbxafdfdd5713a9bf756e35e4_s" delegate:self];
    
    //PolyvPlayerDemoViewController *playerController = [[PolyvPlayerDemoViewController alloc] initWithReadtoken:@"" andVid:@"sl8da4jjbxafdfdd5713a9bf756e35e4_s" delegate:self];
    
    [self presentViewController:playerController animated:YES completion:nil];
}
@end
