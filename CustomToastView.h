#import <UIKit/UIKit.h>

@interface CustomToastView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(UIImage *)icon autoHide:(int)autoHide;
- (void)presentToast;
- (UIWindow *)getKeyWindow;
- (void)hideWithAnimation;
- (void)hideAfter:(NSTimeInterval)time;
@end

@interface CustomToastView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIStackView *hStack; 
@property (nonatomic, strong) UIStackView *vStack; 
@end