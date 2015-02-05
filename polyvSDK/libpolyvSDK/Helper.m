//
//  Helper.m
//  polyvSDK
//
//  Created by seanwong on 8/14/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import "Helper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Helper

+(NSString*)getDownloadFilePath:(NSString*)vid{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    NSString *dataPath = [docsDir stringByAppendingPathComponent:@"/plvideo"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    
    NSString* filePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",vid]];
    return filePath;
    
}

+(NSDictionary*)loadUserJson:(NSString*)userid{
    NSDictionary *results;
    NSString*jsonUrl = [NSString stringWithFormat:@"http://v.polyv.net/userjson/%@.js",userid];
    NSURL* url = [NSURL URLWithString:jsonUrl];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil] ;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    NSString* responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    
    if ([data length] >0 && [httpResponse statusCode] == 200)
    {
        
        NSError *error = nil;
        results = [NSJSONSerialization
                   JSONObjectWithData:data
                   options:0
                   error:&error];
        
       
        
    }
    
    return results;
}


+(NSDictionary*)loadVideoJson:(NSString*)vid{
    NSDictionary *results;
    NSString*jsonUrl = [NSString stringWithFormat:@"http://v.polyv.net/videojson/%@.js",vid];
    NSURL* url = [NSURL URLWithString:jsonUrl];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    NSURLResponse* response = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil] ;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([data length] >0 && [httpResponse statusCode] == 200)
    {
        
        NSError *error = nil;
        results = [NSJSONSerialization
                   JSONObjectWithData:data
                   options:0
                   error:&error];
        
        
        
    }
    
    return results;
}

+ (NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}
// Generates alpha-numeric-random string
+ (NSString *)genRandStringLength:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}
+(void)obfuscate:(NSString*)file{
    NSLog(@"obfuscate");
    int obfuscatLen = 1;
    NSString *pathOfFile = [NSString stringWithFormat:@"%@", file];
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:pathOfFile error:nil] fileSize];

    if (fileSize==0) {
        return;
    }
    NSFileHandle *fh = [NSFileHandle fileHandleForUpdatingAtPath:pathOfFile];
    
    NSData *encryptData = [fh readDataOfLength:obfuscatLen];
    //char* dataPtr = (char*)[encryptData bytes];
    uint8_t * dataPtr = (uint8_t  * )[encryptData bytes];
    
    //NSLog(@"data1: %lu %@",(unsigned long)[encryptData length],encryptData);
    
    [fh seekToFileOffset:0];
    //NSString* key = @"ABCDEFG";
    //uint8_t * keyPtr   = (uint8_t *)[[key dataUsingEncoding:NSUTF8StringEncoding ] bytes];
    for(int index = 0; index < obfuscatLen; index++){
        //NSLog(@"data: %d",dataPtr[index]);
        dataPtr[index] ^= 0xe8;
        
        
        NSData *zeroData = [NSData dataWithBytes:&dataPtr[index] length:1];
        //NSLog(@"data2: %@",zeroData);
        [fh writeData:zeroData];
    }
    [fh closeFile];
    
    //==========
    /*fh = [NSFileHandle fileHandleForUpdatingAtPath:pathOfFile];
    NSData *encryptData2 = [fh readDataOfLength:obfuscatLen];
    
    NSLog(@"data2: %lu %@",(unsigned long)[encryptData2 length],encryptData2);

    [fh closeFile];*/
    
   }

@end
