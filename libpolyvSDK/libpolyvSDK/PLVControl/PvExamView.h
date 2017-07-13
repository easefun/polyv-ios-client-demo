//
//  PvExamView.h
//  polyvSDK
//
//  Created by seanwong on 1/26/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PvExam.h"
#import "PvCheckBox.h"
#import "PvRadioButton.h"
@interface PvExamView : UIView<PvCheckBoxDelegate,PvRadioButtonDelegate>{
    NSMutableDictionary *_answerDictionary;
}

typedef void (^viewClosedBlock)(int seekto);

@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIButton *tipViewConfirmButton;
@property (strong, nonatomic) UILabel *tipViewTextView;

@property (strong, nonatomic) UILabel *headLabel;
@property (strong, nonatomic) UILabel *tipViewHeadLabel;
@property (strong, nonatomic) UILabel *questionLabel;
@property (strong, nonatomic) UIScrollView *scrollview;
@property (strong, nonatomic) UIView *tipView;

@property PvExam *pvExam;
@property (readwrite, copy) viewClosedBlock closedBlock;
@property BOOL right;

- (void)resetExamHistory;
- (void)setExam:(PvExam *)exam;

@end
