//
//  DownloadDelegate.h
//  hlsplay
//
//  Created by seanwong on 4/22/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadDelegate <NSObject>
@optional
- (void) downloadDidFinished: (NSString *)vid;
- (void) dataDownloadFailed: (NSString *)vid reason:(NSString *) reason;
- (void) dataDownloadAtPercent:(NSString *)vid percent: (NSNumber *) aPercent;
@end
