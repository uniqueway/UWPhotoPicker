//
//  UWPhotoCollectionViewCell.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "UWPhotoCollectionViewCell.h"
#import "UWPhotoPickerConfig.h"

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

static NSInteger buttonMargin = 5;
static NSInteger buttonWidth = 16;

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
        self.selectedButton.selected = NO;
        
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
    _selectedButton.frame = CGRectMake(self.bounds.size.width - _selectedButton.frame.size.width - buttonMargin, buttonMargin, buttonWidth, buttonWidth);
}

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    UWPhoto *photo = [notification object];
    if (photo == _photo) {
        _imageView.image = _photo.photoImage;
    }
}

- (void)selectionButtonPressed {
    _selectedButton.selected = !_selectedButton.selected;
    if (self.selectedBlock) {
        self.selectedBlock(_selectedButton.selected, self.indexPath);
    }
}


#pragma mark - set/get
- (void)setPhoto:(UWPhoto *)photo {
    _imageView.image = photo.photoImage;
    _photo = photo;
    __weak typeof(&*self) weakself = self;
    _photo.ImageDidFinished = ^(id<UWPhotoDatable> photo) {
        if (photo == _photo) {
            weakself.imageView.image = weakself.photo.photoImage;
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
        [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerUnselected"] forState:UIControlStateNormal];
        [_selectedButton setImage:[UIImage imageNamed:@"UWPhotoPickerSelected"] forState:UIControlStateSelected];
        [_selectedButton addTarget:self action:@selector(selectionButtonPressed) forControlEvents:UIControlEventTouchDown];
        _selectedButton.frame = CGRectMake(0, 0, 16, 16);
        [self.contentView addSubview:_selectedButton];
    }
    return _selectedButton;
}

@end
