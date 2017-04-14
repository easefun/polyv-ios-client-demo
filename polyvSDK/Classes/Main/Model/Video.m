//
//  Video.m
//  polyvSDK
//
//  Created by seanwong on 8/16/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import "Video.h"

@implementation Video

- (instancetype)initWithDict:(NSDictionary *)jsonDict{
	if (self = [super init]) {
		_title = jsonDict[@"title"];
		_desc = jsonDict[@"context"];
		_vid = jsonDict[@"vid"];
		_piclink = jsonDict[@"first_image"];
		_piclink = [_piclink stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
		_duration = jsonDict[@"duration"];
		//_filesize = jsonDict[@""];
		_allfilesize = jsonDict[@"filesize"];
		//_level = jsonDict[@""];
		_df = [jsonDict[@"df"] intValue];
		_seed = [jsonDict[@"seed"] boolValue];
		//_status = jsonDict[@""];
		//_percent = jsonDict[@""];
		//_rate = jsonDict[@""];
	}
	return self;
}

@end
