//
//  UWPhotoPickerConfig.h
//  Pods
//
//  Created by 小六 on 2月23日.
//
//

#ifndef UWPhotoPickerConfig_h
#define UWPhotoPickerConfig_h

#define UWPhotoBackgroudColor [UIColor colorWithRed:0.952 green:0.949 blue:0.941 alpha:1];
#define UWHEX(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define UWPhotoPickerLoadingDidFinishedNotification @"UWPhotoPickerLoadingDidFinishedNotification"

#endif /* UWPhotoPickerConfig_h */
