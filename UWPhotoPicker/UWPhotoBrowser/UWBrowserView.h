//
//  UWBrowserView.h
//  Pods
//
//  Created by 小六 on 3月17日.
//
//

#import <UIKit/UIKit.h>
#import "UWPhotoDataManager.h"

@interface UWBrowserView : UIView

@property (nonatomic, strong) UWPhotoDataManager    *dataManager;
@property (nonatomic, copy) void(^scrollIndexPath)(NSIndexPath *indexPath);

@end
