

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface UWPhoto : NSObject

@property (nonatomic, strong) UIImage *image; //图片
@property (nonatomic, strong) UIImage *thumbnailImage;

@property (nonatomic, strong) NSString *urlPath; //来源网络


@property (nonatomic, strong) PHAsset *asset; // 来自相册
@property (nonatomic, assign) PHImageRequestID assetRequestID; // 在相册id
@property (nonatomic, copy) void(^finishedLoadImage)(void);

@end
