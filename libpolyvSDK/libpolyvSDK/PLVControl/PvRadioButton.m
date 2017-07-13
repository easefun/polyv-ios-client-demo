//
//  PvRadioButton.m
//  polyvSDK
//
//  Created by seanwong on 1/26/16.
//  Copyright © 2016 easefun. All rights reserved.
//

#import "PvRadioButton.h"

#define PV_RADIO_ICON_WH                     (16.0)
#define PV_ICON_TITLE_MARGIN                 (5.0)


static NSMutableDictionary *_groupRadioDic = nil;

@implementation PvRadioButton

@synthesize delegate = _delegate;
@synthesize checked  = _checked;

-(void)setDelegate:(id<PvRadioButtonDelegate>)delegate groupId:(NSString *)groupId{
    if (self) {
        _delegate = delegate;
        _groupId = [groupId copy];
        
        [self addToGroup];
        
        self.exclusiveTouch = YES;
        
        [self setImage:[UIImage imageNamed:@"radio_unchecked.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"radio_checked.png"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(radioBtnChecked) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (id)initWithDelegate:(id)delegate groupId:(NSString *)groupId {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _groupId = [groupId copy];
        
        [self addToGroup];
        
        self.exclusiveTouch = YES;
        
        [self setImage:[UIImage imageNamed:@"radio_unchecked.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"radio_checked.png"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(radioBtnChecked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)addToGroup {
    if(!_groupRadioDic){
        _groupRadioDic = [[NSMutableDictionary dictionary] init];
    }
    
    NSMutableArray *_gRadios = [_groupRadioDic objectForKey:_groupId];
    if (!_gRadios) {
        _gRadios = [NSMutableArray array];
    }
    [_gRadios addObject:self];
    [_groupRadioDic setObject:_gRadios forKey:_groupId];
}

- (void)removeFromGroup {
    if (_groupRadioDic) {
        NSMutableArray *_gRadios = [_groupRadioDic objectForKey:_groupId];
        if (_gRadios) {
            [_gRadios removeObject:self];
            if (_gRadios.count == 0) {
                [_groupRadioDic removeObjectForKey:_groupId];
            }
        }
    }
}

- (void)uncheckOtherRadios {
    NSMutableArray *_gRadios = [_groupRadioDic objectForKey:_groupId];
    if (_gRadios.count > 0) {
        for (PvRadioButton *_radio in _gRadios) {
            if (_radio.checked && ![_radio isEqual:self]) {
                _radio.checked = NO;
            }
        }
    }
}

- (void)setChecked:(BOOL)checked {
    if (_checked == checked) {
        return;
    }
    
    _checked = checked;
    self.selected = checked;
    
    if (self.selected) {
        [self uncheckOtherRadios];
    }
    
    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedRadioButton:groupId:)]) {
        [_delegate didSelectedRadioButton:self groupId:_groupId];
    }
}

- (void)radioBtnChecked {
    if (_checked) {
        return;
    }
    
    self.selected = !self.selected;
    _checked = self.selected;
    
    if (self.selected) {
        [self uncheckOtherRadios];
    }
    
    if (self.selected && _delegate && [_delegate respondsToSelector:@selector(didSelectedRadioButton:groupId:)]) {
        [_delegate didSelectedRadioButton:self groupId:_groupId];
        
    }
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, (CGRectGetHeight(contentRect) - PV_RADIO_ICON_WH)/2.0, PV_RADIO_ICON_WH, PV_RADIO_ICON_WH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(PV_RADIO_ICON_WH + PV_ICON_TITLE_MARGIN, 0,
                      CGRectGetWidth(contentRect) - PV_RADIO_ICON_WH - PV_ICON_TITLE_MARGIN,
                      CGRectGetHeight(contentRect));
}



- (void)dealloc {
    [self removeFromGroup];
    
    _delegate = nil;
    //[_groupId release];
    _groupId = nil;
    //[super dealloc];
}


@end
