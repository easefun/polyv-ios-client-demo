//
//  ShareDownloader.h
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoDownloader.h"
@interface ShareDownloader : NSObject<DownloadDelegate>


+ (id)sharedInstance;
-(VideoDownloader*)getDownloader:(NSString*)vid withLevel:(int)level;

@end
