//
//  UWImageLoader.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "UWPhotoLoader.h"

@interface UWPhotoLoader ()
@property (strong, nonatomic) NSMutableArray *allPhotos;
@property (readwrite, copy, nonatomic) void(^loadBlock)(NSArray *photos, NSError *error);
@end



@implementation UWPhotoLoader

+ (UWPhotoLoader *)sharedLoader {
    static UWPhotoLoader *loader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[UWPhotoLoader alloc] init];
    });
    return loader;
}

+ (void)loadAllPhotos:(void (^)(NSArray *photos, NSError *error))completion {
    
    [[UWPhotoLoader sharedLoader].allPhotos removeAllObjects]; /* added this line to remove assets duplication*/
    [[UWPhotoLoader sharedLoader] setLoadBlock:completion];
    [[UWPhotoLoader sharedLoader] startLoading];
}

- (void)startLoading {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchresults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [fetchresults enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([asset isKindOfClass:[PHAsset class]]) {
                UWPhoto *photo = [[UWPhoto alloc] init];
                photo.asset = asset;
                [self.allPhotos addObject:@[photo]];
            }
        }];
        if (self.loadBlock) {
            self.loadBlock(self.allPhotos, nil);
        }

    });
}

- (NSMutableArray *)allPhotos {
    if (_allPhotos == nil) {
        _allPhotos = [NSMutableArray array];
    }
    return _allPhotos;
}

@end
