//
//  PLVResumableUpload.m
//  PLV-ios-client-demo
//
//  Copyright (c) 2013 Polyv Inc. All rights reserved.
//

#import "PLVKit.h"
#import "PLVData.h"

#import "PLVResumableUpload.h"

#define HTTP_PATCH @"PATCH"
#define HTTP_POST @"POST"
#define HTTP_HEAD @"HEAD"

#define HTTP_LOCATION @"Location"


#define REQUEST_TIMEOUT 60

typedef NS_ENUM(NSInteger, PLVUploadState) {
    Idle,
    CheckingFile,
    CreatingFile,
    UploadingFile,
};

@interface PLVResumableUpload (){
    NSMutableDictionary *extraInfo;
}
@property (strong, nonatomic) PLVData *data;
@property (strong, nonatomic) NSURL *endpoint;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *writeToken;
@property (strong, nonatomic) NSString *fingerprint;
@property (nonatomic) long long offset;
@property (nonatomic) PLVUploadState state;
@property (strong, nonatomic) void (^progress)(NSInteger bytesWritten, NSInteger bytesTotal);
@end

@implementation PLVResumableUpload

-(void)setExtraInfo:(NSMutableDictionary *)info{
    extraInfo =info;
}
- (id)initWithURL:(NSString *)url
             data:(PLVData *)data
      fingerprint:(NSString *)fingerprint
       writeToken:(NSString*)writeToken
       
{
    self = [super init];
    if (self) {
        [self setEndpoint:[NSURL URLWithString:url]];
        [self setData:data];
        [self setFingerprint:fingerprint];
        [self setWriteToken:writeToken];
    }
    return self;
}

- (void) start
{
    if (self.progressBlock) {
        self.progressBlock(0, 0);
    }

    NSString *uploadUrl = [[self resumableUploads] valueForKey:[self fingerprint]];
    if (uploadUrl == nil) {
        PLVLog(@"No resumable upload URL for fingerprint %@", [self fingerprint]);
        [self createFile];
        return;
    }

    [self setUrl:[NSURL URLWithString:uploadUrl]];
    [self checkFile];
}

- (void) createFile
{
    [self setState:CreatingFile];

    long long size = [[self data] length];
    NSDictionary *headers = @{
                              @"writeToken":self.writeToken,
                              @"Final-Length":[NSString stringWithFormat:@"%lld", size]
                              
                              } ;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self endpoint] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    [request setHTTPMethod:HTTP_POST];
    [request setHTTPShouldHandleCookies:NO];
    [request setAllHTTPHeaderFields:headers];
    
    NSString* postString= @"";
    
    for(NSString *key in extraInfo) {
        NSString*value=[extraInfo valueForKey:key];
        postString = [NSString stringWithFormat:@"%@&%@=%@",postString,key,value];
    }
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *connection __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) checkFile
{
    [self setState:CheckingFile];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    [request setHTTPMethod:HTTP_HEAD];
    [request setHTTPShouldHandleCookies:NO];
    
    NSURLConnection *connection __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) uploadFile
{
    [self setState:UploadingFile];
    
    long long offset = [self offset];
    
    NSDictionary *headers = @{
                              @"writeToken":self.writeToken,
                               @"Offset":[NSString stringWithFormat:@"%lld", offset]};

    __weak PLVResumableUpload* upload = self;
    self.data.failureBlock = ^(NSError* error) {
        PLVLog(@"Failed to upload to %@ for fingerprint %@", [upload url], [upload fingerprint]);
        if (upload.failureBlock) {
            upload.failureBlock(error);
        }
    };
    self.data.successBlock = ^() {
        [upload setState:Idle];
        PLVLog(@"Finished upload to %@ for fingerprint %@", [upload url], [upload fingerprint]);
        NSMutableDictionary* resumableUploads = [upload resumableUploads];
        [resumableUploads removeObjectForKey:[upload fingerprint]];
        BOOL success = [resumableUploads writeToURL:[upload resumableUploadsFilePath]
                                         atomically:YES];
        if (!success) {
            PLVLog(@"Unable to save resumableUploads file");
        }
        if (upload.resultBlock) {
            upload.resultBlock(upload.url);
        }
    };

    PLVLog(@"Resuming upload at %@ for fingerprint %@ from offset %lld",
          [self url], [self fingerprint], offset);
    [[self data]setCurrentOffset:offset];
    [[self data]openStream];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:REQUEST_TIMEOUT];
    [request setHTTPMethod:HTTP_PATCH];
    [request setHTTPBodyStream:[[self data] dataStream]];
    [request setHTTPShouldHandleCookies:NO];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLConnection *connection __unused = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnectionDelegate Protocol Delegate Methods
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    PLVLog(@"ERROR: connection did fail due to: %@", error);
    [connection cancel];
    [[self data] stop];
    if (self.failureBlock) {
        self.failureBlock(error);
    }
}

#pragma mark - NSURLConnectionDataDelegate Protocol Delegate Methods

// TODO: Add support to re-initialize dataStream
- (NSInputStream *)connection:(NSURLConnection *)connection
            needNewBodyStream:(NSURLRequest *)request
{
    PLVLog(@"ERROR: connection requested new body stream, which is currently not supported");
    return nil;
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *headers = [httpResponse allHeaderFields];
    
    switch([self state]) {
        case CheckingFile: {
            if (httpResponse.statusCode != 200) {
                NSLog(@"Server responded with %d. Restarting upload",
                      httpResponse.statusCode);
                [self createFile];
                return;
            }
            NSString *offset = [headers valueForKey:@"Offset"];
            if (offset) {
                //PLVRange range = [self rangeFromHeader:rangeHeader];
                [self setOffset:[offset longLongValue]];
                PLVLog(@"Resumable upload at %@ for %@ from %lld",
                      [self url], [self fingerprint], [self offset]);
            }
            else {
                PLVLog(@"Restarting upload at %@ for %@", [self url], [self fingerprint]);
            }
            [self uploadFile];
            break;
        }
        case CreatingFile: {
            NSString *location = [headers valueForKey:HTTP_LOCATION];
            [self setUrl:[NSURL URLWithString:location]];
            PLVLog(@"Created resumable upload at %@ for fingerprint %@",
                  [self url], [self fingerprint]);
            NSURL* fileURL = [self resumableUploadsFilePath];
            NSMutableDictionary* resumableUploads = [self resumableUploads];
            [resumableUploads setValue:location forKey:[self fingerprint]];
            BOOL success = [resumableUploads writeToURL:fileURL atomically:YES];
            if (!success) {
                PLVLog(@"Unable to save resumableUploads file");
            }
            [self uploadFile];
            break;
        }
        default:
            break;
    }
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    switch([self state]) {
        case UploadingFile:
            if (self.progressBlock) {
                //self.progressBlock(totalBytesWritten+[self offset], [[self data] length]+[self offset]);
                self.progressBlock(totalBytesWritten+[self offset], [[self data] length]);
            }
            break;
        default:
            break;
    }

}

/*
#pragma mark - Private Methods
- (PLVRange)rangeFromHeader:(NSString*)rangeHeader
{
    long long first = PLVInvalidRange;
    long long last = PLVInvalidRange;

    NSString* bytesPrefix = [HTTP_BYTES_UNIT stringByAppendingString:HTTP_RANGE_EQUAL];
    NSScanner* rangeScanner = [NSScanner scannerWithString:rangeHeader];
    BOOL success = [rangeScanner scanUpToString:bytesPrefix intoString:NULL];
    if (!success) {
        PLVLog(@"Failed to scan up to '%@' from '%@'", bytesPrefix, rangeHeader);
    }

    success = [rangeScanner scanString:bytesPrefix intoString:NULL];
    if (!success) {
        PLVLog(@"Failed to scan '%@' from '%@'", bytesPrefix, rangeHeader);
    }

    success = [rangeScanner scanLongLong:&first];
    if (!success) {
        PLVLog(@"Failed to first byte from '%@'", rangeHeader);
    }

    success = [rangeScanner scanString:HTTP_RANGE_DASH intoString:NULL];
    if (!success) {
        PLVLog(@"Failed to byte-range separator from '%@'", rangeHeader);
    }

    success = [rangeScanner scanLongLong:&last];
    if (!success) {
        PLVLog(@"Failed to last byte from '%@'", rangeHeader);
    }

    if (first > last) {
        first = PLVInvalidRange;
        last = PLVInvalidRange;
    }
    if (first < 0) {
        first = PLVInvalidRange;
    }
    if (last < 0) {
        last = PLVInvalidRange;
    }

    return PLVMakeRange(first, last);
}
*/

- (NSMutableDictionary*)resumableUploads
{
    static id resumableUploads = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL* resumableUploadsPath = [self resumableUploadsFilePath];
        resumableUploads = [NSMutableDictionary dictionaryWithContentsOfURL:resumableUploadsPath];
        if (!resumableUploads) {
            resumableUploads = [[NSMutableDictionary alloc] init];
        }
    });

    return resumableUploads;
}

- (NSURL*)resumableUploadsFilePath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* directories = [fileManager URLsForDirectory:NSApplicationSupportDirectory
                                               inDomains:NSUserDomainMask];
    NSURL* applicationSupportDirectoryURL = [directories lastObject];
    NSString* applicationSupportDirectoryPath = [applicationSupportDirectoryURL absoluteString];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:applicationSupportDirectoryPath
                           isDirectory:&isDirectory]) {
        NSError* error = nil;
        BOOL success = [fileManager createDirectoryAtURL:applicationSupportDirectoryURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
        if (!success) {
            PLVLog(@"Unable to create %@ directory due to: %@",
                  applicationSupportDirectoryURL,
                  error);
        }
    }
    return [applicationSupportDirectoryURL URLByAppendingPathComponent:@"PLVResumableUploads.plist"];
}

@end
