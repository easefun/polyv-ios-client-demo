//
//  PvExamView.m
//  polyvSDK
//
//  Created by seanwong on 1/26/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import "PvExamView.h"
#import <QuartzCore/QuartzCore.h>
static const CGFloat pVideoLineHeight = 20.0;
static const CGFloat pAnswerFontSize = 14.0;


@implementation PvExamView

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@synthesize pvExam;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.scrollview];
        [self.tipView addSubview:self.tipViewHeadLabel];
        [self.tipView addSubview:self.tipViewConfirmButton];
        [self.tipView addSubview:self.tipViewTextView];
        
        self.tipView.hidden = YES;

        [self.scrollview addSubview:self.headLabel];

        [self.scrollview addSubview:self.questionLabel];
        [self.scrollview addSubview:self.skipButton];
        [self.scrollview addSubview:self.submitButton];
        
        self.scrollview.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        self.scrollview.clipsToBounds = YES;
        self.scrollview.scrollEnabled = YES;
        [self.scrollview addSubview:self.tipView];

        [self configControlAction];
        
        
    }
    
    return self;
}
- (void)resetExamHistory{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defs dictionaryRepresentation];
    for(NSString *key in dict) {
        if ([key hasPrefix:@"exam"]) {
            [defs removeObjectForKey:key];
        }
    }
    
    [defs synchronize];
}
- (void)configControlAction
{
    [self.skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.submitButton addTarget:self action:@selector(submitButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.tipViewConfirmButton addTarget:self action:@selector(tipViewConfirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
}

- (UIImageView *)creatImageViewFromURL:(NSURL *)imageURL{
    UIImageView *imageView = [[UIImageView alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        NSData *data = [NSData dataWithContentsOfURL:imageURL];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            [imageView setImage:image];
            
        });
    });
    return imageView;
}
- (void)setExam:(PvExam *)exam{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\[(.*)\\]\\]"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    self.right = NO;
    _answerDictionary = [NSMutableDictionary new];
    self.pvExam = exam;
    
    if (!self.pvExam.skip) {
        self.skipButton.hidden = YES;
    }else{
        self.skipButton.hidden = NO;
    }
    int startY = pVideoLineHeight+20;
    int startX = 10;
    [self.questionLabel setText:exam.question];
    self.questionLabel.frame = CGRectMake(startX, startY, self.frame.size.width, pVideoLineHeight);
    startY += pVideoLineHeight;
    startY += 5;
    //清理上一次产生的表单控件
    for(UIView *subview in [self.scrollview subviews]) {
        if([subview isKindOfClass:[PvCheckBox class]] || [subview isKindOfClass:[PvRadioButton class]] ||
           [subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    NSString *groupId = self.pvExam.examId;
    for (int i = 0; i < self.pvExam.choices.count; i++) {
        NSDictionary *choice = [self.pvExam.choices objectAtIndex:i];
        NSString *word = [choice objectForKey:@"answer"];
        
        if (self.pvExam.multiple) {
            
            PvCheckBox *checkbox = [[PvCheckBox alloc]initWithFrame:CGRectMake(startX, startY, self.frame.size.width, pVideoLineHeight)];
            [checkbox setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            checkbox.titleLabel.font =[UIFont systemFontOfSize:pAnswerFontSize];
            
            NSTextCheckingResult *match = [regex firstMatchInString:word options:0 range:NSMakeRange(0, [word length])];
            if(match){
                NSRange groupOne = [match rangeAtIndex:1];
                NSString *imageUrl = [word substringWithRange:groupOne];
                word = [regex stringByReplacingMatchesInString:word options:0 range:NSMakeRange(0, [word length]) withTemplate:@""];
                [checkbox setTitle:word forState:UIControlStateNormal];

                int answerLength = pAnswerFontSize *[word length];
                answerLength+=30;//勾选位置
                UIImageView *imageview = [self creatImageViewFromURL:[NSURL URLWithString:imageUrl]];
                imageview.contentMode =  UIViewContentModeScaleAspectFit;
                
                imageview.frame =CGRectMake(answerLength, startY, self.frame.size.width-answerLength, pVideoLineHeight);
                //NSLog(@"%@", NSStringFromCGRect(imageview.frame));
                [self.scrollview addSubview:imageview];
                
            }else{
                [checkbox setTitle:word forState:UIControlStateNormal];
            }
            checkbox.tag = i;
            [checkbox setDelegate:self groupId:groupId];
            
            [self.scrollview addSubview:checkbox];

            
        }else{
            PvRadioButton *radioButton = [[PvRadioButton alloc]initWithFrame:CGRectMake(startX, startY, self.frame.size.width, pVideoLineHeight)];
            radioButton.tag = i;
            [radioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            radioButton.titleLabel.font =[UIFont systemFontOfSize:pAnswerFontSize];
            
            NSTextCheckingResult *match = [regex firstMatchInString:word options:0 range:NSMakeRange(0, [word length])];
            if(match){
                NSRange groupOne = [match rangeAtIndex:1];
                NSString *imageUrl = [word substringWithRange:groupOne];
                word = [regex stringByReplacingMatchesInString:word options:0 range:NSMakeRange(0, [word length]) withTemplate:@""];
                [radioButton setTitle:word forState:UIControlStateNormal];
                
                int answerLength = pAnswerFontSize *[word length];
                answerLength+=30;//勾选位置
                UIImageView *imageview = [self creatImageViewFromURL:[NSURL URLWithString:imageUrl]];
                imageview.contentMode =  UIViewContentModeScaleAspectFit;
                
                imageview.frame =CGRectMake(answerLength, startY, self.frame.size.width-answerLength, pVideoLineHeight);
                //NSLog(@"%@", NSStringFromCGRect(imageview.frame));
                [self.scrollview addSubview:imageview];
                
            }else{
                [radioButton setTitle:word forState:UIControlStateNormal];
            }

            [radioButton setDelegate:self groupId:groupId];
            
            [self.scrollview addSubview:radioButton];
        }
        
        
        startY += pVideoLineHeight;
        startY += 5;
        
       
        
    }
    [self.scrollview bringSubviewToFront:self.submitButton];

    [self.scrollview bringSubviewToFront:self.tipView];
 
    [self.scrollview setContentSize:CGSizeMake(self.frame.size.width, startY)];
    
    [self.submitButton setFrame:CGRectMake(self.frame.size.width-self.submitButton.frame.size.width - 10, self.scrollview.contentSize.height-self.submitButton.frame.size.height, 60, pVideoLineHeight)];
    
    [self.tipViewConfirmButton setFrame:CGRectMake(self.frame.size.width-self.tipViewConfirmButton.frame.size.width - 20, self.scrollview.contentSize.height-self.tipViewConfirmButton.frame.size.height, 60, pVideoLineHeight)];
    
    self.tipView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.scrollview.contentSize.width, self.scrollview.contentSize.height);
    
    self.tipViewTextView.frame = CGRectMake(self.tipView.frame.origin.x + 20, self.frame.origin.y + 20 ,self.tipView.frame.size.width - 40, self.tipView.frame.size.height-41);
    //NSLog(@"%@", NSStringFromCGRect(self.tipViewTextView.frame));
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollview.frame = self.frame;
    
    self.headLabel.frame = CGRectMake((self.frame.size.width-self.headLabel.frame.size.width)/2, 20, self.headLabel.frame.size.width, 20);
    self.skipButton.frame = CGRectMake(self.frame.size.width-60, 20, 60, 20);
    
    self.tipViewHeadLabel.frame = CGRectMake((self.frame.size.width-self.tipViewHeadLabel.frame.size.width)/2, 0, self.tipViewHeadLabel.frame.size.width, 20);
    
    
}


- (void)skipButtonClick
{
    if (self.closedBlock) {
        [self saveRecord];
        self.closedBlock(-1);
    }
}
- (void)saveRecord{
    //保存，以便下次不再回答这个问题
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"Y" forKey:[NSString stringWithFormat:@"exam_%@", self.pvExam.examId]];
}
- (void)tipViewConfirmButtonClick{
    self.tipView.hidden = YES;
    
    if (self.right||self.pvExam.wrongTime==-1) {
        [self saveRecord];
    }
    
    if (self.closedBlock) {
        if (self.right) {
            self.closedBlock(-1);
        }else{
            self.closedBlock(self.pvExam.wrongTime);
        }
        
    }
}

- (void)submitButtonClick{
    
    for (int i = 0; i < self.pvExam.choices.count; i++) {
        NSDictionary *choice = [self.pvExam.choices objectAtIndex:i];
        int right_answer = [[choice objectForKey:@"right_answer"]intValue];
        if(right_answer == 1){
            if([_answerDictionary objectForKey:[NSString stringWithFormat:@"%d", i]]){
                self.right = YES;
            }else{
                self.right = NO;
            }
            
        }
    }
    
    if (self.right) {
        [self.tipViewHeadLabel setText:@"回答正确"];
        [self.tipViewConfirmButton setTitle:@"确认" forState:UIControlStateNormal];
    }else{
        [self.tipViewHeadLabel setText:@"回答错误"];
        //需要seek回去再看
        if (self.pvExam.wrongTime!=-1) {
            [self.tipViewConfirmButton setTitle:@"再看一次" forState:UIControlStateNormal];
        }
    }
    if ([self.pvExam.answer length] > 0) {
        [self.tipViewTextView setText:self.pvExam.answer];
    }else{
        self.tipViewTextView.text = @"正确答案:\n";
        for (int i = 0; i < self.pvExam.choices.count; i++) {
            NSDictionary *choice = [self.pvExam.choices objectAtIndex:i];
            int right_answer = [[choice objectForKey:@"right_answer"]intValue];
            if(right_answer == 1){
                self.tipViewTextView.text = [NSString stringWithFormat:@"%@\n%@", self.tipViewTextView.text, [choice objectForKey:@"answer"]];
                //NSLog(@"%@", self.tipViewTextView.text);
                
            }
        }
        
    }
    
    self.tipView.hidden = NO;
}




- (UIButton *)skipButton
{
    if (!_skipButton) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        _skipButton.titleLabel.font =[UIFont systemFontOfSize:14];
        [_skipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    }
    return _skipButton;
}
- (UIButton *)submitButton
{
    if (!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];

        [_submitButton setBackgroundColor:UIColorFromRGB(0x1D82E9)];
        [_submitButton setTitle:@"确定" forState:UIControlStateNormal];
        _submitButton.titleLabel.font =[UIFont systemFontOfSize:14];
        [_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitButton.bounds = CGRectMake(0, 0, 60, pVideoLineHeight);
    }
    return _submitButton;
}
- (UIButton *)tipViewConfirmButton
{
    if (!_tipViewConfirmButton) {
        _tipViewConfirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tipViewConfirmButton setBackgroundColor:UIColorFromRGB(0x1D82E9)];
        [_tipViewConfirmButton setTitle:@"确定" forState:UIControlStateNormal];
        _tipViewConfirmButton.titleLabel.font =[UIFont systemFontOfSize:14];
        [_tipViewConfirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _tipViewConfirmButton.bounds = CGRectMake(0, 0, 60, pVideoLineHeight);
    }
    return _tipViewConfirmButton;
}
- (UIScrollView *)scrollview
{
    if (!_scrollview) {
        _scrollview = [[UIScrollView alloc]initWithFrame:self.frame];
    }
    return _scrollview;
}
- (UIView *)tipView
{
    if (!_tipView) {
        _tipView = [UIView new];
        [_tipView setBackgroundColor:[UIColor whiteColor]];
    }
    return _tipView;
}

- (UILabel *)headLabel
{
    if (!_headLabel) {
        _headLabel = [UILabel new];
        _headLabel.backgroundColor = [UIColor whiteColor];
        _headLabel.font = [UIFont systemFontOfSize:17];
        _headLabel.textColor = [UIColor blackColor];
        _headLabel.textAlignment = NSTextAlignmentLeft;
        _headLabel.bounds = CGRectMake(0, 0, 17*4, pVideoLineHeight);
        [_headLabel setText:@"课堂问答"];
    }
    return _headLabel;
}
- (UILabel *)questionLabel
{
    if (!_questionLabel) {
        _questionLabel = [UILabel new];
        _questionLabel.backgroundColor = [UIColor whiteColor];
        _questionLabel.font = [UIFont systemFontOfSize:15];
        _questionLabel.textColor = [UIColor blackColor];
        _questionLabel.textAlignment = NSTextAlignmentLeft;
        _questionLabel.bounds = CGRectMake(0, 0, 60, pVideoLineHeight);
    }
    return _questionLabel;
}

- (UILabel *)tipViewHeadLabel
{
    if (!_tipViewHeadLabel) {
        _tipViewHeadLabel = [UILabel new];
        _tipViewHeadLabel.backgroundColor = [UIColor whiteColor];
        _tipViewHeadLabel.font = [UIFont systemFontOfSize:15];
        _tipViewHeadLabel.textColor = [UIColor orangeColor];
        _tipViewHeadLabel.textAlignment = NSTextAlignmentLeft;
        _tipViewHeadLabel.bounds = CGRectMake(0, 0, 60, pVideoLineHeight);
    }
    return _tipViewHeadLabel;
}
- (UILabel *)tipViewTextView{
    if (!_tipViewTextView) {
        _tipViewTextView = [UILabel new];
        _tipViewTextView.textColor = [UIColor blackColor];
        _tipViewTextView.numberOfLines = 0;
        _tipViewTextView.lineBreakMode = NSLineBreakByCharWrapping;
        _tipViewTextView.font = [UIFont systemFontOfSize:15];
        _tipViewTextView.layer.borderColor = UIColorFromRGB(0xeeeeee).CGColor;
        _tipViewTextView.layer.borderWidth = 1;
    }
    return _tipViewTextView;
    
}

- (void)didSelectedCheckBox:(PvCheckBox *)checkbox checked:(BOOL)checked{
    if (checked) {
        [_answerDictionary setValue:checkbox.titleLabel.text forKey:[NSString stringWithFormat:@"%zd", checkbox.tag]];
    }else{
        [_answerDictionary removeObjectForKey:[NSString stringWithFormat:@"%zd", checkbox.tag]];
        
    }
    
    
}
- (void)didSelectedRadioButton:(PvRadioButton *)radio groupId:(NSString *)groupId {
    [_answerDictionary removeAllObjects];
    [_answerDictionary setValue:radio.titleLabel.text forKey:[NSString stringWithFormat:@"%zd", radio.tag]];
}





@end
