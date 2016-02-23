//
//  TWImageScrollView.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWImageScrollView.h"
#import <GPUImage/GPUImage.h>
#import "UIImage+Resize.h"

#define rad(angle) ((angle) / 180.0 * M_PI)
static const CGFloat MAX_SIZE = 1500;

@interface TWImageScrollView ()<UIScrollViewDelegate>
{
    CGSize _imageSize;
    NSInteger currentFilterType;
}

@property (strong, nonatomic) GPUImagePicture *picture;
//@property (strong, nonatomic) GPUImagePicture *originPicture;
@property (strong, nonatomic) UIImage *currentImage;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture1;
@property (nonatomic, strong) GPUImageGrayscaleFilter *grayFilter;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightnessFilter;
@property (nonatomic, strong) GPUImageSaturationFilter *saturationFilter;
@property (nonatomic, strong) GPUImageWhiteBalanceFilter *whiteBalanceFilter;
@property (nonatomic, strong) GPUImageSharpenFilter *sharpenFilter;
@property (nonatomic, strong) GPUImageContrastFilter *contrastFilter;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TWImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

/**
 *  cropping image not just snapshot , inpired by https://github.com/gekitz/GKImagePicker
 *
 *  @return image cropped
 */
- (UIImage *)capture {
    CGRect visibleRect = [self _calcVisibleRectForCropArea];//caculate visible rect for crop
    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:self.imageView.image];//if need rotate caculate
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);
    CGImageRef ref = CGImageCreateWithImageInRect([self.imageView.image CGImage], visibleRect);//crop
    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:self.imageView.image.scale orientation:self.imageView.image.imageOrientation] ;
    CGSize maxSize = CGSizeMake(MAX_SIZE, MAX_SIZE);
    CGImageRelease(ref);
    ref = NULL;
    cropped = [cropped resizedImageToFitInSize:maxSize scaleIfSmaller:YES];
    return cropped;
}


static CGRect TWScaleRect(CGRect rect, CGFloat scale)
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}


-(CGRect)_calcVisibleRectForCropArea{
    
    CGFloat sizeScale = self.imageView.image.size.width / self.imageView.frame.size.width;
    sizeScale *= self.zoomScale;
    CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
    return visibleRect = TWScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}
//- (UIImage *)capture {
//    UIImage *image = [self.imageView image];
//    CGRect visibleRect = [self _calcVisibleRectForCropArea:image.size];//caculate visible rect for crop
//    CGImageRef ref = CGImageCreateWithImageInRect([image CGImage], visibleRect);//crop
//    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:1 orientation:image.imageOrientation];
//    CGSize maxSize = CGSizeMake(MAX_SIZE, MAX_SIZE);
//    UIGraphicsBeginImageContextWithOptions(maxSize, NO, 0.0);
//    [cropped drawInRect:CGRectMake(0, 0, MAX_SIZE,MAX_SIZE)];
//    cropped = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    CGImageRelease(ref);
//    ref = NULL;
//    return cropped;
//}
//
//static CGRect TWScaleRect(CGRect rect, CGFloat scale)
//{
//    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.width * scale);
//}
//
//
//- (CGRect)_calcVisibleRectForCropArea:(CGSize)size {
//    CGFloat sizeScale = 1;
//    if (size.height > size.width) {
//        sizeScale = size.width / self.frame.size.width;
//    } else {
//        sizeScale = size.height / self.frame.size.height;
//    }
//    sizeScale *= self.zoomScale;
//    CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
//    visibleRect = TWScaleRect(visibleRect, sizeScale);
//    return visibleRect;
//}
//
//- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
//{
//    CGAffineTransform rectTransform;
//    switch (img.imageOrientation)
//    {
//        case UIImageOrientationLeft:
//            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
//            break;
//        case UIImageOrientationRight:
//            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
//            break;
//        case UIImageOrientationDown:
//            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
//            break;
//        default:
//            rectTransform = CGAffineTransformIdentity;
//    };
//    
//    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
//}

#pragma mark - Switch Filter

- (void)forceSwitchToNewFilter:(NSInteger)type {
    currentFilterType = type;
    self.filter       = nil;
    if (self.picture == nil) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.imageView.image];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.picture removeAllTargets];
        switch (type) {
            case 0: {
                break;
            }
                
            case 1: {
                self.saturationFilter.saturation    = 1.01;
                self.sharpenFilter.sharpness        = 0.1;
                self.contrastFilter.contrast        = 1.5;
                self.whiteBalanceFilter.temperature = 5000;
                self.brightnessFilter.brightness    = 0.0f;
                self.filter = self.grayFilter;
                [self addFilters];
                break;
            }
            case 2: {
                self.saturationFilter.saturation    = 1.28635494736842;
                self.sharpenFilter.sharpness        = 0;
                self.contrastFilter.contrast        = 1.2;
                self.whiteBalanceFilter.temperature = 5100;
                self.brightnessFilter.brightness    = 0.02f;
                [self addFilters];
                break;
            }
                
            case 3: {
                self.saturationFilter.saturation    = 1;
                self.sharpenFilter.sharpness        = 0;
                self.contrastFilter.contrast        = 1.3;
                self.whiteBalanceFilter.temperature = 4100;
                self.brightnessFilter.brightness    = 0.005f;
                [self addFilters];
                
                break;
            }
                
            case 4: {
                self.saturationFilter.saturation    = 1.3;
                self.sharpenFilter.sharpness        = 0;
                self.contrastFilter.contrast        = 1.7;
                self.whiteBalanceFilter.temperature = 5300;
                self.brightnessFilter.brightness    = -0.03f;
                [self addFilters];
                break;
            }
                
            default:
                break;
        }
        [self.picture processImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = nil;
            if (self.filter) {
                image = [self.filter imageFromCurrentFramebufferWithOrientation:self.imageView.image.imageOrientation];
            } else {
                image = self.currentImage;
            }
            self.imageView.image = nil;
            self.imageView.image = image;
        });
    });
}

- (void)addFilters {
    if (!self.filter) {
        self.filter = [[GPUImageFilter alloc] init];
    }
    [self.picture addTarget:self.saturationFilter];
    [self.saturationFilter addTarget:self.sharpenFilter];
    [self.sharpenFilter addTarget:self.contrastFilter];
    [self.contrastFilter addTarget:self.whiteBalanceFilter];
    [self.whiteBalanceFilter addTarget:self.brightnessFilter];
    [self.brightnessFilter addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
}

- (void)switchFilter:(NSInteger)type {
    
    if ((self.imageView.image != nil) && (self.picture == nil)) {
        self.picture = [[GPUImagePicture alloc] initWithImage:self.imageView.image];
    } else {
        if (currentFilterType == type) {
            return;
        }
    }
    [self forceSwitchToNewFilter:type];
    
}


- (void)displayImage:(UIImage *)image {
    if (!image) {
        return;
    }
    self.currentImage = image;
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
    }
    CGSize size    = self.bounds.size;
    CGFloat width  = 0;
    CGFloat height = 0;
    CGFloat x      = 0;
    CGFloat y      = 0;
    if (image.size.height > image.size.width) {
        width  = size.width;
        height = (size.width / image.size.width) * image.size.height;
    } else {
        height = size.height;
        width  = (size.height / image.size.height) * image.size.width;
    }
    currentFilterType    = 0;
    self.picture         = [[GPUImagePicture alloc] initWithImage:image];
    self.imageView.image = nil;
    self.imageView.image = image;
    CGRect frame         = CGRectMake(x, y, width, height);
    [self configureForImageSize:frame.size];
    self.contentSize = CGSizeMake(width, height);
    self.imageView.frame = frame;
    [self.scrollDelegate contentDidEdit:NO];
}

- (void)configureForImageSize:(CGSize)imageSize {
    CGSize size = self.bounds.size;
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake((imageSize.width-size.width)/2, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, (imageSize.height-size.height)/2);
    }
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;

}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 2.0;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.scrollDelegate contentDidEdit:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self.scrollDelegate contentDidEdit:YES];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


#pragma mark - getters and setters
- (GPUImageBrightnessFilter *)brightnessFilter
{
    if (_brightnessFilter == nil) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    }
    return _brightnessFilter;
}

- (GPUImageSaturationFilter *)saturationFilter
{
    if (_saturationFilter == nil) {
        _saturationFilter = [[GPUImageSaturationFilter alloc] init];
    }
    return _saturationFilter;
}

- (GPUImageWhiteBalanceFilter *)whiteBalanceFilter
{
    if (_whiteBalanceFilter == nil) {
        _whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    }
    return _whiteBalanceFilter;
}

- (GPUImageSharpenFilter *)sharpenFilter
{
    if (_sharpenFilter == nil) {
        _sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    }
    return _sharpenFilter;
}

- (GPUImageContrastFilter *)contrastFilter
{
    if (_contrastFilter == nil) {
        _contrastFilter = [[GPUImageContrastFilter alloc] init];
        _contrastFilter.contrast = 1.0f;
    }
    return _contrastFilter;
}

- (GPUImageGrayscaleFilter *)grayFilter {
    if (_grayFilter == nil) {
        _grayFilter = [[GPUImageGrayscaleFilter alloc] init];
    }
    return _grayFilter;
}

@end
