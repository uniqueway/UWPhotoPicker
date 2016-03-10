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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.countLocation = UWPhotoCountLocationNone;
        self.hasRightButton = YES;
        self.hasSectionTitle = YES;
        self.isSingleSelection = NO;
        self.isSingleMenu = YES;
    }
    return self;
}

- (void)loadPhotosWithAll:(NSArray *)allPhotos recommendPhotos:(NSArray *)recommendPhotos singleSelection:(BOOL)isSingleSelection hasSectionTitle:(BOOL)hasSectionTitle{
    self.allPhotos = allPhotos;
    self.recommendPhotos = recommendPhotos;
    _isSingleSelection = isSingleSelection;
    _hasSectionTitle = hasSectionTitle;
    _selectedCount = 0;
    if (self.recommendPhotos.count > 0) {
        _isSingleMenu = NO;
        _menuIndex = UWMenuIndexRecommed;
    }else {
        _isSingleMenu = YES;
        _menuIndex = UWMenuIndexAll;
    }
    if (_hasSectionTitle) {
        [self handleTitle];
    }
}

- (void)changeSelectedStatus:(NSArray<NSIndexPath *> *)indexPaths {
//    for (NSIndexPath *indexPath in indexPaths) {
//        id <UWPhotoDatable> model = [self photoAtIndex:indexPath];
//    }
}

- (void)handleTitle {
    self.allPhotosTitles = [NSMutableArray array];
    self.recommendTitles = [NSMutableArray array];
    
    for (NSArray *group in self.allPhotos) {
        id <UWPhotoDatable> photo = group.firstObject;
        NSString *title = [[NSDate dateWithTimeIntervalSince1970:photo.date] uwpp_DateFormatByDot];
        [self.allPhotosTitles addObject:title];
        for (id<UWPhotoDatable>photo in group) {
            if (photo.isSelected) {
                _selectedCount++;
            }
        }
    }
    
    for (NSArray *group in self.recommendPhotos) {
        id <UWPhotoDatable> photo = group.firstObject;
        NSString *title = [[NSDate dateWithTimeIntervalSince1970:photo.date] uwpp_DateFormatByDot];
        [self.recommendTitles addObject:title];
        if (_selectedCount == 0) {
            for (id<UWPhotoDatable>photo in group) {
                if (photo.isSelected) {
                    _selectedCount++;
                }
            }
        }
    }
    
    if (self.finishedLoading) {
        self.finishedLoading();
    }
}

- (id <UWPhotoDatable>)photoAtIndex:(NSIndexPath *)indexPath {
    if (!_hasSectionTitle) {
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
    if (!_hasSectionTitle) {
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
    if (!_hasSectionTitle) {
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
