//
//  PolyvUtil.h
//  hlsplay
//
//  Created by seanwong on 6/5/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

@interface PolyvUtil : NSObject

+(NSData*)getEcryptedKeyWithVideoPoolId:(NSString*)videoPoolId  BitRate:(int) bitrate;

+(NSData*)ecryptedKeyData:(NSData*)data WithVideoPoolId:(NSString*)videoPoolId;
+(NSURL*)getKeyUrlWithVideoPoolId:(NSString*)videoPoolId BitRate:(int) bitrate;

+(NSString*)getSign:(NSString*)ts VideoPoolId:(NSString*)videoPoolId;
+ (NSString*)md5HexDigest:(NSString*)input;
+ (NSData *)AES128EncryptedDataWithKey:(NSString *)key data:(NSData*)data;
+ (NSData *)AES128DecryptedDataWithKey:(NSString *)key data:(NSData*)data;;
+ (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(Byte*)iv data:(NSData*)data;
+ (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(Byte*)iv data:(NSData*)data;
+(NSData*)loadDataFromURL:(NSURL*)url;
+ (NSArray *)decryptUserConfig:(NSData*)data;
@end
