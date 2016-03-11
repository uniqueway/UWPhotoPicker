//
//  UWPhotoDatable.h
//  Pods
//
//  Created by 小六 on 3月1日.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


@protocol UWPhotoDatable <NSObject>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy)   void(^imageDidFinished)(id<UWPhotoDatable> photo);
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSTimeInterval date;

- (NSString *)modelId;
- (NSString *)imageId; // 图片储存在本地相册的localIdentifier

@end
