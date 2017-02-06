//
//  PvCheckBox.h
//  polyvSDK
//
//  Created by seanwong on 1/26/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PvCheckBoxDelegate;

@interface PvCheckBox : UIButton {
	NSString *_groupId;
	BOOL _checked;
	id _userInfo;
}
@property(nonatomic, copy, readonly)NSString *groupId;

@property(nonatomic, weak) id<PvCheckBoxDelegate> delegate;
@property(nonatomic, assign) BOOL checked;
@property(nonatomic, retain) id userInfo;

- (id)initWithDelegate:(id)delegate;

- (void)setDelegate:(id<PvCheckBoxDelegate>)delegate groupId:(NSString *)groupId;


@end

@protocol PvCheckBoxDelegate <NSObject>

@optional

- (void)didSelectedCheckBox:(PvCheckBox *)checkbox checked:(BOOL)checked;

@end
