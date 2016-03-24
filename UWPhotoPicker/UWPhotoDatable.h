//
//  UWPhotoDatable.h
//  Pods
//
//  Created by 小六 on 3月1日.
//
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "UWPhotoDatable.h"


@protocol UWPhotoDatable <NSObject>

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *editImage;
@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) NSTimeInterval date;

@property (nonatomic, strong) NSString *offset; //CGPoint
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) NSInteger filterIndex; //滤镜

- (NSString *)selectionIdentifier;// 优先imageId > modelId

- (void)loadingImageCompletion:( void(^)( id<UWPhotoDatable>  photo) )finished;



@end
