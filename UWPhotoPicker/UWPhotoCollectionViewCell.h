//
//  UWPhotoCollectionViewCell.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UWPhotoDatable.h"

typedef NS_ENUM(NSInteger, SelectedStyle) {
    SelectedStyleNone,
    SelectedStyleCheck,
    SelectedStyleLine,
    SelectedStyleBoth,
};


@interface UWPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id <UWPhotoDatable> photo;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy)   void(^selectedBlock)(BOOL isSelected, NSIndexPath *indexPath);
@property (nonatomic, assign) SelectedStyle selectedStyle;

- (void)cellShouldHighlight:(BOOL)isHighlight;
- (void)showLineWithHeight:(BOOL)isHightlight;
- (void)shouldScale;
- (void)loadPhoto:(id<UWPhotoDatable>)photo thumbnail:(BOOL)isThumbnail;


@end
