

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "UWPhotoDatable.h"

@interface UWPhoto : NSObject<UWPhotoDatable>


@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *editedImage;
@property (nonatomic, strong) UIImage *portraitImage;

@property (nonatomic, assign) NSTimeInterval date;

@property (nonatomic, strong) PHAsset *asset; // 来自相册
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) NSString *offset; //CGPoint
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) NSInteger filterIndex; //滤镜


@end
