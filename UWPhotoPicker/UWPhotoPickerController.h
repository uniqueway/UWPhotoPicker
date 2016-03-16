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

@class UWPhotoNavigationView, UWPhotoCollectionViewCell;


typedef NS_ENUM(NSInteger, UWPickerStatus) {
    UWPickerStatusRecommed,
    UWPickerStatusAll,
};

@interface UWPhotoPickerController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, copy) void(^selectedPhotos)(NSArray <UWPhotoDatable>*list);


@property (nonatomic, strong) UWPhotoDataManager    *dataManager;

@property (nonatomic, weak  ) UICollectionView      *collectionView;
@property (nonatomic, weak  ) UWPhotoNavigationView *navBar;

@property (nonatomic, strong) NSMutableSet *modelChangedList;
@property (nonatomic, weak)   UWPhotoCollectionViewCell *selecedCell;
@end
