

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "UWPhotoDatable.h"

@interface UWPhoto : NSObject<UWPhotoDatable>


@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy)   void(^imageDidFinished)(id<UWPhotoDatable> photo);
@property (nonatomic, assign) NSTimeInterval date;

@property (nonatomic, strong) PHAsset *asset; // 来自相册
@property (nonatomic, assign) PHImageRequestID assetRequestID; // 在相册id
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) NSString *identifier;



@end
