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
- (void) downloadDidFinished: (NSString *) aName;
- (void) dataDownloadFailed: (NSString *) reason;
- (void) dataDownloadAtPercent: (NSNumber *) aPercent;
@end
