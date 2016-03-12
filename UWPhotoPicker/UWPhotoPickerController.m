//
//  UWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "UWPhotoPickerController.h"
#import "UWPhotoEditorViewController.h"
#import "UWPhotoCollectionViewCell.h"
#import "UWPhotoLoader.h"
#import "SVProgressHUD.h"
#import "UWPhotoReusableView.h"
#import "UWPhotoPickerConfig.h"
#import "SDSegmentedControl.h"
#import "UWPhotoDatable.h"
#import "UIView+UWPhotoAnimation.h"

#define NavigationBarHeight 64
static CGFloat kBottomSegmentHeight = 45;
static CGFloat kSegmentItemWidth = 70;
static NSInteger MAX_SELECTION_COUNT = INFINITY;
static CGFloat kCountLabelWidth = 22.f;

@interface UWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate> {
    CGFloat beginOriginY;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableSet *modelChangedList;
@property (nonatomic, weak)   UWPhotoCollectionViewCell *selecedCell;
@property (strong, nonatomic) UIButton *cropBtn;
@property (nonatomic, assign) UWPickerStatus status;

@property (nonatomic, strong) SDSegmentedControl *segmentedControl;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSInteger selectedCount;

@end

@implementation UWPhotoPickerController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView reloadData];
    [self.view addSubview:self.topView];
    self.modelChangedList = [NSMutableSet set];
    __weak __typeof(&*self)weakSelf = self;
    _photoData.finishedLoading = ^{
        [weakSelf calculateCountOfSelectedPhotos];
        [weakSelf.collectionView reloadData];
    };
    [self.view addSubview:self.segmentedControl];
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)handlePhotoStatusAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)isSelected {
    
    id <UWPhotoDatable> photo = [self.photoData photoAtIndex:indexPath];
    self.photoData.selectedCount += isSelected ? 1 : -1;

    if (_photoData.isSingleSelection) { // 单选时，取消上一个图片选中状态，移除所有图片
        UWPhotoCollectionViewCell *cell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell != self.selecedCell) {
            self.selecedCell.isSelected = NO;
            self.selecedCell = cell;
            _photoData.selectionIdentifier = [photo selectionIdentifier];
        }else {
            cell.isSelected = YES;
        }
        if (!_photoData.hasRightButton) { // 没有「确定」按钮时，选择即返回
            [self confirmSelectedImages];
        }
    }
    
    // 单选时，不包含就选移出所有，再添加新的；多选的时候包含当前model，移出当前model，改的只有是否选中状态，并且成对出现，第二次出现时，并未对此model做修改
    if (_photoData.isSingleSelection) {
        if (![self.modelChangedList containsObject:photo]) {
            [self.modelChangedList removeAllObjects];
            [self.modelChangedList addObject:photo];
        }
    }else {
        if ([self.modelChangedList containsObject:photo]) {
            [self.modelChangedList removeObject:photo];
        }else {
            [self.modelChangedList addObject:photo];
        }
    }
    [self calculateCountOfSelectedPhotos];
}

#pragma mark - event
/// 选择的图片个数
- (void)calculateCountOfSelectedPhotos {
    if (!_photoData.isSingleSelection) {
        // 赋值
        if (_photoData.countLocation == UWPhotoCountLocationBottom) {
            self.countLabel.text = [NSString stringWithFormat:@"已选: %@",@(self.photoData.selectedCount)];
        }else {
            self.countLabel.text = @(self.photoData.selectedCount).stringValue;
            [self.countLabel uw_scaleAnimation];
        }
        // 动画
        if (self.photoData.selectedCount == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.countLabel.alpha = 0;
            }];
        }else if (self.countLabel.alpha == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                self.countLabel.alpha = 1;
            }];
        }
        
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return [self.photoData numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.photoData numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UWPhotoDatable> photo = [self.photoData photoAtIndex:indexPath];
    static NSString *CellIdentifier = @"UWPhotoCollectionViewCell";
    UWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.isLineWhenSelected = _photoData.isSingleSelection;
    cell.photo = photo;
    cell.indexPath = indexPath;
    cell.selectedBlock = ^(BOOL isSelected, NSIndexPath *indexPath) {
        [self handlePhotoStatusAtIndexPath:indexPath selected:isSelected];
    };
    if (_photoData.isSingleSelection && !self.selecedCell) { // 单选时，确定选择状态
        cell.isSelected = NO;
        BOOL isThis = [_photoData.selectionIdentifier isEqualToString:[photo selectionIdentifier]];
        if ( isThis ) {
            cell.isSelected = YES;
            self.selecedCell = cell;
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UWPhotoReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UWPhotoReusableView class]) forIndexPath:indexPath];
        view.title = [self.photoData titleInSection:indexPath.section];
        return view;
    }
    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}

#pragma mark - event response

- (void)backAction {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)confirmSelectedImages {
    if (self.selectedPhotos) {
        NSArray <UWPhotoDatable>*tmp =  [self.modelChangedList allObjects];
        self.selectedPhotos(tmp);
    }
    if (_photoData.isSingleSelection) {
        [self backAction];
    }
}

- (void)segmentValueChanged:(SDSegmentedControl *)sender {
    self.selecedCell = nil;
    self.photoData.menuIndex = sender.selectedSegmentIndex == 0?  UWMenuIndexRecommed : UWMenuIndexAll;
    [self.collectionView reloadData];
}
#pragma mark - getters & setters

- (UIView *)topView {
    if (_topView == nil) {
        CGFloat navHeight = 44;
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), NavigationBarHeight);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.clipsToBounds = YES;
        self.topView.backgroundColor = [UIColor whiteColor];
        
        rect = CGRectMake(0, 20, CGRectGetWidth(self.topView.bounds), navHeight);
        UIView *navView = [[UIView alloc] initWithFrame:rect];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(0, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"NavigationBar_Back"]
                 forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        CGFloat titleWidth = 100;
        rect = CGRectMake((CGRectGetWidth(navView.bounds)-titleWidth)/2, 0, titleWidth, navHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = _photoData.title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [navView addSubview:titleLabel];
        
        if (_photoData.hasRightButton) {
            rect = CGRectMake(CGRectGetWidth(navView.bounds)-45, 0, 40, CGRectGetHeight(navView.bounds));
            self.cropBtn = [[UIButton alloc] initWithFrame:rect];
            [self.cropBtn setTitle:@"确定" forState:UIControlStateNormal];
            [self.cropBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
            [self.cropBtn setTitleColor:UWHEX(0x00a2a0) forState:UIControlStateNormal];
            [self.cropBtn addTarget:self action:@selector(confirmSelectedImages) forControlEvents:UIControlEventTouchUpInside];
            [navView addSubview:self.cropBtn];
        }
        if (_photoData.countLocation == UWPhotoCountLocationTop) {
            [navView addSubview:self.countLabel];
        }
    }
    return _topView;
}

- (UIButton *)buttonWithTitle:(NSString *)title withSize:(CGSize)size{
    UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *darkColor  = [UIColor colorWithRed:46.0/255.0 green:43.0/255.0 blue:37.0/255.0 alpha:1];
    UIColor *whiteColor = [UIColor whiteColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:darkColor forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateSelected];
    [button setBackgroundImage:[self.class imageWithCGColor:whiteColor.CGColor size:size] forState:UIControlStateNormal];
    [button setBackgroundImage:[self.class imageWithCGColor:darkColor.CGColor size:size] forState:UIControlStateSelected];
    
    return button;
}

+ (UIImage *)imageWithCGColor:(CGColorRef)cgColor_
                         size:(CGSize)size_
{
    CGFloat systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    CGFloat scale = systemVer >= 4.0 ? UIScreen.mainScreen.scale : 1.0;
    
    return [self imageWithCGColor:cgColor_ size:size_ scale:scale];
}

+ (UIImage *)imageWithCGColor:(CGColorRef)cgColor_
                         size:(CGSize)size_
                        scale:(CGFloat)scale_
{
    CGFloat systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ( systemVer >= 4.0 ) {
        UIGraphicsBeginImageContextWithOptions(size_, NO, scale_);
    }
    else {
        UIGraphicsBeginImageContext(size_);
    }
    
    CGRect rect = CGRectZero;
    rect.size = size_;
    UIColor *color = [UIColor colorWithCGColor:cgColor_];
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
    [color setFill];
    [rectanglePath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
        
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, value);
        layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing      = spacing;
        layout.minimumLineSpacing           = spacing;
        layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 30);
        
        CGRect rect = CGRectMake(0, NavigationBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) -NavigationBarHeight-5);
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, kBottomSegmentHeight, 0);
        collectionView.backgroundColor = UWPhotoBackgroudColor;
        [collectionView registerClass:[UWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"UWPhotoCollectionViewCell"];
        [collectionView registerClass:[UWPhotoReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UWPhotoReusableView class])];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UWPhotoDataManager *)photoData {
    if (!_photoData) {
        _photoData = [[UWPhotoDataManager alloc] init];
    }
    return _photoData;
}

- (SDSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[SDSegmentedControl alloc] initWithTitles:@[@"推荐", @"所有照片"] width:kSegmentItemWidth];
        _segmentedControl.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds)- kBottomSegmentHeight, CGRectGetWidth(self.view.bounds), kBottomSegmentHeight);
        [_segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        BOOL isTop = _photoData.countLocation == UWPhotoCountLocationTop;
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = isTop ? [self.cropBtn titleColorForState:UIControlStateNormal] : [UIColor clearColor];
        _countLabel.textAlignment = isTop? NSTextAlignmentCenter : NSTextAlignmentRight;
        _countLabel.font = [UIFont boldSystemFontOfSize:12];
        _countLabel.textColor = isTop ? [UIColor whiteColor] : UWHEX(0x3c3931);
        _countLabel.alpha = 0;
        CGFloat allWidth = CGRectGetWidth(self.view.bounds);
        if (isTop) {
            _countLabel.frame = CGRectMake(allWidth-45- kCountLabelWidth, CGRectGetMidY(_cropBtn.frame) - kCountLabelWidth/2, kCountLabelWidth, kCountLabelWidth);
            _countLabel.layer.cornerRadius = kCountLabelWidth/2;
            _countLabel.layer.masksToBounds = YES;
            _countLabel.textColor = [UIColor whiteColor];
            _countLabel.textAlignment = NSTextAlignmentCenter;
        }else {
            [_segmentedControl addSubview:_countLabel];
            [_segmentedControl bringSubviewToFront:_countLabel];
            _countLabel.frame = CGRectMake(allWidth - 100 , 0, 85, kBottomSegmentHeight);
        }
    }
    return _countLabel;
}

@end
