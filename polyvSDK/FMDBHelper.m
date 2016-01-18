//
//  FMDBHelper.m
//  jkws
//
//  Created by seanwong on 13-7-18.
//
//

#import "FMDBHelper.h"
#import "FMDatabase.h"
#import  "FMDatabaseQueue.h"
#import "Video.h"
@implementation FMDBHelper
@synthesize DBName;
@synthesize queue;
// 数据库存储路径(内部使用)
- (NSString *)getPath:(NSString *)dbName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:dbName];

}
+ (id)sharedInstance{
    static FMDBHelper *fmdbHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmdbHelper = [[self alloc] init];
        
    });
    return fmdbHelper;
}
- (id)init {
    if (self = [super init]) {
        DBName = [self getPath:@"polyv.db"];
        [self readyDownloadTable];
    }
    return self;
}



// 打开数据库
- (void)readyDatabase
{
    queue = [FMDatabaseQueue databaseQueueWithPath:self.DBName];

}
#pragma mark downloadTable
-(void)readyDownloadTable{
    [self readyDatabase];
    [queue inDatabase:^(FMDatabase *db) {
        NSString * sql = @"create table if not exists downloadlist (vid varchar(40),title varchar(100),duration varchar(20),filesize bigint,level int,percent int default 0,status int,primary key (vid))";
        [db executeUpdate:sql];

    }];
    
}
-(void)addDownloadVideo:(Video*)v{
    
    [queue inDatabase:^(FMDatabase *db) {
        
         [db executeUpdate:@"replace INTO downloadlist(vid,title,duration,filesize,level,percent,status) VALUES (?,?,?,?,?,?,0)", v.vid,v.title,v.duration,[NSNumber numberWithLongLong:v.filesize],[NSNumber numberWithInt:v.level],[NSNumber numberWithInt:v.percent]];
    }];
    
   
    
}
-(void)updateDownloadPercent:(NSString*)vid percent:(NSNumber*)percent{
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update downloadlist set percent=? where vid=?", percent,vid];
        
     }];
        //[DB close];
    
}
-(void)updateDownloadStatic:(NSString*)vid status:(int)status{
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"update downloadlist set status=? where vid=?", [NSNumber numberWithInt:status],vid];
        
    }];

}

-(void)removeDownloadVideo:(Video*)v{
    [queue inDatabase:^(FMDatabase *db) {
        NSLog(@"delete %@",v.vid);
        [db executeUpdate:@"delete from downloadlist where vid=?", v.vid];
    }];
     
    
    
}


-(NSMutableArray*)listDownloadVideo{
   
    NSMutableArray*downloadVideos = [NSMutableArray array];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs =[db executeQuery:@"select * from downloadlist"];
        while ([rs next]) {
            NSString * vid = [rs stringForColumn:@"vid"];
            NSString * title = [rs stringForColumn:@"title"];
            NSString * duration = [rs stringForColumn:@"duration"];
            long long filesize = [rs longLongIntForColumn:@"filesize"];
            int level = [rs intForColumn:@"level"];
            int percent = [rs intForColumn:@"percent"];
            int status = [rs intForColumn:@"status"];
            Video*v = [[Video alloc]init];
            v.vid = vid;
            v.title = title;
            v.level = level;
            v.filesize = filesize;
            v.duration = duration;
            v.percent = percent;
            v.status = status;
            
            
            [downloadVideos insertObject:v atIndex:0];
        }
        
    }];
    
    return downloadVideos;
    
}
#pragma mark -
@end
