//
//  UWImageScrollView.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImagePicture.h"
//#import "IFImageFilter.h"
//#import "InstaFilters.h"

@protocol UWImageScrollViewDelegate <NSObject>
- (void)contentDidEdit:(BOOL)flag;
@end

@interface UWImageScrollView : UIScrollView

@property (nonatomic, weak) id<UWImageScrollViewDelegate> scrollDelegate;

- (void)displayImage:(UIImage *)image;
- (UIImage *)capture;

- (void)switchFilter:(NSInteger)type;
@end
