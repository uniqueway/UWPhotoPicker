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


#define NavigationBarHeight 64
static CGFloat kBottomSegmentHeight = 45;
static CGFloat kSegmentItemWidth = 70;
static NSInteger MAX_SELECTION_COUNT = INFINITY;

@interface UWPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegate> {
    CGFloat beginOriginY;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIImageView *maskView;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *imageDidSelectList;
@property (strong, nonatomic) NSMutableArray *indexPathList;
@property (strong, nonatomic) UIButton *cropBtn;
@property (nonatomic, assign) UWPickerStatus status;

@property (nonatomic, strong) SDSegmentedControl *segmentedControl;
@property (nonatomic, strong) UILabel *countLabel;

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
    self.imageDidSelectList = [@[] mutableCopy];
    self.indexPathList      = [@[] mutableCopy];
    __weak __typeof(&*self)weakSelf = self;
    _photoData.finishedLoading = ^{
        [weakSelf.collectionView reloadData];
    };
    [self.view addSubview:self.segmentedControl];
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)handlePhotoStatusAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)isSelected {
    UWPhoto *photo = [self.photoData photoAtIndex:indexPath];
    if (isSelected) {
        if (_photoData.isSingleSelection) {
            
            NSIndexPath *preIndexPath = (NSIndexPath *)self.indexPathList.firstObject;
            UWPhotoCollectionViewCell *cell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:preIndexPath];
            cell.isSelected = NO;
            [self.imageDidSelectList removeAllObjects];
            [self.indexPathList removeAllObjects];
        }
        [self.imageDidSelectList addObject:photo];
        [self.indexPathList addObject:indexPath];
    }else {
        [self.imageDidSelectList removeObject:photo];
        [self.indexPathList removeObject:indexPath];
    }
    [self calculateCountOfSelectedPhotos];
}

#pragma mark - event

- (void)calculateCountOfSelectedPhotos {
    if (!_photoData.isSingleSelection) {
        self.countLabel.text = [NSString stringWithFormat:@"已选: %@",@(self.imageDidSelectList.count)];
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
    static NSString *CellIdentifier = @"UWPhotoCollectionViewCell";
    UWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    UWPhoto *photo = [self.photoData photoAtIndex:indexPath];
    cell.photo = photo;
    cell.indexPath = indexPath;
    cell.isSelected = ([self.indexPathList containsObject:indexPath]);
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
    UWPhotoCollectionViewCell *cell = (UWPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = !cell.isSelected;
    [self handlePhotoStatusAtIndexPath:indexPath selected:cell.isSelected];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
}


#pragma mark - event response

- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)pushToEditView {
    UWPhotoEditorViewController *view = [[UWPhotoEditorViewController alloc] initWithPhotoList:self.imageDidSelectList crop:self.cropBlock];
    [self.navigationController pushViewController:view animated:YES];
}

- (void)segmentValueChanged:(SDSegmentedControl *)sender {
    self.photoData.menuIndex = sender.selectedSegmentIndex == 0?  UWMenuIndexRecommed : UWMenuIndexAll;
}
#pragma mark - getters & setters

- (UIView *)topView {
    if (_topView == nil) {
        CGFloat navHeight = 44;
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), NavigationBarHeight);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.clipsToBounds = YES;
        self.topView.backgroundColor = [[UIColor colorWithRed:26.0/255 green:29.0/255 blue:33.0/255 alpha:1] colorWithAlphaComponent:.8f];
        
        rect = CGRectMake(0, 20, CGRectGetWidth(self.topView.bounds), navHeight);
        UIView *navView = [[UIView alloc] initWithFrame:rect];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(0, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        [backBtn setImage:[UIImage imageNamed:@"back.png"]
                 forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        CGFloat titleWidth = 100;
        rect = CGRectMake((CGRectGetWidth(navView.bounds)-titleWidth)/2, 0, titleWidth, navHeight);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = self.title;
        if (!self.title) {
            titleLabel.text = @"选择封面";
        }
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [navView addSubview:titleLabel];
        
        rect = CGRectMake(CGRectGetWidth(navView.bounds)-80, 0, 80, CGRectGetHeight(navView.bounds));
        self.cropBtn = [[UIButton alloc] initWithFrame:rect];
        [self.cropBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.cropBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [self.cropBtn setTitleColor:UWHEX(0x00a2a0) forState:UIControlStateNormal];
        [self.cropBtn addTarget:self action:@selector(pushToEditView) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:self.cropBtn];
        
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
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.font = [UIFont boldSystemFontOfSize:12];
        _countLabel.textColor = UWHEX(0x3c3931);
        CGFloat startX = CGRectGetWidth(self.view.bounds) - 100;
        _countLabel.frame = CGRectMake(startX, 0, 85, kBottomSegmentHeight);
        [_segmentedControl addSubview:_countLabel];
        [_segmentedControl bringSubviewToFront:_countLabel];
    }
    return _countLabel;
}

@end
