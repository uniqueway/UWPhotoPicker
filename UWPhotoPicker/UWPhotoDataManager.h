//
//  UWPhotoDataManager.h
//  Pods
//
//  Created by 小六 on 2月24日.
//
//

#import <Foundation/Foundation.h>
#import "UWPhoto.h"

typedef NS_ENUM(NSInteger, UWMenuIndex) {
    UWMenuIndexAll,
    UWMenuIndexRecommed,
};

typedef NS_ENUM(NSInteger, UWPhotoListType) {
    UWPhotoListTypeNone,
    UWPhotoListTypeTitle,
};



@interface UWPhotoDataManager : NSObject

@property (nonatomic, assign) BOOL hasTitle;
@property (nonatomic, assign) BOOL isSingleSelection; // 单选多选
@property (nonatomic, assign) BOOL isSingleMenu; // 是否带「推荐」「所有照片」两个菜单项
@property (nonatomic, assign) UWMenuIndex menuIndex;
@property (nonatomic, copy) void(^finishedLoading)(void);

- (void)loadPhotosWithAll:(NSArray <UWPhoto *> *)allPhotos recommendPhotos:(NSArray <UWPhoto *> *)recommendPhotos singleSelection:(BOOL)isSingleSelection hasTitle:(BOOL)hasTitle;

- (UWPhoto *)photoAtIndex:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleInSection:(NSInteger)section;

@end
