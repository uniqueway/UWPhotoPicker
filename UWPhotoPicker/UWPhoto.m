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

- (void)loadImageWithAssetRequestID:(PHImageRequestID)requestId {
    
}



- (void)loadImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
      
    };
    _assetRequestID = [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoImage = result;
            if (self.ImageDidFinished) {
                self.ImageDidFinished(self);
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
    [self loadImageWithAsset:asset targetSize:CGSizeMake(200, 200)];
}



@end
