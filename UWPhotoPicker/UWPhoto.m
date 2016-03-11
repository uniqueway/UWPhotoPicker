//
//  TWPhoto.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "UWPhoto.h"
#import "UWPhotoPickerConfig.h"


@implementation UWPhoto

- (NSString *)selectionIdentifier {
    return _asset.localIdentifier;
}

- (void)loadImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void(^)(UIImage *result))completion{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    BOOL isOrigin = targetSize.width == 0;
    options.resizeMode = isOrigin ? PHImageRequestOptionsResizeModeNone : PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = isOrigin? PHImageRequestOptionsDeliveryModeHighQualityFormat: PHImageRequestOptionsDeliveryModeFastFormat;
    options.synchronous = NO;
    [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    }];
}

- (void)imageFinishLoading {
    NSAssert([[NSThread currentThread] isMainThread], @"这个必须在主线程调用");
    [self performSelector:@selector(postImageFinishedNotification) withObject:nil withObject:0];
}

- (void)postImageFinishedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:UWPhotoPickerLoadingDidFinishedNotification
                                                        object:self];
}

- (void)setAsset:(PHAsset *)asset {
    _asset = asset;
    _date = asset.creationDate.timeIntervalSince1970;
    [self loadImageWithAsset:asset targetSize:CGSizeMake(200, 200) completion:^(UIImage *result) {
        self.thumbnailImage = result;
        if (self.imageDidFinished) {
            self.imageDidFinished(self);
        }
    }];
}

- (NSString *)identifier {
    return _asset.localIdentifier;
}

- (UIImage *)image {
    if (!_image) {
        [self loadImageWithAsset:_asset targetSize:CGSizeZero completion:^(UIImage *result) {
            self.image = result;
            if (self.imageDidFinished) {
                self.imageDidFinished(self);
            }
        }];
    }
    return _image;
}

@end
