//
//  UWPhotoCollectionViewCell.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "UWPhotoCollectionViewCell.h"
#import "UWPhotoPickerConfig.h"
#import "UWPhotoDatable.h"

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

static NSInteger buttonMargin = 5;
static NSInteger buttonWidth = 30;

@interface UWPhotoCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectedButton;

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
    if (_isLineWhenSelected) {
        self.selectedButton.frame = self.bounds;
    }else {
        self.selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width , 0, buttonWidth, buttonWidth);
    }
    
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <UWPhotoDatable> photo = [notification object];
    if (photo == _photo) {
        _imageView.image = _photo.image;
    }
}

- (void)selectionButtonPressed {
    self.isSelected = !self.isSelected;
    _photo.isSelected = self.isSelected;
    if (self.selectedBlock) {
        self.selectedBlock(_selectedButton.selected, self.indexPath);
    }
}


#pragma mark - set/get
- (void)setPhoto:(id <UWPhotoDatable>)photo {
    _imageView.image = photo.image;
    _photo = photo;
    self.isSelected = _photo.isSelected;
    __weak typeof(&*self) weakself = self;
    _photo.imageDidFinished = ^(id<UWPhotoDatable> photo) {
        if (photo == _photo) {
            weakself.imageView.image = weakself.photo.image;
        }
    };
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.selectedButton.selected = isSelected;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.adjustsImageWhenHighlighted = NO;
        _selectedButton.backgroundColor = [UIColor clearColor];
        if (_isLineWhenSelected) {
            [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerLineSelected"] forState:UIControlStateSelected];
            _selectedButton.contentMode = UIViewContentModeScaleToFill;
        }else {
            [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerUnselected"] forState:UIControlStateNormal];
            [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerSelected"] forState:UIControlStateSelected];
        }
        [_selectedButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchDown];
        _selectedButton.frame = CGRectMake(0, 0, 30, 30);
        [self.contentView addSubview:_selectedButton];
    }
    return _selectedButton;
}

@end
