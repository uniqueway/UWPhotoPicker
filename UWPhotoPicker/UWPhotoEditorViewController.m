//
//  UWPhotoEditorViewController.m
//  Pods
//
//  Created by Madao on 11/6/15.
//
//

#import "UWPhotoEditorViewController.h"
#import "UWPhotoFilterCollectionViewCell.h"
#import "UWPhoto.h"
#import "UWImageScrollView.h"
#import "UWPhotoImageItem.h"
#import <SVProgressHUD.h>
#import <Masonry.h>

#import <mach/mach_time.h>
#import "UWPhotoDatable.h"
#import "UWPhotoNavigationView.h"
#import "UWFilterView.h"


#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
#define NavigationBarHeight 44

@interface UWPhotoEditorViewController()<UICollectionViewDataSource, UICollectionViewDelegate,UWImageScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableArray *thumbnailImageList;



@property (nonatomic, assign) BOOL isEdited;
@property (nonatomic, strong) UWImageScrollView *imageScrollView;
@property (nonatomic, assign) NSInteger currentType;
@property (strong, nonatomic) NSMutableSet *resultList;
@property (strong, nonatomic) UIButton *nextOrSubmitButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CALayer *maskLayer;



@property (nonatomic, weak  ) UWPhotoNavigationView *navBar;
@property (nonatomic, weak) UWFilterView *filterView;
@property (nonatomic, assign) CGFloat filterBottomMargin;

@property (nonatomic, strong) CALayer *topMaskLayer;
@property (nonatomic, strong) CALayer *bottomMaskLayer;

@end

@implementation UWPhotoEditorViewController


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resultList   = [[NSMutableSet alloc] initWithCapacity:1];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets =     NO;
    self.view.clipsToBounds = YES;
    self.filterBottomMargin = 105;
    [self updateImageAtIndex:self.currentIndexPath];
    self.filterView.selectedFilterType = ^(NSInteger type){
        [self.imageScrollView switchFilter:type];
    };
    [self buildLayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:animated];
}

- (void)buildLayer {

    CGFloat maskHeight = 0;
    CGFloat topHeight = 0;
    if (!self.needFilter) { // 美化推荐背景图
        maskHeight = round(SCREEN_WIDTH/3 * 2);
        topHeight = (SCREEN_HEIGHT - NavigationBarHeight - maskHeight)/2;
    } else if ( !self.dataManager) { // 美化照片
        maskHeight = SCREEN_WIDTH;
        topHeight = (SCREEN_HEIGHT - NavigationBarHeight - maskHeight - 115)/2;
    }else {
        maskHeight = SCREEN_WIDTH;
        topHeight = (SCREEN_HEIGHT - NavigationBarHeight - maskHeight - 115 - 75)/2;
    }
    
    self.topMaskLayer.frame = CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, topHeight);
    [self.view.layer addSublayer:[self maskLayer:CGRectMake(0, CGRectGetMaxY(self.topMaskLayer.frame), SCREEN_WIDTH, maskHeight)]];
    self.bottomMaskLayer.frame = CGRectMake(0, CGRectGetMaxY(self.maskLayer.frame), SCREEN_WIDTH, topHeight);
    
    [self.view.layer addSublayer:self.bottomMaskLayer];
    [self.view.layer addSublayer:self.topMaskLayer];
}

- (void)updateImageAtIndex:(NSIndexPath *)indexPath {
    id <UWPhotoDatable> photo = self.currentPhoto;
    if (!photo) {
        photo = [_dataManager photoAtIndex:indexPath];
    }
    [self.imageScrollView displayImage:[photo thumbnailImage]];
    [self.imageScrollView switchFilter:[photo filterIndex]];
    [self.imageScrollView setZoomScale:[photo scale]];
    [self.imageScrollView setContentOffset:CGPointFromString([photo offset])];
    self.filterView.currentType = [photo filterIndex];
    //FIXME: 移动到当前的IndexPath
}

- (void)contentDidEdit:(BOOL)flag {
    self.isEdited = flag;
}

- (void)savePhotoCurrentStatus {
    
    id <UWPhotoDatable> photo = self.currentPhoto;
    photo.filterIndex = self.filterView.currentType;
    photo.scale = self.imageScrollView.zoomScale;
    photo.offset = NSStringFromCGPoint(self.imageScrollView.contentOffset);
    photo.image = self.imageScrollView.capture;
    [self.resultList addObject:photo];
}

#pragma mark - event - 
- (void)finishFix {
    [self savePhotoCurrentStatus];
    if (self.resultList.count > 0 && self.cropBlock) {
        self.cropBlock([self.resultList allObjects]);
    }
    [self backAction];
}

#pragma mark - event response

- (void)backAction {
  [self.navigationController popViewControllerAnimated:YES];
}

+ (UIImage *)imageWithCGColor:(CGColorRef)cgColor_
                         size:(CGSize)size_
{
    CGFloat systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    CGFloat scale = systemVer >= 4.0 ? UIScreen.mainScreen.scale : 1.0;
    
    return [self imageWithCGColor:cgColor_ size:size_ scale:scale];
}

+ (UIImage *)imageWithCGColor:(CGColorRef)cgColor_
                         size:(CGSize)size_
                        scale:(CGFloat)scale_
{
    CGFloat systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ( systemVer >= 4.0 ) {
        UIGraphicsBeginImageContextWithOptions(size_, NO, scale_);
    }
    else {
        UIGraphicsBeginImageContext(size_);
    }
    
    CGRect rect = CGRectZero;
    rect.size = size_;
    
    UIColor *color = [UIColor colorWithCGColor:cgColor_];
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
    [color setFill];
    [rectanglePath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)fixrotation:(UIImage *)image {
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

+ (UIImage *)generatePhotoThumbnail:(UIImage *)image {
    image = [self fixrotation:image];
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio   = SCREEN_WIDTH/3 - 20;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    // Done Resizing
    
    return thumbnail;
}

#pragma mark getters & setters

- (CALayer *)maskLayer:(CGRect)frame {
    if (!_maskLayer) {
        CALayer *maskLayer = [CALayer layer];
        maskLayer.bounds   = frame;
        CGFloat y          = CGRectGetMinY(frame);
        CGFloat height     = CGRectGetHeight(frame);
        CGFloat width      = CGRectGetWidth(frame);
        maskLayer.position = CGPointMake(width/2, height/2+y);
        for (int i = 0; i < 4; i++) {
            CAShapeLayer *line = [CAShapeLayer layer];
            UIBezierPath *linePath=[UIBezierPath bezierPath];
            CGPoint startPoint,endPoint;
            CGFloat per = (i%2)*0.33 + 0.33;
            if (i > 1) {
                startPoint = CGPointMake(per*width, y);
                endPoint   = CGPointMake(per*width, height+y);
            } else {
                startPoint = CGPointMake(0, per*height+y);
                endPoint   = CGPointMake(width, per*height+y);
            }
            [linePath moveToPoint: startPoint];
            [linePath addLineToPoint:endPoint];
            line.path         = linePath.CGPath;
            line.fillColor    = nil;
            line.opacity      = 0.7;
            line.shadowColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
            line.shadowRadius = 2;
            line.strokeColor  = [UIColor whiteColor].CGColor;
            [maskLayer addSublayer:line];
        }
        _maskLayer = maskLayer;
    }
    return _maskLayer;
}

- (CALayer *)topMaskLayer {
    if (!_topMaskLayer) {
        _topMaskLayer = [CALayer layer];
        _topMaskLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
        
    }
    return _topMaskLayer;
}

- (CALayer *)bottomMaskLayer {
    if (!_bottomMaskLayer) {
        _bottomMaskLayer = [CALayer layer];
        _bottomMaskLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    }
    return _bottomMaskLayer;
}

- (UWPhotoNavigationView *)navBar {
    if (!_navBar) {
        UWPhotoNavigationView *navBar = [[UWPhotoNavigationView alloc] init];
        navBar.backgroundColor = [UIColor blackColor];
        [navBar.backButton setImage:[UIImage imageNamed:@"UWNavigationBarWhiteBack"] forState:UIControlStateNormal];
        [navBar.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navBar.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [navBar.rightButton setTitle:@"完成" forState:UIControlStateNormal];
        [navBar.rightButton addTarget:self action:@selector(finishFix) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:navBar];
        [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.height.mas_equalTo(NavigationBarHeight);
        }];
        _navBar = navBar;
    }
    return _navBar;
}

- (UWImageScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [[UWImageScrollView alloc] initWithFrame:[self rectForScrollView]];
        _imageScrollView.backgroundColor = [UIColor blackColor];
        _imageScrollView.scrollDelegate  = self;
        [self.view addSubview:_imageScrollView];
        [_imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navBar.mas_bottom).offset(0);
            make.left.right.offset(0);
            make.bottom.equalTo(self.filterView.mas_top).offset(0);
        }];
    }
    return _imageScrollView;
}

- (UWFilterView *)filterView {
    if (!_filterView) {
        UWFilterView *filterView = [[UWFilterView alloc] init];
        [self.view addSubview:filterView];
        [filterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.offset(0);
            make.bottom.offset(-10);
            make.height.mas_equalTo(self.filterBottomMargin);
        }];
        _filterView = filterView;
    }
    return _filterView;
}

- (CGRect)rectForScrollView {
    CGRect rect = CGRectMake(0, NavigationBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavigationBarHeight - self.filterBottomMargin);
    return rect;
}
@end
