//
//  Video.h
//  polyvSDK
//
//  Created by seanwong on 8/16/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic,copy) NSString *vid;
@property (nonatomic,copy) NSString *piclink;
@property (nonatomic,copy) NSString *duration;
@property long long filesize;
@property NSArray* allfilesize;
@property int level;
@property int df;
@property int status;
@property int percent;

- (id)initWithVid:(NSString*)_vid;
@end
