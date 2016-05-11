//
//  UWZoomingScrollView.h
//  Pods
//
//  Created by 小六 on 5月9日.
//
//

#import <UIKit/UIKit.h>
#import "UWPhotoDatable.h"


@interface UWZoomingScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic) id <UWPhotoDatable> photo;


@end
