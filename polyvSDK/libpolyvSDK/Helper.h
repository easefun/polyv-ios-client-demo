//
//  Helper.h
//  polyvSDK
//
//  Created by seanwong on 8/14/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject
+(NSString*)getDownloadFilePath:(NSString*)vid;
+(void)obfuscate:(NSString*)file;
+(NSDictionary*)loadUserJson:(NSString*)userid;
+(NSDictionary*)loadVideoJson:(NSString*)vid;
+ (NSString *)genRandStringLength:(int)len;
+ (NSString*)md5HexDigest:(NSString*)input;
@end
