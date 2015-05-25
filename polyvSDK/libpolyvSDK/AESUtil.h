//
//  AESUtil.h
//  hlsplay
//
//  Created by seanwong on 5/25/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESUtil : NSObject
+ (NSData *)AES128EncryptedDataWithKey:(NSString *)key data:(NSData*)data;
+ (NSData *)AES128DecryptedDataWithKey:(NSString *)key data:(NSData*)data;;
+ (NSData *)AES128EncryptedDataWithKey:(NSString *)key iv:(Byte*)iv data:(NSData*)data;;
+ (NSData *)AES128DecryptedDataWithKey:(NSString *)key iv:(Byte*)iv data:(NSData*)data;;
@end
