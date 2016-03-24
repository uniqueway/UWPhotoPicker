//
//  TWPhoto.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "UWPhoto.h"
#import "UWPhotoHelper.h"


@implementation UWPhoto

- (NSString *)selectionIdentifier {
    return _asset.localIdentifier;
}

- (void)loadingImageCompletion:(void (^)(id<UWPhotoDatable>))finished {
    if (_image) {
        if (finished) {
            finished(self);
        }
    }else {
        CGSize size = [UIScreen mainScreen].bounds.size;
        [self loadImageWithAsset:_asset targetSize:size completion:^(UIImage *result) {
            _image = result;
            if (finished) {
                finished(self);
            }
        }];
    }
}

- (void)loadImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void(^)(UIImage *result))completion{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode =  PHImageRequestOptionsResizeModeFast;
    options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    }];
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    _date = asset.creationDate.timeIntervalSince1970;
    [self loadImageWithAsset:asset targetSize:CGSizeMake(200, 200) completion:^(UIImage *result) {
        self.image = result;
    }];
}

- (NSString *)identifier {
    return _asset.localIdentifier;
}


- (CGSize)thumbnailSize {
    if (_thumbnailSize.width == 0) {
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - (4 - 1) * 2)/4;
        _thumbnailSize = CGSizeMake(width, width);
    }
    return _thumbnailSize;
}

@end
