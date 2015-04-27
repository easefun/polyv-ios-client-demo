//
//  MPMoviePlayerController+plv.h
//  hlsplay
//
//  Created by seanwong on 4/14/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MPMoviePlayerController(plv)

-(id)initWithVid:(NSString*)vid;
- (void)setVid:(NSString*)vid;


-(id)initWithVid:(NSString*)vid level:(int)level;
- (void)setVid:(NSString*)vid level:(int)level;

@end
