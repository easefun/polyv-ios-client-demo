//
//  DownLoadManager.m
//  playerVideo(demo)
//
//  Created by xsteach on 14/11/12.
//  Copyright (c) 2014年 xsteach. All rights reserved.
//

#import "DownLoadManager.h"

@interface DownLoadManager(){
    UIProgressView * _progressView;
    NSDictionary * dic;
    
    NSMutableDictionary * locationRootDic;
    NSString *rootFilePath;
}
@end
@implementation DownLoadManager
-(instancetype)init{
    if (self = [super init]) {
        NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithFormat:@"%@/myFolder", NSHomeDirectory()] attributes:nil];
        rootFilePath= [documentsDirectory stringByAppendingPathComponent:@"download.plist"];
        locationRootDic = [[NSMutableDictionary alloc]initWithContentsOfFile:rootFilePath];
    }
    return self;
}
-(NSDictionary *)getDownLoadList{
    return locationRootDic;
}
-(void)setProgressFrame:(CGRect)frame toView:(UIView *)aView{
    _progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.frame = frame;
    _progressView.progress = 0;
    _progressView.progressTintColor = [UIColor cyanColor];
    _progressView.trackTintColor = [UIColor whiteColor];
    [aView addSubview:_progressView];
}
-(void)startDownLoad:(NSDictionary *)infoDic{
    dic = [[NSDictionary alloc]initWithDictionary:infoDic];
    if (!locationRootDic) {
        //第一次，文件没有创建，因此要创建文件，并写入相应的初始值。
        NSArray * array = [[NSArray alloc]initWithObjects:dic, nil];
        NSArray * vids = [[NSArray alloc]initWithObjects:[dic objectForKey:@"vid"], nil];
        locationRootDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:array,@"root",vids,@"vids",nil];
        [locationRootDic writeToFile:rootFilePath atomically:YES];
        
    }else{
        NSMutableArray * array = [locationRootDic objectForKey:@"root"];
        NSMutableArray * vids = [locationRootDic objectForKey:@"vids"];
        if (![vids containsObject:[dic objectForKey:@"vid"]]) {
            [vids addObject:[dic objectForKey:@"vid"]];
            [array addObject:dic];
            [locationRootDic setObject:array forKey:@"root"];
            [locationRootDic writeToFile:rootFilePath atomically:YES];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"视频已经存在" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alert show];
            return;
        }
    }
    
    
    DownloadHelper* downloder = [DownloadHelper sharedInstance];
    [downloder addSkipBackupAttributeToDownloadedVideos];
    downloder.delegate = self;
    [downloder download:[infoDic objectForKey:@"vid"]];
    
}

#pragma mark DownloadHelperDelegate
- (void) downloadDidFinished: (NSString *) filepath{
    NSLog(@"downloadDidFinished:%@",filepath);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"视频下载完成" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
    [alert show];
}
- (void) didReceiveFilename: (NSString *) aName{
    NSLog(@"didReceiveFilename:%@",aName);
}
- (void) dataDownloadFailed: (NSString *) reason{
    NSLog(@"dataDownloadFailed:%@",reason);
}
- (void) dataDownloadAtPercent: (NSNumber *) aPercent{
    _progressView.progress = [aPercent floatValue];
    NSLog(@"dataDownloadAtPercent:%f",_progressView.progress);
}
@end
