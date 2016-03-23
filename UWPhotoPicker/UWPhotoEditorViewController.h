//
//  UWPhotoEditorViewController.h
//  Pods
//
//  Created by Madao on 11/6/15.
//
//

#import <UIKit/UIKit.h>
#import "UWPhotoDataManager.h"

static NSString * const UWPhotoEditorViewControllerNotification = @"UWPhotoEditorViewControllerNotification";
static NSString * const UWPhotoEditorUploadEditedImageNotification = @"UWPhotoEditorUploadEditedImageNotification";

typedef void(^cropBlock)(NSArray *list);

@interface UWPhotoEditorViewController : UIViewController

@property (nonatomic, strong) UWPhotoDataManager *dataManager;
@property (nonatomic, assign) BOOL isSingle;
@property (nonatomic, copy) void(^cropBlock)(NSArray *list);

@property (nonatomic, strong) id <UWPhotoDatable> currentPhoto;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@end
