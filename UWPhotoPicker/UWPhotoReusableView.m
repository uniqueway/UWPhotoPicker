//
//  UWPhotoReusableView.m
//  Pods
//
//  Created by 小六 on 2月23日.
//
//

#import "UWPhotoReusableView.h"
#import "UWPhotoPickerConfig.h"

@interface UWPhotoReusableView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation UWPhotoReusableView

- (void)prepareForReuse {
    self.backgroundColor = UWPhotoBackgroudColor;

}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 10)];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [UIColor colorWithRed:0.588 green:0.588 blue:0.588 alpha:1];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
