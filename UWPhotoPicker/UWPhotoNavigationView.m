//
//  UWPhotoNavigationView.m
//  Pods
//
//  Created by 小六 on 3月14日.
//
//

#import "UWPhotoNavigationView.h"
#import "Masonry.h"
#import "UIView+UWPhotoAnimation.h"
#import "UWPhotoPickerConfig.h"

static const CGFloat NavBarHeight = 44;

@interface UWPhotoNavigationView ()

@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *countLabel;

@end

@implementation UWPhotoNavigationView


#pragma mark - setter 
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setCount:(NSUInteger)count {
    
    self.countLabel.text = @(count).stringValue;
    [self.countLabel uw_scaleAnimation];
    if (count == 0 ) {
        [UIView animateWithDuration:0.3 animations:^{
            self.countLabel.alpha = 0;
        }];
    }else if (self.countLabel.alpha == 0){
        [UIView animateWithDuration:0.3 animations:^{
            self.countLabel.alpha = 1;
        }];
    }
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.left.offset(80);
            make.right.offset(-80);
            make.height.mas_equalTo(NavBarHeight);
        }];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if (!_backButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"NavigationBar_Back"] forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.offset(0);
            make.size.mas_equalTo(CGSizeMake(NavBarHeight, NavBarHeight));
        }];
        _backButton = button;
    }
    return _backButton;
}

- (UIButton *)rightButton {
    if ( !_rightButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"已选" forState:UIControlStateNormal];
        button.adjustsImageWhenHighlighted = NO;
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [button setTitleColor:UWHEX(0x00a2a0) forState:UIControlStateNormal];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.offset(0);
            make.right.offset(-10);
            make.size.mas_equalTo(CGSizeMake(35, NavBarHeight));
        }];
        _rightButton = button;
    }
    return _rightButton;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        CGFloat width = 22;
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.backgroundColor = UWHEX(0x00a2a0);
        countLabel.textAlignment = NSTextAlignmentCenter;
        countLabel.font = [UIFont boldSystemFontOfSize:12];
        countLabel.textColor = [UIColor whiteColor];
        countLabel.alpha = 0;
        countLabel.layer.cornerRadius = width/2;
        countLabel.layer.masksToBounds = YES;
        [self addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel.mas_centerY).offset(0);
            make.size.mas_equalTo(CGSizeMake(width, width));
            make.right.equalTo(self.rightButton.mas_left).offset(-5);
        }];
        _countLabel = countLabel;
    }
    return _countLabel;
}
@end
