//
//  PLVDownloadItemCell.m
//  polyvSDK
//
//  Created by Bq Lin on 2017/12/25.
//  Copyright © 2017年 easefun. All rights reserved.
//

#import "PLVDownloadItemCell.h"

@implementation PLVDownloadItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setVideo:(Video *)video {
	_video = video;
	dispatch_async(dispatch_get_main_queue(), ^{
		self.titleLabel.text = video.title;
		self.sizeLabel.text = [NSString stringWithFormat:@"大小:%@", [NSByteCountFormatter stringFromByteCount:video.filesize countStyle:NSByteCountFormatterCountStyleFile]];
		self.progressLabel.text = [NSString stringWithFormat:@"%.1f%%, %ldkb/s", video.percent, video.rate];
	});
}

@end
