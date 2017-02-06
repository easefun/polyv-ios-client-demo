//
//  PvExam.h
//  polyvSDK
//
//  Created by seanwong on 1/26/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PvExam : NSObject

@property (nonatomic, copy) NSString *examId;
@property (nonatomic, copy) NSString *userid;
@property int seconds;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSArray *choices;
@property (nonatomic, copy) NSString *answer;
@property BOOL skip;
@property int wrongTime;
@property int wrongShow;
@property BOOL multiple;

@end
