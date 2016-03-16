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

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

static NSInteger buttonWidth = 30;

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
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:self.imageView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                     name:UWPhotoPickerLoadingDidFinishedNotification
                                                   object:nil];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    if (_selectedStyle == SelectedStyleCheck) {
        self.selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width , 0, buttonWidth, buttonWidth);
    }else if (_selectedStyle == SelectedStyleLine){
        self.lineButton.frame = self.bounds;
    }else {
        self.selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width , 0, buttonWidth, buttonWidth);
        self.lineButton.frame = self.bounds;
    }
    
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <UWPhotoDatable> photo = [notification object];
    if (photo == _photo) {
        _imageView.image = [_photo thumbnailImage];
    }
}

- (void)selectionButtonPressed {
    self.isSelected = !self.isSelected;
    
    [_selectedButton uw_scaleAnimation];
    _lineButton.selected = YES;
    if (self.selectedBlock) {
        self.selectedBlock(_selectedButton.selected, self.indexPath);
    }
}

#pragma mark - set/get
- (void)setPhoto:(id <UWPhotoDatable>)photo {
    _imageView.image = [photo thumbnailImage];
    _photo = photo;
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
    }else {
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
        _selectedButton.frame = CGRectMake(0, 0, 30, 30);
        [self.contentView addSubview:_selectedButton];
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
    }
    return _lineButton;
}

@end
