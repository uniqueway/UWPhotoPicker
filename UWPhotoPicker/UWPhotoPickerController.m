//
//  UWPhotoPickerController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "UWPhotoPickerController.h"
#import "UWPhotoEditorViewController.h"
#import "UWPhotoLoader.h"
#import "SVProgressHUD.h"
#import "UWPhotoReusableView.h"
#import "UWPhotoHelper.h"
#import "SDSegmentedControl.h"
#import "UWPhotoDatable.h"
#import "UWPhotoNavigationView.h"
#import "Masonry.h"
#import "UWPhotoBrowserBoard.h"
#import <EXTScope.h>

#define NavigationBarHeight 64
static CGFloat kBottomSegmentHeight = 45;
static CGFloat kSegmentItemWidth = 70;
static NSInteger MAX_SELECTION_COUNT = INFINITY;


@interface UWPhotoPickerController ()

@property (nonatomic, assign) UWPickerStatus status;
@property (nonatomic, strong) SDSegmentedControl *segmentedControl;

@property (nonatomic, assign) BOOL preNavbarHiddenStatus;

@end

@implementation UWPhotoPickerController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _preNavbarHiddenStatus = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden =  YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navBar.title = _dataManager.title;

    self.modelChangedList = [[NSMutableSet alloc] init];
    __weak __typeof(&*self)weakSelf = self;
    _dataManager.finishedLoading = ^{
        [weakSelf calculateCountOfSelectedPhotosByNum:0];
        [weakSelf.collectionView reloadData];
    };

    [self buildUI];
}

- (void)buildUI {
    CGFloat colum = 4.0, spacing = 2.0;
    CGFloat value = floorf((CGRectGetWidth(self.view.bounds) - (colum - 1) * spacing) / colum);
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = CGSizeMake(value, value);
    layout.sectionInset                 = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing      = spacing;
    layout.minimumLineSpacing           = spacing;
    layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 30);
    
    CGRect rect = CGRectMake(0, NavigationBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) -NavigationBarHeight - (_dataManager.isSingleMenu ? 0 : 5));
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, kBottomSegmentHeight, 0);
    collectionView.backgroundColor = UWPhotoBackgroudColor;
    [collectionView registerClass:[UWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"UWPhotoCollectionViewCell"];
    [collectionView registerClass:[UWPhotoReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UWPhotoReusableView class])];
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    [_collectionView reloadData];
    
    if (!_dataManager.isSingleMenu) {
        [self.view addSubview:self.segmentedControl];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self calculateCountOfSelectedPhotosByNum:0];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = _preNavbarHiddenStatus;
    [super viewWillDisappear:animated];
}

- (SelectedStyle)selectedStyle {
    return _dataManager.isSingleSelection ? SelectedStyleLine : SelectedStyleCheck;
}

- (void)handlePhotoStatusAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)isSelected {
    
    id <UWPhotoDatable> photo = [_dataManager photoAtIndex:indexPath];
    UWPhotoCollectionViewCell *cell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (_dataManager.isSingleSelection) { // 单选时，取消上一个图片选中状态，移除所有图片
        UWPhotoCollectionViewCell *selectedCell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        if (cell != selectedCell) {
            selectedCell.isSelected = NO;
            _dataManager.selectionIdentifier = [photo selectionIdentifier];
        }else {
            cell.isSelected = YES;
        }
        if (!_dataManager.hasRightButton) { // 没有「确定」按钮时，选择即返回
            [self confirmSelectedImages];
        }
    }
    
    // 单选时，不包含就选移出所有，再添加新的；多选的时候包含当前model，移出当前model，改的只有是否选中状态，并且成对出现，第二次出现时，并未对此model做修改
    if (_dataManager.isSingleSelection) {
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
    [self calculateCountOfSelectedPhotosByNum:isSelected ? 1 : -1];
    self.selectedIndexPath = indexPath;
    [self handleEditPhotosAtIndexPath:indexPath];
}

- (void)handleEditPhotosAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataManager.editable) {
        id <UWPhotoDatable> photo = [_dataManager photoAtIndex:indexPath];
        UWPhotoEditorViewController *editBoard = [[UWPhotoEditorViewController alloc] init];
        editBoard.currentPhoto = _dataManager.isSingleSelection ? photo : nil;
        editBoard.needFilter = !(_dataManager.isSingleMenu && _dataManager.isSingleSelection);
        @weakify(self);
        editBoard.cropBlock = ^(NSArray *list){
            @strongify(self)
            if (self.selectedPhotos) {
                self.selectedPhotos(list);
            }
            [self backAction];
        };
        [self.navigationController pushViewController:editBoard animated:YES];
    }
}

#pragma mark - event
/// 选择的图片个数
- (void)calculateCountOfSelectedPhotosByNum:(NSUInteger)count {
    self.dataManager.selectedCount += count;
    if (!_dataManager.isSingleSelection) {
        if (_dataManager.countLocation == UWPhotoCountLocationBottom) {
            self.segmentedControl.countOfImages = _dataManager.selectedCount;
        }else {
            self.navBar.count = self.dataManager.selectedCount;
        }
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return [self.dataManager numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataManager numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    id<UWPhotoDatable> photo = [self.dataManager photoAtIndex:indexPath];
    static NSString *CellIdentifier = @"UWPhotoCollectionViewCell";
    UWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectedStyle =  [self selectedStyle];
    cell.photo = photo;
    cell.indexPath = indexPath;
    @weakify(self);
    cell.selectedBlock = ^(BOOL isSelected, NSIndexPath *indexPath) {
        @strongify(self);
        [self handlePhotoStatusAtIndexPath:indexPath selected:isSelected];
    };
    if ( _dataManager.isSingleSelection ) { // 单选时，确定选择状态
        if (self.selectedIndexPath == indexPath) {
            cell.isSelected = YES;
        }else {
            cell.isSelected = NO;
            BOOL isThis = [_dataManager.selectionIdentifier isEqualToString:[photo selectionIdentifier]];
            if ( isThis ) {
                cell.isSelected = YES;
                self.selectedIndexPath = indexPath;
            }
        }
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        UWPhotoReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UWPhotoReusableView class]) forIndexPath:indexPath];
        view.title = [self.dataManager titleInSection:indexPath.section];
        return view;
    }
    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_dataManager.editable) {
        [self handleEditPhotosAtIndexPath:indexPath];
    }else {
        UWPhotoBrowserBoard *board = [[UWPhotoBrowserBoard alloc] init];
        board.dataManager = self.dataManager;
        board.selectedIndexPath = indexPath;
        [self.navigationController pushViewController:board animated:YES];
    }
}

#pragma mark - event response

- (void)backAction {
    if (!_dataManager.isSingleSelection) {
        [self.modelChangedList enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  <UWPhotoDatable> obj, BOOL * _Nonnull stop) {
            [obj setIsSelected:[obj isSelected]];
        }];
    }
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)confirmSelectedImages {
    if (self.selectedPhotos) {
        NSArray *tmp = [NSArray arrayWithArray:[self.modelChangedList allObjects]];
        self.selectedPhotos(tmp);
    }
    [self backAction];
}

- (void)segmentValueChanged:(SDSegmentedControl *)sender {
    self.selectedIndexPath = nil;
    self.dataManager.menuIndex = sender.selectedSegmentIndex == 0?  UWMenuIndexRecommed : UWMenuIndexAll;
    [self.collectionView reloadData];
}
#pragma mark - getters & setters

- (UWPhotoDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[UWPhotoDataManager alloc] init];
    }
    return _dataManager;
}

- (SDSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[SDSegmentedControl alloc] initWithTitles:@[@"推荐", @"所有照片"] width:kSegmentItemWidth];
        _segmentedControl.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds)- kBottomSegmentHeight, CGRectGetWidth(self.view.bounds), kBottomSegmentHeight);
        [_segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (UWPhotoNavigationView *)navBar {
    if (!_navBar) {
        UWPhotoNavigationView *navBar = [[UWPhotoNavigationView alloc] init];
        [navBar.backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        if (_dataManager.hasRightButton) {
            [navBar.rightButton setTitle:@"确定" forState:UIControlStateNormal];
            [navBar.rightButton addTarget:self action:@selector(confirmSelectedImages) forControlEvents:UIControlEventTouchUpInside];
        }
        _navBar = navBar;
        [self.view addSubview:navBar];
        [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.height.mas_equalTo(NavigationBarHeight);
        }];
    }
    return _navBar;
}

@end
