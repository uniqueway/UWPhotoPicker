//
//  UWPhotoDataManager.h
//  Pods
//
//  Created by 小六 on 2月24日.
//
//

#import <Foundation/Foundation.h>
#import "UWPhotoDatable.h"

typedef NS_ENUM(NSInteger, UWMenuIndex) {
    UWMenuIndexAll,
    UWMenuIndexRecommed,
};

typedef NS_ENUM(NSInteger, UWPhotoListType) {
    UWPhotoListTypeNone,
    UWPhotoListTypeTitle,
};

typedef NS_ENUM(NSInteger, UWPhotoCountLocation) {
    UWPhotoCountLocationNone,
    UWPhotoCountLocationTop,
    UWPhotoCountLocationBottom,
}; // 显示选择照片的位置



@interface UWPhotoDataManager : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger selectedCount;
@property (nonatomic, assign) UWPhotoCountLocation countLocation; // 选中图片个数的位置
@property (nonatomic, assign) BOOL hasRightButton; //是否带右上角确认的按钮
@property (nonatomic, assign) BOOL hasSectionTitle; //section是否带标题

@property (nonatomic, assign) BOOL isSingleSelection; // 单选多选
@property (nonatomic, strong) NSString *imageIdentifier; //单选的时候确定选中图片的id，优先赋值图片id,其次是对象id,

@property (nonatomic, assign) BOOL isSingleMenu; // 是否带「推荐」「所有照片」两个菜单项
@property (nonatomic, assign) UWMenuIndex menuIndex;
@property (nonatomic, copy) void(^finishedLoading)(void);

- (void)loadPhotosWithAll:(NSArray *)allPhotos recommendPhotos:(NSArray *)recommendPhotos singleSelection:(BOOL)isSingleSelection hasSectionTitle:(BOOL)hasSectionTitle;
- (void)changeSelectedStatus:(NSArray <NSIndexPath *> *)indexPaths;

- (id <UWPhotoDatable>)photoAtIndex:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleInSection:(NSInteger)section;

@end
