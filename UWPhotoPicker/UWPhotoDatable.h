//
//  UWPhotoDatable.h
//  Pods
//
//  Created by 小六 on 3月1日.
//
//

#import <Foundation/Foundation.h>



@protocol UWPhotoDatable <NSObject>

@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy)   void(^ImageDidFinished)(id<UWPhotoDatable> photo);

@end
