//
//  PLVKit.h
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#define PLV_LOGGING_ENABLED 1
#if PLV_LOGGING_ENABLED
    #define PLVLog( s, ... ) NSLog( @"<%@:(%d)> %@", \
        [[NSString stringWithUTF8String:__FILE__] lastPathComponent], \
        __LINE__, \
        [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
    #define PLVLog( s, ... ) ;
#endif

#import "PLVData.h"
#import "PLVAssetData.h"
#import "PLVResumableUpload.h"
