//
//  UWPhotoBrowserBoard.m
//  Pods
//
//  Created by 小六 on 3月14日.
//
//

#import "UWPhotoBrowserBoard.h"
#import "UWPhotoDatable.h"
#import "UWPhotoNavigationView.h"
#import <Masonry.h>
#import "UWPhotoCollectionViewCell.h"
#import "UWPhotoHelper.h"


@interface UWPhotoBrowserBoard ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign) NSInteger selectedCount;

@property (nonatomic, strong) NSArray <UWPhotoDatable> *photos;
@property (nonatomic, strong) NSMutableSet *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) UWPhotoNavigationView *navBar;

@end

@implementation UWPhotoBrowserBoard

- (instancetype)initWithPhotos:(NSArray <UWPhotoDatable> *)photos index:(NSUInteger)index selectedCount:(NSUInteger)selectedCount{
    self = [super init];
    if (self) {
        _currentIndex = index > photos.count - 1 ? photos.count - 1 : index;
        _photos = photos;
        _selectedCount = selectedCount > photos.count - 1 ? photos.count - 1 : selectedCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
}

#pragma mark - UI -
- (void)buildUI {
    [self updateTitle];
    [self.collectionView reloadData];
    [self createLine];
}

- (void)updateTitle {
    NSString *title = [NSString stringWithFormat:@"%@/%@", @(_currentIndex), @(_photos.count)];
    self.navBar.title = title;
}

- (void)createLine {
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = UWHEX(0x434343);
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(self.collectionView.mas_top).offset(0);
    }];
}

#pragma mark - event
- (void)backAction {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showPhotos {
    
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_dataManager numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_dataManager numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<UWPhotoDatable> photo = [self.photoData photoAtIndex:indexPath];
    static NSString *CellIdentifier = @"UWPhotoCollectionViewCell";
    UWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectedStyle =  _dataManager.isSingleSelection ? SelectedStyleLine : SelectedStyleCheck;
    cell.photo = photo;
    cell.indexPath = indexPath;
    cell.selectedBlock = ^(BOOL isSelected, NSIndexPath *indexPath) {
        [self handlePhotoStatusAtIndexPath:indexPath selected:isSelected];
    };
    if (_dataManager.isSingleSelection && !self.selecedCell) { // 单选时，确定选择状态
        cell.isSelected = NO;
        BOOL isThis = [_dataManager.selectionIdentifier isEqualToString:[photo selectionIdentifier]];
        if ( isThis ) {
            cell.isSelected = YES;
            self.selecedCell = cell;
        }
    }
    return cell;
}
#pragma mark - getter -
- (UWPhotoNavigationView *)navBar {
    if (!_navBar) {
        UWPhotoNavigationView *navBar = [[UWPhotoNavigationView alloc] init];
        [navBar.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navBar.rightButton setTitle:@"已选" forState:UIControlStateNormal];
        navBar.rightButton.enabled = NO;
        _navBar = navBar;
        [self.view addSubview:navBar];
        [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.height.mas_equalTo(44);
        }];
    }
    return _navBar;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView                  = [[UIScrollView alloc] init];
        scrollView.pagingEnabled                  = YES;
        scrollView.delegate                       = self;
        scrollView.showsVerticalScrollIndicator   = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor                = [UIColor blackColor];
        scrollView.contentSize                    = CGSizeMake([[UIScreen mainScreen] bounds].size.width*_photos.count, 0);
        [self.view addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navBar.mas_bottom).offset(0);
            make.left.right.offset(0);
            make.bottom.offset(-78);
        }];
        _scrollView = scrollView;
        
    }
    return _scrollView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat width = 47;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                    = CGSizeMake(width, width);
        layout.sectionInset                = UIEdgeInsetsMake(0, 15, 0, 15);
        layout.minimumInteritemSpacing     = 5;
        layout.minimumLineSpacing          = 5;
        layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.dataSource        = self;
        collectionView.delegate          = self;
        collectionView.contentInset      = UIEdgeInsetsMake(0, 30, 0, 0);
        collectionView.backgroundColor   = [UIColor blackColor];
        [collectionView registerClass:[UWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"UWPhotoCollectionViewCell"];
        [self.view addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.offset(0);
            make.height.mas_equalTo(width+30);
        }];
        _collectionView = collectionView;
    }
    return _collectionView;
}
@end
