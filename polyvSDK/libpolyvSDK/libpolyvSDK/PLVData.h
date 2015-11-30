//
//  PLVData.h
//  PLV-ios-client-demo
//
//  Created by Polyv.net.
//  Copyright (c) 2013 PLV.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLVData : NSObject <NSStreamDelegate>

@property (readwrite,copy) void (^failureBlock)(NSError* error);
@property (readwrite,copy) void (^successBlock)(void);

- (id)initWithData:(NSData*)data;
- (NSInputStream*)dataStream;
- (long long)length;
- (void)stop;
-(void)setCurrentOffset:(long long)offset;
-(void)openStream;
@end
