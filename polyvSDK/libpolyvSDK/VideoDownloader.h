//
//  M3U8Downloader.h
//  hlsplay
//
//  Created by seanwong on 4/9/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadDelegate.h"
@interface VideoDownloader : NSObject

-(void)stop;
- (void)start:(NSString*)vid level:(int)level;
-(void)setDownloadDelegate:(id<DownloadDelegate>)delegate;
-(void)deleteVideo:(NSString*)vid level:(int)level;
@end
