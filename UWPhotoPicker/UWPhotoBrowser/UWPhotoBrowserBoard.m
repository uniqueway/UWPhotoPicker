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
#import "UWBrowserView.h"

@interface UWPhotoBrowserBoard ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UWBrowserView *browserView;
@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, strong) NSArray <UWPhotoDatable> *photos;
@property (nonatomic, strong) NSMutableSet *visiblePhotoViews;
@property (nonatomic, strong) NSMutableSet *reusablePhotoViews;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, weak) UWPhotoCollectionViewCell *highLightCell;

@end

@implementation UWPhotoBrowserBoard

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self calculateCountOfSelectedPhotosByNum:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (SelectedStyle)selectedStyle {
    return SelectedStyleBoth;
}

- (void)handlePhotoStatusAtIndexPath:(NSIndexPath *)indexPath selected:(BOOL)isSelected {
    
    [self scrollToIndexPath:indexPath animated:YES];
    [self calculateCountOfSelectedPhotosByNum: (isSelected ? 1 : -1) ];
}

- (void)calculateCountOfSelectedPhotosByNum:(NSUInteger)count {
    self.dataManager.selectedCount += count;
    if (self.dataManager.selectedCount >= 0) {
        self.navBar.count = self.dataManager.selectedCount;
    }else {
        self.dataManager.selectedCount = 0;
    }
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    [self.browserView scrollToIndexPath:indexPath];
    UWPhotoCollectionViewCell *selectedCell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [selectedCell cellShouldHighlight:NO];
    self.selectedIndexPath = indexPath;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    UWPhotoCollectionViewCell *currentCell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [currentCell cellShouldHighlight:YES];
    [self updateTitleToIndexPath:self.selectedIndexPath];

}

#pragma mark - UI -
- (void)buildUI {
    [self.segmentedControl removeFromSuperview];
    self.segmentedControl = nil;
    _totalCount = 0;
    NSInteger section = [self.dataManager numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        NSInteger count = [self.dataManager numberOfItemsInSection:i];
        _totalCount += count;
    }
    
    self.navBar.backgroundColor = [UIColor blackColor];
    self.navBar.titleColor = [UIColor whiteColor];
    [self.navBar.rightButton setTitle:@"已选" forState:UIControlStateNormal];
    [self.navBar.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navBar.backButton setImage:[UIImage imageNamed:@"UWNavigationBarWhiteBack"] forState:UIControlStateNormal];
    [self.navBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
    }];
    

    [self updateTitleToIndexPath:self.selectedIndexPath];
    [self createCollectionView];
    [self createLine];
    self.browserView.dataManager = self.dataManager;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self scrollToIndexPath:self.selectedIndexPath animated:NO];
        [UIView animateWithDuration:0.1 delay:0.2 options:nil animations:^{
            self.collectionView.alpha = 1;
        } completion:nil];
    });
}

- (void)createCollectionView {
    CGFloat width = 47;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                    = CGSizeMake(width, width);
    layout.sectionInset                = UIEdgeInsetsMake(15, 5, 15, 0);
    layout.minimumInteritemSpacing     = 5;
    layout.minimumLineSpacing          = 5;
    layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
    layout.headerReferenceSize = CGSizeZero;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.dataSource        = self;
    collectionView.delegate          = self;
    collectionView.contentInset      = UIEdgeInsetsMake(0, 30, 0, 30);
    collectionView.backgroundColor   = [UIColor blackColor];
    [collectionView registerClass:[UWPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"UWPhotoCollectionViewCell"];
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.offset(0);
        make.height.mas_equalTo(width+30);
    }];
    collectionView.alpha = 0;
    self.collectionView = collectionView;
}

- (void)updateTitleToIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = 1;
    for (NSInteger section = 0 ; section < indexPath.section; section++) {
        index += [self.dataManager numberOfItemsInSection:section];
    }
    index += indexPath.row;
    
    NSString *title = [NSString stringWithFormat:@"%@/%@", @(index), @(_totalCount)];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self scrollToIndexPath:indexPath animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UWPhotoCollectionViewCell *cell = [super collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedStyle = SelectedStyleBoth;
    BOOL isEqual = self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row;
    [cell cellShouldHighlight:isEqual];
    return cell;
}

#pragma mark - getter -
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView                  = [[UIScrollView alloc] init];
        scrollView.pagingEnabled                  = YES;
        scrollView.delegate                       = self;
        scrollView.showsVerticalScrollIndicator   = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor                = [UIColor blackColor];
        [self.view addSubview:scrollView];
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navBar.mas_bottom).offset(0);
            make.left.right.offset(0);
            make.bottom.offset(-77);
        }];
        _scrollView = scrollView;
        
    }
    return _scrollView;
}

- (UWBrowserView *)browserView {
    if (!_browserView) {
        UWBrowserView *browserView = [[UWBrowserView alloc] init];
        browserView.scrollIndexPath = ^(NSIndexPath *indexPath) {
            [self scrollToIndexPath:indexPath animated:YES];
        };
        [self.view addSubview:browserView];
        [browserView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(44);
            make.left.right.offset(0);
            make.bottom.offset(-77);
        }];
        _browserView = browserView;
    }
    return _browserView;
}
@end
