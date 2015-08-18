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
@interface FMDBHelper : NSObject
@property (retain, nonatomic) FMDatabase *DB;
@property (retain, nonatomic) NSString *DBName;

-(id)initPolyvDB;
-(id)initWithDBName:(NSString *)dbName;
#pragma mark download
-(void)addDownloadVideo:(Video*)v;
-(NSMutableArray*)listDownloadVideo;
-(void)removeDownloadVideo:(Video*)v;
-(void)updateDownloadPercent:(NSString*)vid percent:(NSNumber*)percent;
-(void)updateDownloadStatic:(NSString*)vid status:(int)status;
#pragma mark -

@end
