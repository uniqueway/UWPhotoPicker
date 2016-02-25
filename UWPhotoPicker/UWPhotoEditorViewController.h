//
//  UWPhotoEditorViewController.h
//  Pods
//
//  Created by Madao on 11/6/15.
//
//

#import <UIKit/UIKit.h>

static NSString * const UWPhotoEditorViewControllerNotification = @"UWPhotoEditorViewControllerNotification";
static NSString * const UWPhotoEditorUploadEditedImageNotification = @"UWPhotoEditorUploadEditedImageNotification";

typedef void(^cropBlock)(NSArray *list);
@interface UWPhotoEditorViewController : UIViewController

@property (nonatomic, copy) void(^cropBlock)(NSArray *list);

- (id)initWithPhotoList:(NSArray *)list crop:(cropBlock)crop;

@end
