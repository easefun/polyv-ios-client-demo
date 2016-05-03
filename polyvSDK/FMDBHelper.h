//
//  FMDBHelper.h
//  jkws
//
//  Created by seanwong on 13-7-18.
//
//

#import <Foundation/Foundation.h>
#import "Video.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
@interface FMDBHelper : NSObject
@property (retain, nonatomic) NSString *DBName;
@property (retain, nonatomic) FMDatabaseQueue *queue;

+ (id)sharedInstance;
#pragma mark download
-(void)addDownloadVideo:(Video*)v;
-(NSMutableArray*)listDownloadVideo;
-(void)removeDownloadVideo:(Video*)v;
-(void)updateDownloadPercent:(NSString*)vid percent:(NSNumber*)percent;
-(void)updateDownloadStatic:(NSString*)vid status:(int)status;
#pragma mark -

@end
