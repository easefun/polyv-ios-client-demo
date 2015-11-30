//
//  PLVResumableUpload.h
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PLVUploadResultBlock)(NSData* serverResponse);
typedef void (^PLVUploadFailureBlock)(NSError* error);
typedef void (^PLVUploadProgressBlock)(NSInteger bytesWritten, NSInteger bytesTotal);




@class PLVData;

@interface PLVResumableUpload : NSObject <NSURLConnectionDelegate>

@property (readwrite, copy) PLVUploadResultBlock resultBlock;
@property (readwrite, copy) PLVUploadFailureBlock failureBlock;
@property (readwrite, copy) PLVUploadProgressBlock progressBlock;

- (id)initWithURL:(NSString *)url
              data:(PLVData *)data
       fingerprint:(NSString *)fingerprint;

-(void)setExtraInfo:(NSMutableDictionary *)extraInfo;

- (void) start;

@end