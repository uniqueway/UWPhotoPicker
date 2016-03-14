//
//  UWPhotoNavigationView.h
//  Pods
//
//  Created by 小六 on 3月14日.
//
//

#import <UIKit/UIKit.h>

@interface UWPhotoNavigationView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UIButton *rightButton;


@end
