//
//  UWPhotoBrowserBoard.m
//  Pods
//
//  Created by 小六 on 3月14日.
//
//

#import "UWPhotoBrowserBoard.h"

@interface UWPhotoBrowserBoard ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableSet *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation UWPhotoBrowserBoard

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



@end
