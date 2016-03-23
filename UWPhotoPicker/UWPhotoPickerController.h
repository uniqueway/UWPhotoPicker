//
//  UWPhotoPickerController.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UWPhotoDataManager.h"
#import "UWPhotoDatable.h"

#import "UWPhotoCollectionViewCell.h"


@class UWPhotoNavigationView, UWPhotoCollectionViewCell;


typedef NS_ENUM(NSInteger, UWPickerStatus) {
    UWPickerStatusRecommed,
    UWPickerStatusAll,
};

@interface UWPhotoPickerController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy) void(^selectedPhotos)(NSArray *list);


@property (nonatomic, strong) UWPhotoDataManager    *dataManager;

@property (nonatomic, weak  ) UICollectionView      *collectionView;
@property (nonatomic, weak  ) UWPhotoNavigationView *navBar;

@property (nonatomic, strong) NSMutableSet *modelChangedList;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

/**
 *  @brief 子类重写，选择的样子，无，对勾，线框，对勾和线框
 */
- (SelectedStyle)selectedStyle;
/**
 *  @brief 点击对勾的时候调用
 */
- (void)handlePhotoStatusAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)isSelected;
- (void)calculateCountOfSelectedPhotosByNum:(NSUInteger)count;

@end
