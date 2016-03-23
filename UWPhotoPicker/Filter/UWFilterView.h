//
//  UWFilterView.h
//  Pods
//
//  Created by 小六 on 3月23日.
//
//

#import <UIKit/UIKit.h>

@interface UWFilterView : UIView

@property (nonatomic, assign) NSInteger currentType;
@property (nonatomic, copy) void(^selectedFilterType)(NSInteger type);

@end
