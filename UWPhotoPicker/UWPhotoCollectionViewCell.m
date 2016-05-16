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
#import "UWZoomingScrollView.h"

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

static NSInteger buttonWidth = 25;

@interface UWPhotoCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIButton *lineButton;
@property (nonatomic, strong) UWZoomingScrollView *scrollView;

@end

@implementation UWPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UWPhotoBackgroudColor;
        self.clipsToBounds = YES;
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
        self.imageView.frame = self.bounds;
        
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

- (void)showLineWithHeight:(BOOL)isHightlight {
    _selectedStyle = SelectedStyleLine;
    self.lineButton.selected = isHightlight;
}

- (void)shouldScale {
    self.scrollView.photo = self.photo;
}

- (void)transformIdentity {
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
}


- (void)loadPhoto:(id<UWPhotoDatable>)photo thumbnail:(BOOL)isThumbnail {
    _photo = photo;
    [self transformIdentity];
    self.isSelected = _photo.isSelected;
    __weak typeof(&*self) weakself = self;
    _imageView.image = nil;
    _imageView.image = [_photo thumbnailImage];
    if (isThumbnail) {
        [_photo loadThumbnailImageCompletion:^(id<UWPhotoDatable> photo) {
            if (photo == _photo) {
                weakself.imageView.image = [weakself.photo thumbnailImage];
            }
        }];
    }else {
        [_photo loadPortraitImageCompletion:^(id<UWPhotoDatable> photo) {
            if (photo == _photo) {
                weakself.imageView.image = [weakself.photo portraitImage];
            }
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - set/get
- (void)setPhoto:(id <UWPhotoDatable>)photo {
    [self loadPhoto:photo thumbnail:YES];
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

- (UWZoomingScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UWZoomingScrollView alloc] init];
        _scrollView.frame = [UIScreen mainScreen].bounds;
        [self.contentView addSubview:_scrollView];
        
    }
    return _scrollView;
}

@end
