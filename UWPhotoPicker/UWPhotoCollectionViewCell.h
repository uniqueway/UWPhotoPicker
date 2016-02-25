//
//  UWPhotoCollectionViewCell.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UWPhoto.h"

@interface UWPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UWPhoto *photo;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIImageView *icon;

@end
