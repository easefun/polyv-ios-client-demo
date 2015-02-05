//
//  DownLoadManager.h
//  playerVideo(demo)
//
//  Created by xsteach on 14/11/12.
//  Copyright (c) 2014年 xsteach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DownloadHelper.h"

@interface DownLoadManager : NSObject<DownloadHelperDelegate>
-(void)setProgressFrame:(CGRect)frame toView:(UIView *)aView;
-(void)startDownLoad:(NSDictionary *)infoDic;
-(NSDictionary *)getDownLoadList;
@end
