//
//  UWPhotoPickerController.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UWPhotoDataManager.h"


typedef NS_ENUM(NSInteger, UWPickerStatus) {
    UWPickerStatusRecommed,
    UWPickerStatusAll,
};

@interface UWPhotoPickerController : UIViewController

@property (nonatomic, copy) void(^selectedPhotos)(NSArray *list);
@property (nonatomic, copy) void(^cropBlock)(NSArray *list);
@property (nonatomic, strong) UWPhotoDataManager *photoData;
@property (nonatomic, assign) NSInteger limit;



@end
