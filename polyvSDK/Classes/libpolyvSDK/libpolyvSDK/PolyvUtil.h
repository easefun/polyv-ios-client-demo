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

/**
 *  获取加密的 key
 *
 *  @param videoPoolId videoPoolId
 *  @param bitrate     码率
 *
 *  @return 加密的 key
 */
+ (NSData *)getEcryptedKeyWithVideoPoolId:(NSString *)videoPoolId BitRate:(int)bitrate;

/**
 *  加密 key
 *
 *  @param data        key data
 *  @param videoPoolId videoPoolId
 *
 *  @return key
 */
+ (NSData *)ecryptedKeyData:(NSData *)data WithVideoPoolId:(NSString *)videoPoolId;

/**
 *  获取 key URL
 *
 *  @param videoPoolId videoPoolId
 *  @param bitrate     码率
 *
 *  @return key URL
 */
+ (NSURL *)getKeyUrlWithVideoPoolId:(NSString *)videoPoolId BitRate:(int)bitrate;

/**
 *  获取签名
 *
 *  @param ts          时间戳
 *  @param videoPoolId videoPoolId
 *
 *  @return 签名
 */
+ (NSString *)getSign:(NSString *)ts VideoPoolId:(NSString *)videoPoolId;

/**
 *  使用 MD5 加密
 *
 *  @param input 输入字符串
 *
 *  @return MD5 加密的字符串
 */
+ (NSString *)md5HexDigest:(NSString *)input;

/**
 *  AES-128 加密
 *
 *  @param key  秘钥
 *  @param data 需加密的数据
 *
 *  @return 加密的数据
 */
+ (NSData *)AES128EncryptedDataWithKey:(NSString *)key data:(NSData *)data;

/**
 *  AES-128 解密
 *
 *  @param key  秘钥
 *  @param data 待解密的数据
 *
 *  @return 解密后的数据
 */
+ (NSData *)AES128DecryptedDataWithKey:(NSString *)key data:(NSData *)data;

/**
 *  AES-128 加密
 *
 *  @param key  秘钥
 *  @param iv   初始向量
 *  @param data 待加密数据
 *
 *  @return 加密的数据
 */
+ (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(Byte *)iv data:(NSData *)data;

/**
 *  AES-128 解密
 *
 *  @param key  秘钥
 *  @param iv   初始向量
 *  @param data 待解密的数据
 *
 *  @return 解密的数据
 */
+ (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(Byte *)iv data:(NSData *)data;

/**
 *  同步从URL获取数据
 *
 *  @param url URL
 *
 *  @return 返回数据
 */
+ (NSData *)loadDataFromURL:(NSURL *)url;

/**
 *  使用默认加密秘钥和加密向量解密用户配置信息
 *
 *  @param data 加密的用户配置信息
 *
 *  @return 解密后的用户配置信息
 */
+ (NSArray *)decryptUserConfig:(NSData *)data;

/**
 *  解密用户配置信息
 *
 *  @param data 加密的用户信息
 *  @param key  加密密钥
 *  @param iv   加密向量
 *
 *  @return 用户信息
 */
+ (NSArray *)decryptUserConfig:(NSData *)data key:(NSString *)key iv:(NSString *)iv;

//+ (NSString *)localIPAddress;
/**
 *  主机地址
 *
 *  @return 主机地址
 */
+ (NSString*)hostIp;

/// video pool id
+ (NSString *)videoPoolIdWithVid:(NSString *)vid;
/// vid
+ (NSString *)vidWithvideoPoolId:(NSString *)videoPoolId;
/// 时间戳
+ (NSString *)timestamp;
@end
