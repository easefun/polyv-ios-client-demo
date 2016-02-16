//
//  PvRadioButton.h
//  polyvSDK
//
//  Created by seanwong on 1/26/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PvRadioButtonDelegate;

@interface PvRadioButton : UIButton {
    NSString                        *_groupId;
    BOOL                            _checked;
    id<PvRadioButtonDelegate> __unsafe_unretained      _delegate;
}

@property(nonatomic, assign)id<PvRadioButtonDelegate>   delegate;
@property(nonatomic, copy, readonly)NSString            *groupId;
@property(nonatomic, assign)BOOL checked;

- (id)initWithDelegate:(id)delegate groupId:(NSString*)groupId;

-(void)setDelegate:(id<PvRadioButtonDelegate>)delegate groupId:(NSString*)groupId;
@end

@protocol PvRadioButtonDelegate <NSObject>

@optional

- (void)didSelectedRadioButton:(PvRadioButton *)radio groupId:(NSString *)groupId;

@end
