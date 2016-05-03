//
//  PvUrlSessionDownloadDelegate.h
//  polyvSDK
//
//  Created by seanwong on 11/6/15.
//  Copyright © 2015 easefun. All rights reserved.
//

@class PvUrlSessionDownload;

@protocol PvUrlSessionDownloadDelegate <NSObject>
@optional
- (void) downloadDidFinished:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid;
- (void) dataDownloadStop:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid;
- (void) dataDownloadFailed:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid reason:(NSString *) reason;
- (void) dataDownloadAtPercent:(PvUrlSessionDownload*)downloader withVid:(NSString *)vid percent: (NSNumber *) aPercent;

@end
