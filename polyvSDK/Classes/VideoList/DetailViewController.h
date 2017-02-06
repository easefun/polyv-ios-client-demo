//
//  DetailViewController.h
//  polyvSDK
//
//  Created by seanwong on 10/23/15.
//  Copyright © 2015 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"

@interface DetailViewController : UIViewController
@property (nonatomic, strong) Video* video;
@property (assign, nonatomic) BOOL isPresented;

@end
