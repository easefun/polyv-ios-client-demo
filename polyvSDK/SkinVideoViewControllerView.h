#import <UIKit/UIKit.h>

@interface SkinVideoViewControllerView : UIView

@property (nonatomic, strong, readonly) UIView *topBar;
@property (nonatomic, strong, readonly) UIView *bitRateView;
@property (nonatomic, strong, readonly) UIView *bottomBar;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong, readonly) UIButton *bitRateButton;


- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;
- (NSMutableArray*)createBitRateButton:(int)dfnum;
@end
