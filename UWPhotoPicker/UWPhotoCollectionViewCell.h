//
//  UWPhotoCollectionViewCell.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UWPhotoDatable.h"

@interface UWPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) id <UWPhotoDatable> photo;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy)   void(^selectedBlock)(BOOL isSelected, NSIndexPath *indexPath);


@end
