//
//  UWPhotoHelper.h
//  Pods
//
//  Created by 小六 on 3月16日.
//
//

#import <Foundation/Foundation.h>


#define UWPhotoBackgroudColor [UIColor colorWithRed:0.952 green:0.949 blue:0.941 alpha:1];
#define UWHEX(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define UWPhotoPickerLoadingDidFinishedNotification @"UWPhotoPickerLoadingDidFinishedNotification"


@interface UWPhotoHelper : NSObject

@end

#pragma mark - NSDate -

@interface NSDate (UWPhotoPicker)

/**
 *  @brief  格式：YYYY.MM.dd
 */
- (NSString *)uwpp_DateFormatByDot;

@end

#pragma mark - Animation -

@interface UIView (UWPhotoAnimation)

- (void)uw_scaleAnimation;

@end
