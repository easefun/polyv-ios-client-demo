//
//  PLVData.m
//  PLV-ios-client-demo
//
//  Created by Polyv.net.
//  Copyright (c) 2013 PLV.io. All rights reserved.
//

#import "PLVKit.h"
#import "PLVData.h"

#define PLV_BUFSIZE (32*1024)

@interface PLVData ()
@property (assign) long long offset;
@property (strong, nonatomic) NSInputStream* inputStream;
@property (strong, nonatomic) NSOutputStream* outputStream;
@property (strong, nonatomic) NSData* data;
@end

@implementation PLVData

-(void)openStream{
    [self.outputStream open];
}
- (id)init
{
    self = [super init];
    if (self) {
        NSInputStream* inStream = nil;
        NSOutputStream* outStream = nil;
        [self createBoundInputStream:&inStream
                            outputStream:&outStream
                              bufferSize:PLV_BUFSIZE];
        assert(inStream != nil);
        assert(outStream != nil);
        self.inputStream = inStream;
        self.outputStream = outStream;
        self.outputStream.delegate = self;
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                     forMode:NSDefaultRunLoopMode];
        
    }
    return self;
}

- (id)initWithData:(NSData*)data
{
    self = [self init];
    if (self) {
        self.data = data;
    }
    return self;
}

#pragma mark - Public Methods
- (NSInputStream*)dataStream
{
    return _inputStream;
}

- (void)stop
{
    [[self outputStream] setDelegate:nil];
    [[self outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop]
                                   forMode:NSDefaultRunLoopMode];
    [[self outputStream] close];
    [self setOutputStream:nil];

    [[self inputStream] setDelegate:nil];
    [[self inputStream] close];
    [self setInputStream:nil];
}

- (long long)length
{
    return _data.length;
}


- (NSUInteger)getBytes:(uint8_t *)buffer
            fromOffset:(long long)offset
                length:(NSUInteger)length
                 error:(NSError **)error
{
    NSRange range = NSMakeRange(offset, length);
    if (offset + length > _data.length) {
        return 0;
    }

    [_data getBytes:buffer range:range];
    return length;
}

-(void)setCurrentOffset:(long long)offset{
    self.offset = offset;
}
#pragma mark - NSStreamDelegate Protocol Methods
- (void)stream:(NSStream *)aStream
   handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            PLVLog(@"PLVData stream opened");
        } break;
        case NSStreamEventHasSpaceAvailable: {
            uint8_t buffer[PLV_BUFSIZE];
            long long length = PLV_BUFSIZE;
            if (length > [self length] - [self offset]) {
                length = [self length] - [self offset];
            }
            if (!length) {
                [[self outputStream] setDelegate:nil];
                [[self outputStream] close];
                if (self.successBlock) {
                    self.successBlock();
                }
                return;
            }
            PLVLog(@"Reading %lld bytes from %lld to %lld until %lld"
                  , length, [self offset], [self offset] + length, [self length]);
            NSError* error = NULL;
            NSUInteger bytesRead = [self getBytes:buffer
                                       fromOffset:[self offset]
                                           length:length
                                            error:&error];
            if (!bytesRead) {
                PLVLog(@"Unable to read bytes due to: %@", error);
                if (self.failureBlock) {
                    self.failureBlock(error);
                }
            } else {
                NSInteger bytesWritten = [[self outputStream] write:buffer
                                                        maxLength:bytesRead];
                if (bytesWritten <= 0) {
                    PLVLog(@"Network write error %@", [aStream streamError]);
                } else {
                    if (bytesRead != (NSUInteger)bytesWritten) {
                        PLVLog(@"Read %d bytes from buffer but only wrote %d to the network",
                              bytesRead, bytesWritten);
                    }
                    [self setOffset:[self offset] + bytesWritten];
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            PLVLog(@"PLVData stream error %@", [aStream streamError]);
            if (self.failureBlock) {
                self.failureBlock([aStream streamError]);
            }
        } break;
        case NSStreamEventHasBytesAvailable:
        case NSStreamEventEndEncountered:
        default:
            assert(NO);     // should never happen for the output stream
            break;
    }
}

// A category on NSStream that provides a nice, Objective-C friendly way to create
// bound pairs of streams.  Adapted from the SimpleURLConnections sample code.
- (void)createBoundInputStream:(NSInputStream **)inputStreamPtr
                  outputStream:(NSOutputStream **)outputStreamPtr
                    bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;

    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );

    readStream = NULL;
    writeStream = NULL;

#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED < 1070)
#error If you support Mac OS X prior to 10.7, you must re-enable CFStreamCreateBoundPairCompat.
#endif
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED < 50000)
#error If you support iOS prior to 5.0, you must re-enable CFStreamCreateBoundPairCompat.
#endif

    //    if (NO) {
    //        CFStreamCreateBoundPairCompat(
    //                                      NULL,
    //                                      ((inputStreamPtr  != nil) ? &readStream : NULL),
    //                                      ((outputStreamPtr != nil) ? &writeStream : NULL),
    //                                      (CFIndex) bufferSize
    //                                      );
    //    } else {
    CFStreamCreateBoundPair(
                            NULL,
                            ((inputStreamPtr  != nil) ? &readStream : NULL),
                            ((outputStreamPtr != nil) ? &writeStream : NULL),
                            (CFIndex) bufferSize
                            );
    //    }

    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}


@end

