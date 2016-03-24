

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "UWPhotoDatable.h"

@interface UWPhoto : NSObject<UWPhotoDatable>


@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *editImage;
@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, copy)   void(^imageDidFinished)(id<UWPhotoDatable> photo);
@property (nonatomic, assign) NSTimeInterval date;

@property (nonatomic, strong) PHAsset *asset; // 来自相册
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) CGSize thumbnailSize;

@property (nonatomic, strong) NSString *offset; //CGPoint
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) NSInteger filterIndex; //滤镜

@end
