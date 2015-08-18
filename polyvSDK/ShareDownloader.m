//
//  ShareDownloader.m
//  polyvSDK
//
//  Created by seanwong on 8/17/15.
//  Copyright (c) 2015 easefun. All rights reserved.
//

#import "ShareDownloader.h"
#import "FMDBHelper.h"
@implementation ShareDownloader{
    NSMutableDictionary *_downloaderlist;
    FMDBHelper *_fmdb;
}


+ (id)sharedInstance{
    static ShareDownloader *shareDownloader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareDownloader = [[self alloc] init];
        
    });
    return shareDownloader;
}

-(VideoDownloader*)getDownloader:(NSString*)vid withLevel:(int)level{
    NSString* key = [NSString stringWithFormat:@"%@_%d",vid,level];
    VideoDownloader*downloader = [_downloaderlist objectForKey:key];
    if(downloader==nil){
        downloader =[[VideoDownloader alloc]init];
        [downloader setDownloadDelegate:self];
        [_downloaderlist setValue:downloader forKey:key];
    }
    return downloader;
}

- (id)init {
    if (self = [super init]) {
        _downloaderlist = [[NSMutableDictionary alloc] init];
        _fmdb = [[FMDBHelper alloc] initPolyvDB];
    }
    return self;
}

- (void) downloadDidFinished:(VideoDownloader*)downloader withVid: (NSString *) vid{
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知"
                                                        message:@"视频下载完成"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });*/
    [_fmdb updateDownloadPercent:vid percent:[NSNumber numberWithInt:100]];
    [_fmdb updateDownloadStatic:vid status:1];
    
    
}
- (void) dataDownloadFailed:(VideoDownloader*)downloader withVid: (NSString *) vid reason:(NSString *)reason{
    [_fmdb updateDownloadStatic:vid status:-1];
    

    
}

- (void) dataDownloadAtPercent:(VideoDownloader*)downloader withVid:(NSString*)vid percent:(NSNumber *) percent{
    NSLog(@"%@ - %@",vid,percent);
    [_fmdb updateDownloadPercent:vid percent:percent];
}

@end
