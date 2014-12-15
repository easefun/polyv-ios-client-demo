//
//  AVVideoMixCenter.h
//  KukuVedio
//
//  Created by junpeng on 14-7-5.
//  Copyright (c) 2014年 junpeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


@protocol AVVideoMixCenterDelegate <NSObject>

@optional
- (void)avVideoMixDidFinished:(AVAssetExportSession*)session;
- (void)avVideoMixDidFailed:(NSError *)error;

@end

@interface AVVideoMixCenter : NSObject

- (void)renderSizeWithPath:(NSString *)filePath
            outputFileName:(NSString *)outputfilename
                  Delegate:(id<AVVideoMixCenterDelegate>)delegate;

- (void)compositionWithFilepath:(NSString *)savepath
                 outputFileName:(NSString *)outputfilename
                       Delegate:(id<AVVideoMixCenterDelegate>)delegate;
@end
