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
@property (nonatomic, strong) UIScrollView *scrollView;

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
    if (!_scrollView) {
        self.contentView.backgroundColor = [UIColor blackColor];
        [self.scrollView addSubview:self.imageView];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self adjustImage];
    }
}

- (void)adjustImage {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize size = self.imageView.image.size;
    size.height = size.height/scale;
    size.width  = size.width/scale;
    CGRect rect = CGRectZero;
    if (size.height > self.bounds.size.height || size.width > self.bounds.size.width) {
        CGFloat ratio = size.width/self.bounds.size.width;
        CGFloat height = size.height * ratio;
        rect.size.width = self.bounds.size.width;
        rect.size.height = height;
    }else {
        rect = self.bounds;
    }
    _scrollView.contentSize = rect.size;
    if (self.frame.size.height < rect.size.height) {
        _scrollView.contentOffset = CGPointMake(0, (rect.size.height-self.frame.size.height)/2);
    }
    
    
    
//    CGFloat imageRatio = size.width/size.height;
//    CGFloat height = self.frame.size.height / imageRatio;
//    CGFloat y = (self.frame.size.height - height)/2;
    
    self.imageView.frame = rect;
}

- (void)transformIdentity {
    _scrollView.zoomScale = _scrollView.minimumZoomScale;
}


- (void)loadPhoto:(id<UWPhotoDatable>)photo thumbnail:(BOOL)isThumbnail {
    _photo = photo;
    [self transformIdentity];
    self.isSelected = _photo.isSelected;
    __weak typeof(&*self) weakself = self;
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
                if (_scrollView) {
                    [self adjustImage];
                }
            }
        }];
    }
}

#pragma mark - UIScrollViewDelegate

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
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

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.frame = self.bounds;
        [self.contentView addSubview:_scrollView];
        
    }
    return _scrollView;
}

@end
