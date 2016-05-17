//
//  TWPhoto.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "UWPhoto.h"
#import "UWPhotoHelper.h"

@interface UWPhoto ()

@property (nonatomic, assign) PHImageRequestID imageRequestId;

@end


@implementation UWPhoto

- (NSString *)selectionIdentifier {
    return _asset.localIdentifier;
}

- (void)loadThumbnailImageCompletion:( void(^)(id <UWPhotoDatable> photo) )completion {
    if (_thumbnailImage) {
        if (completion) {
            completion(self);
        }
    }else {
        [self loadImageWithAsset:_asset targetSize:[self imageSize] completion:^(UIImage *result) {
            _thumbnailImage = result;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)loadEditedImageCompletion:( void(^)(id <UWPhotoDatable> photo) )completion {
    if (_editedImage) {
        if (completion) {
            completion(self);
        }
    }else {
        [self loadImageWithAsset:_asset targetSize:[self imageSize] completion:^(UIImage *result) {
            _editedImage = result;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)loadPortraitImageCompletion:( void(^)( id<UWPhotoDatable> photo) )completion {
    if (_portraitImage) {
        if (completion) {
            completion(self);
        }
    }else {
        CGSize size = [UIScreen mainScreen].bounds.size ;
        CGFloat scale = [UIScreen mainScreen].scale;
        size = CGSizeMake(size.width*scale, (size.height-0)*scale);
        [self loadImageWithAsset:_asset targetSize:size completion:^(UIImage *result) {

            _portraitImage = result;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)loadSourceImageCompletion:( void(^)( UIImage *image))completion {
    [self loadImageWithAsset:_asset targetSize:CGSizeMake(1500, 1500) completion:completion];
}

- (void)loadImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void(^)(UIImage *result))completion{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode =  PHImageRequestOptionsResizeModeFast;
    options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    _imageRequestId = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
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
}

- (NSString *)identifier {
    return _asset.localIdentifier;
}

- (CGSize)imageSize {
    static CGSize itemSize;
    if (itemSize.width == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat itemWidth =  floorf((width - (4 - 1) * 2) / 4);
        itemSize = CGSizeMake(itemWidth*scale, itemWidth*scale);
    }
    return itemSize;
}

- (void)cancelImageRequest {
    [[PHImageManager defaultManager] cancelImageRequest:_imageRequestId];
}
@end
