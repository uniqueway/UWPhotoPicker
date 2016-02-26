//
//  UWPhotoDataManager.m
//  Pods
//
//  Created by 小六 on 2月24日.
//
//

#import "UWPhotoDataManager.h"
#import <Photos/Photos.h>
#import "NSDate+UWPhotoPicker.h"

@interface UWPhotoDataManager ()

@property (nonatomic, strong) NSMutableArray *allPhotosTitles;
@property (nonatomic, strong) NSArray *allPhotos;
@property (nonatomic, strong) NSMutableArray *recommendTitles;
@property (nonatomic, strong) NSArray *recommendPhotos;

@end

@implementation UWPhotoDataManager

- (void)loadPhotosWithAll:(NSArray *)allPhotos recommendPhotos:(NSArray *)recommendPhotos singleSelection:(BOOL)isSingleSelection hasTitle:(BOOL)hasTitle{
    self.allPhotos = allPhotos;
    self.recommendPhotos = recommendPhotos;
    _isSingleSelection = isSingleSelection;
    _hasTitle = hasTitle;
    if (self.recommendPhotos.count > 0) {
        _isSingleMenu = NO;
        _menuIndex = UWMenuIndexRecommed;
    }else {
        _isSingleMenu = YES;
        _menuIndex = UWMenuIndexAll;
    }
    if (_hasTitle) {
        [self handleTitle];
    }
}

- (void)handleTitle {
    self.allPhotosTitles = [NSMutableArray array];
    self.recommendTitles = [NSMutableArray array];
    
    for (NSArray *group in self.allPhotos) {
        UWPhoto *photo = group.firstObject;
        NSString *title = [photo.asset.creationDate uwpp_DateFormatByDot];
        [self.allPhotosTitles addObject:title];
    }
    
    for (NSArray *group in self.recommendPhotos) {
        UWPhoto *photo = group.firstObject;
        NSString *title = [photo.asset.creationDate uwpp_DateFormatByDot];
        [self.recommendTitles addObject:title];
    }
    
    if (self.finishedLoading) {
        self.finishedLoading();
    }
}

- (UWPhoto *)photoAtIndex:(NSIndexPath *)indexPath {
    if (!_hasTitle) {
        if (indexPath.row < self.allPhotos.count) {
            return self.allPhotos[indexPath.row];
        }else {
            return nil;
        }
    }
    
    if (_menuIndex == UWMenuIndexRecommed) {
        return self.recommendPhotos[indexPath.section][indexPath.row];
    }else if (_menuIndex == UWMenuIndexAll) {
        return self.allPhotos[indexPath.section][indexPath.row];
    }
    return nil;
}

- (NSString *)titleInSection:(NSInteger)section {
    return _menuIndex == UWMenuIndexRecommed ? self.recommendTitles[section] : self.allPhotosTitles[section];
}

- (NSInteger)numberOfSections {
    if (!_hasTitle) {
        return 1;
    }
    if (_menuIndex == UWMenuIndexRecommed) {
        return self.recommendTitles.count;
    }else if (_menuIndex == UWMenuIndexAll) {
        return self.allPhotosTitles.count;
    }
    return 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    if (!_hasTitle) {
        return self.allPhotosTitles.count;
    }
    if (_menuIndex == UWMenuIndexAll) {
        return [self.allPhotos[section] count];
    }else if (_menuIndex == UWMenuIndexRecommed) {
        return [self.recommendPhotos[section] count];
    }
    return 0;
    
}
@end