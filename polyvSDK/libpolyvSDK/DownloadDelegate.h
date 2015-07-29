//
//  DownloadDelegate.h
//  hlsplay
//
//  Created by seanwong on 4/22/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VideoDownloader;

@protocol DownloadDelegate <NSObject>
@optional
- (void) downloadDidFinished:(VideoDownloader*)downloader withVid:(NSString *)vid;
- (void) dataDownloadFailed:(VideoDownloader*)downloader withVid:(NSString *)vid reason:(NSString *) reason;
- (void) dataDownloadAtPercent:(VideoDownloader*)downloader withVid:(NSString *)vid percent: (NSNumber *) aPercent;
@end
