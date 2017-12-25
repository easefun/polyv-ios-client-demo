//
//  PLVDownloadItemCell.h
//  polyvSDK
//
//  Created by Bq Lin on 2017/12/25.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"

@interface PLVDownloadItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@property (nonatomic, strong) Video *video;

@end
