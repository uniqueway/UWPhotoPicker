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
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
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
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            UWPhoto *photo = [UWPhoto new];
            photo.asset = result;
            [self.allPhotos insertObject:photo atIndex:0];
        }
        
    };
    
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        
        if ([group numberOfAssets] > 0) {
            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos) {
                [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
            }
        }
        
        if (group == nil) {
            self.loadBlock(self.allPhotos, nil);
        }
        
    };
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:^(NSError *error) {
        self.loadBlock(nil, error);
    }];
}

- (NSMutableArray *)allPhotos {
    if (_allPhotos == nil) {
        _allPhotos = [NSMutableArray array];
    }
    return _allPhotos;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

@end
