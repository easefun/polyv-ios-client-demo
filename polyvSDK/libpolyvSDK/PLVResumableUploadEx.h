//
//  PLVResumableUploadEx.h
//  VideoOnline
//
//  Created by Goman on 14-12-12.
//  Copyright (c) 2014年 Goman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLVResumableUpload.h"
@interface PLVResumableUploadEx : NSObject
-(void) startWithCompress;
@property (readwrite, copy) PLVUploadResultBlock resultBlock;
@property (readwrite, copy) PLVUploadFailureBlock failureBlock;
@property (readwrite, copy) PLVUploadProgressBlock progressBlock;

- (id)initWithURL:(NSString *)url
         filePath:(NSString *) filePath
      fingerprint:(NSString *)fingerprint;

-(void)setExtraInfo:(NSMutableDictionary *)extraInfo;

@end
