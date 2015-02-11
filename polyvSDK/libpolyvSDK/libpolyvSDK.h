//
//  libpolyvSDK.h
//  libpolyvSDK
//
//  Created by seanwong on 7/14/14.
//  Copyright (c) 2014 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface libpolyvSDK : NSObject


extern NSString *PolyvPrivatekey;
extern NSString *PolyvReadtoken;
extern NSString *PolyvWritetoken;
extern NSString *PolyvUserId;
extern NSString *DownloadId;
extern NSString *DownloadSecretKey;


+ (void)initConfigWithPrivateKey:(NSString*)privateKey Readtoken:(NSString*)readtoken Writetoken:(NSString*)writetoken UserId:(NSString*)userId DownloadId:(NSString*)downloadId Downloadsecretkey:(NSString*)downloadsecretkey;


@end
