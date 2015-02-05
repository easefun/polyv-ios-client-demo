//
//  DownloadHelper.m
//  polyvSDK
//
//  Created by seanwong on 8/14/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "DownloadHelper.h"
#import "Helper.h"
#import "libpolyvSDK.h"

#define NUMBER(X) [NSNumber numberWithFloat:X]


@implementation DownloadHelper
@synthesize stream;
@synthesize delegate;
@synthesize urlString;
@synthesize filePath;
@synthesize vid;
@synthesize urlconnection;
@synthesize isDownloading;


- (id)initWithVid:(NSString *)videoid encode:(BOOL)encode delegate:(id<DownloadHelperDelegate>)polyvdelegate{

    return [self initWithVid:videoid encode:encode withDf:1 delegate:polyvdelegate];
}

- (id)initWithVid:(NSString *)videoid encode:(BOOL)encode withDf:(int)br delegate:(id<DownloadHelperDelegate>)polyvdelegate{
    self.vid = videoid;
    self.delegate = polyvdelegate;
    
    df = br;
    
    encodefile = encode;
    
    if (df==0) {
        df = 1;
    }

    
    if (self = [super init]) {
    }
    return self;

}

-(BOOL)addSkipBackupAttributeToDownloadedVideos{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask, YES);
    
    NSString*docsDir = [dirPaths objectAtIndex:0];
    NSString *dataPath = [docsDir stringByAppendingPathComponent:@"/plvideo"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: dataPath]);
    
    NSError *error = nil;
    NSURL*pathurl = [NSURL URLWithString:dataPath];
    BOOL success = [pathurl setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [pathurl lastPathComponent], error);
    }
    return success;
    
    
}

- (void) deleteVideo{
    
    filePath = [Helper getDownloadFilePath:self.vid];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        [fm removeItemAtPath:filePath error:nil];
        NSLog(@"delete vid:%@",self.vid);
    }
    
}
- (void) start
{
    self.isDownloading = NO;
    
    NSURL *url = [NSURL URLWithString:self.urlString];
    
    
    if (!url)
    {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL from string %@", self.urlString];
        
        [delegate dataDownloadFailed:reason];
        return;
    }
    
    filePath = [Helper getDownloadFilePath:self.vid];
    
     NSUInteger downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:filePath
                                                            error:&error];
        if (!error && fileDictionary){
            downloadedBytes = [fileDictionary fileSize];
        }
    }else {
        [fm createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];

    if (!theRequest)
    {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL request from string %@", self.urlString];
        [delegate dataDownloadFailed:reason];
        
        return;
    }
    
    self.urlconnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (!self.urlconnection)
    {
        NSString *reason = [NSString stringWithFormat:@"URL connection failed for string %@", self.urlString];
        [delegate dataDownloadFailed:reason];
        
        return;
    }
    
    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%lu-", (unsigned long)downloadedBytes];
        [theRequest setValue:requestRange forHTTPHeaderField:@"Range"];
    }
    
    downloadProgress =downloadedBytes;
    
    self.downloadingFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [self.downloadingFileHandle seekToEndOfFile];
    
    
    
    self.isDownloading = YES;
    
    // Create the new data object
    //self.data = [NSMutableData data];
    
    
    
    
    //NSLog(@"%@",filePath);
    
    //stream = [[NSOutputStream alloc] initToFileAtPath:filePath append:NO];
    //[stream open];
    
    
    
    
    [self.urlconnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) cleanup
{
    self.stream = nil;
    self.response = nil;
    self.urlconnection = nil;
    self.urlString = nil;
    self.isDownloading = NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    /*self.response = aResponse;
    
    if ([aResponse expectedContentLength] < 0)
    {
        NSString *reason = [NSString stringWithFormat:@"Invalid URL [%@]", self.urlString];
        [delegate dataDownloadFailed:reason];
        [connection cancel];
        [self cleanup];
        return;
    }
    
    if ([aResponse suggestedFilename]){
        [delegate didReceiveFilename:[aResponse suggestedFilename]];
    }*/
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    
    
    downloadFileSize = [response expectedContentLength];
    //NSLog(@"set downloadFileSize:%lld",downloadFileSize);

    
    //NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
    //self.downloadingFileHandle = fh;
    NSFileHandle *fh =    self.downloadingFileHandle;
    switch (httpResponse.statusCode) {
        case 206: {
            NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
            NSError *error = nil;
            NSRegularExpression *regex = nil;
            // Check to see if the server returned a valid byte-range
            regex = [NSRegularExpression regularExpressionWithPattern:@"bytes (\\d+)-\\d+/\\d+"
                                                              options:NSRegularExpressionCaseInsensitive
                                                                error:&error];
            if (error) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            // If the regex didn't match the number of bytes, start the download from the beginning
            NSTextCheckingResult *match = [regex firstMatchInString:range
                                                            options:NSMatchingAnchored
                                                              range:NSMakeRange(0, range.length)];
            if (match.numberOfRanges < 2) {
                [fh truncateFileAtOffset:0];
                break;
            }
            
            // Extract the byte offset the server reported to us, and truncate our
            // file if it is starting us at "0".  Otherwise, seek our file to the
            // appropriate offset.
            NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
            NSInteger bytes = [byteStr integerValue];
            if (bytes <= 0) {
                [fh truncateFileAtOffset:0];
                downloadProgress =0;
                break;
            } else {
                [fh seekToFileOffset:bytes];
                downloadProgress =bytes;
                if ([range hasPrefix:@"bytes"]) {
                    NSArray *bytes = [range componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/"]];
                    if ([bytes count] == 4) {
                        downloadFileSize = [[bytes objectAtIndex:2] longLongValue] ?: -1; // if this is *, it's converted to 0, but -1 is default.
                        NSLog(@"set downloadFileSize 206:%lld",downloadFileSize);

                    }
                }
            }
            break;
        }
            
        case 404: {
            
           
            
            [connection cancel];
            
            
            return;
        }
            
            
        default:
            [fh truncateFileAtOffset:0];
            downloadProgress =0;
            break;
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{

    //NSUInteger left = [theData length];
    //sizeCounter=sizeCounter+left;
    /*NSUInteger nwr = 0;
    do {
        nwr = [stream write:[theData bytes] maxLength:left];
        if (-1 == nwr) break;
        left -= nwr;
    } while (left > 0);
    if (left) {
        NSLog(@"stream error: %@", [stream streamError]);
    }
    
    if (self.response)
    {
        float expectedLength = [self.response expectedContentLength];
        //float currentLength = self.data.length;
        float currentLength = sizeCounter;
        float percent = currentLength / expectedLength;
        [delegate dataDownloadAtPercent:NUMBER(percent)];
        
        //DELEGATE_CALLBACK(dataDownloadAtPercent:, NUMBER(percent));
    }*/
    
    downloadProgress += [theData length];
    [self.downloadingFileHandle writeData:theData];
    //NSLog(@"downloadFileSize:%lld",downloadFileSize);
    
    //[self.downloadingFileHandle synchronizeFile];
    if (downloadFileSize>0) {
        float percent = (float)downloadProgress / (float)downloadFileSize;
        //NSLog(@"download: %lld/%lld",downloadProgress,downloadFileSize);
        [delegate dataDownloadAtPercent:NUMBER(percent)];
    }
    
    
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // finished downloading the data, cleaning up
    self.response = nil;
    [self.downloadingFileHandle closeFile];
    
    // Delegate is responsible for releasing data
    if (self.delegate)
    {
        //NSData *theData = [self.data retain];
        
        [delegate downloadDidFinished:self.filePath];
       // DELEGATE_CALLBACK(downloadDidFinished:, self.filePath);
    }
    [self.urlconnection unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self cleanup];
    //对文件加密
    if(encodefile){
        [Helper obfuscate:self.filePath];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isDownloading = NO;
    NSLog(@"Error: Failed connection, %@", [error localizedDescription]);
    //DELEGATE_CALLBACK(dataDownloadFailed:, @"Failed Connection");
    [self.delegate dataDownloadFailed:@"Failed Connection"];
    [self cleanup];
}




- (void) download
{
    //http://dl.videocc.net/<userId>/download_<videoId>_<bitRate>.mp4?downloadId=<downloadId>&times=<times>&ran=<ran>&sign=<sign>
    
    /*
     下载文件的URL中每个参数都必须正确提供，否则无法下载视频文件，每个参 数的说明如下：
     1) userId, 用户在POLYV中的ID，例如邢帅的userId为"";
     2) videoId, 待下载视频的videoId;
     3) bitRate, 待下载视频的码率序号，取值范围为：1, 2, 3;
     4) downloadId, 在POLYV平台中登记后领取到的downloadId;
     5) times, 当前时间戳，单位为毫秒，服务器最好能做时间校对，如果此时间 戳与下载服务器的当前时间戳相差超过阈值（1小时），则判定为请求非法；
     6) ran, 随机字符串，在并发请求时此值很重要，此值最好能尽量随机；
     7) sign, 签名串，签名串的计算规则 为：sign=MD5(downloadId+secretKey+fileType+videoId+bitRate+times+ran),
     其中，下载MP4时，fileType的值为"mp4"；下载FLV时，fileType的值为"flv"；所 有参数值以字符串的形式拼起来再做MD5哈 希。
     */
    
    //NSDictionary*userProfle = [Helper loadUserJson:[self.vid substringWithRange:NSMakeRange(0, 10)]];
    //NSString*hash = [userProfle valueForKey:@"hash"];
    
    //sharedInstance.vid = videoid;
    /*if (encodefile) {
        self.urlString = [NSString stringWithFormat:@"http://v.polyv.net/uc/video/downloadMp4?vid=%@&hash=%@&df=%d",self.vid,hash,df];
    }else{
        self.urlString = [NSString stringWithFormat:@"http://v.polyv.net/uc/video/getMp4?vid=%@&hash=%@&df=%d",self.vid,hash,df];
    }*/
    
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    // NSTimeInterval is defined as double
    NSNumber *timeStampObj = [NSNumber numberWithDouble: timeStamp];
    NSString*ran=[Helper genRandStringLength:8];
    NSString*plainSign =[NSString stringWithFormat:@"%@%@%@%@%d%@%@",DownloadId,DownloadSecretKey,@"mp4",self.vid,df,[timeStampObj stringValue],ran];
    
    NSString*sign=[Helper md5HexDigest:plainSign];
    self.urlString = [NSString stringWithFormat:@"http://dl.videocc.net/%@/download_%@_%d.mp4?downloadId=%@&%@&ran=%@&sign=%@",PolyvUserId,self.vid
                      ,df,DownloadId,[timeStampObj stringValue],ran,sign];
    
    NSLog(@"download:%@",urlString);
    [self start];
}

- (void) cancel
{
    if (isDownloading) [urlconnection cancel];
    isDownloading = false;
}


- (long long) getDownloadFileSize{
    return downloadFileSize;
}

- (long long) downloadProgress{
    return downloadProgress;
}
@end