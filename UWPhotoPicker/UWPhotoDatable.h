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
@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, copy)   void(^imageDidFinished)(id<UWPhotoDatable> photo);
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSTimeInterval date;

- (NSString *)selectionIdentifier;// 优先imageId > modelId

@end
