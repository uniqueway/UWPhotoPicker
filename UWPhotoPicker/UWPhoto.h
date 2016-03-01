

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "UWPhotoDatable.h"

@interface UWPhoto : NSObject<UWPhotoDatable>


@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy)   void(^ImageDidFinished)(id<UWPhotoDatable> photo);


@property (nonatomic, strong) PHAsset *asset; // 来自相册
@property (nonatomic, assign) PHImageRequestID assetRequestID; // 在相册id


@end
