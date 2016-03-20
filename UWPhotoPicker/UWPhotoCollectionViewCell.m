//
//  UWPhotoCollectionViewCell.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "UWPhotoCollectionViewCell.h"
#import "UWPhotoHelper.h"
#import "UWPhotoDatable.h"
#import <Masonry.h>

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

static NSInteger buttonWidth = 25;

@interface UWPhotoCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIButton *lineButton;

@end

@implementation UWPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UWPhotoBackgroudColor;
        self.clipsToBounds = YES;
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];

        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.offset(0);
        }];
    }
    return self;
}

- (void)selectionButtonPressed {
    self.isSelected = !self.isSelected;
    if (_selectedStyle != SelectedStyleLine) {
        [_photo setIsSelected:self.isSelected];
    }
    [_selectedButton uw_scaleAnimation];
    _lineButton.selected = YES;
    if (self.selectedBlock) {
        self.selectedBlock(_selectedButton.selected, self.indexPath);
    }
}

- (void)cellShouldHighlight:(BOOL)isHighlight {
    _lineButton.selected = isHighlight;
}

- (void)shouldScale {
    if (self.imageView.gestureRecognizers.count == 0) {
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
        self.imageView.userInteractionEnabled = YES;
        [self.imageView addGestureRecognizer:pinch];
    }
}

- (void)transformIdentity {
    self.imageView.transform = CGAffineTransformIdentity;
}

- (void)scaleImage:(UIPinchGestureRecognizer *)sender {
    sender.view.transform = CGAffineTransformScale(sender.view.transform, sender.scale, sender.scale);
    sender.scale = 1;
}

#pragma mark - set/get
- (void)setPhoto:(id <UWPhotoDatable>)photo {
    _imageView.image = [photo thumbnailImage];
    _photo = photo;
    [self transformIdentity];
    self.isSelected = _photo.isSelected;
    __weak typeof(&*self) weakself = self;
    _photo.imageDidFinished = ^(id<UWPhotoDatable> photo) {
        if (photo == _photo) {
            weakself.imageView.image = [weakself.photo thumbnailImage];
        }
    };
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (_selectedStyle == SelectedStyleCheck) {
        self.selectedButton.selected = isSelected;
    }else if(_selectedStyle == SelectedStyleLine) {
        self.lineButton.selected = isSelected;
    }else if(_selectedStyle == SelectedStyleBoth){
        self.selectedButton.selected = isSelected;
        self.lineButton.userInteractionEnabled = NO;
    }
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.adjustsImageWhenHighlighted = NO;
        _selectedButton.backgroundColor = [UIColor clearColor];
        [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerUnselected"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerSelected"] forState:UIControlStateSelected];
        [_selectedButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectedButton];
        [_selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.offset(0);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonWidth));
        }];
    }
    return _selectedButton;
}

- (UIButton *)lineButton {
    if (!_lineButton) {
        _lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lineButton.adjustsImageWhenHighlighted = NO;
        _lineButton.backgroundColor = [UIColor clearColor];
        [_lineButton setImage:[UIImage imageNamed:@"UWPhotoPickerLineSelected"] forState:UIControlStateSelected];
        _lineButton.contentMode = UIViewContentModeScaleToFill;
        [_lineButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_lineButton];
        [_lineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.offset(0);
        }];
    }
    return _lineButton;
}

@end
