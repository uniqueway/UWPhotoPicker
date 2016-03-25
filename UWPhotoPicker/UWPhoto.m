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
        CGSize size = [UIScreen mainScreen].bounds.size;
        size = CGSizeMake(size.width*2, size.height*2);
        [self loadImageWithAsset:_asset targetSize:size completion:^(UIImage *result) {
            _portraitImage = result;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)loadSourceImageCompletion:( void(^)( UIImage *image))completion {
    [self loadImageWithAsset:_asset targetSize:PHImageManagerMaximumSize completion:completion];
}

- (void)loadImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void(^)(UIImage *result))completion{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode =  PHImageRequestOptionsResizeModeNone;
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
}

- (NSString *)identifier {
    return _asset.localIdentifier;
}

- (CGSize)imageSize {
    static CGSize itemSize;
    if (itemSize.width == 0) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat itemWidth =  floorf((width - (4 - 1) * 2) / 4);
        itemSize = CGSizeMake(itemWidth*2, itemWidth*2);
    }
    return itemSize;
}

@end
