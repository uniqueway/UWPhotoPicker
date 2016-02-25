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
    UWMenuIndexRecommed,
    UWMenuIndexAll,
};

@interface UWPhotoDataManager : NSObject

@property (nonatomic, assign) BOOL hasTitle;
@property (nonatomic, assign) BOOL isSingleSelection; // 单选多选
@property (nonatomic, assign) BOOL isSingleMenu; // 是否带「推荐」「所有照片」两个菜单项
@property (nonatomic, assign) UWMenuIndex menuIndex;


- (void)loadPhotosWithAll:(NSArray *)allPhotos recommendPhotos:(NSArray *)recommendPhotos singleSelection:(BOOL)isSingleSelection hasTitle:(BOOL)hasTitle;

- (UWPhoto *)photoAtIndex:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (NSString *)titleInSection:(NSInteger)section;
@end
