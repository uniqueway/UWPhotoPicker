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
    [self scrollToIndexPath:self.selectedIndexPath];
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
    
    [self scrollToIndexPath:indexPath];
    [self calculateCountOfSelectedPhotosByNum: (isSelected ? 1 : -1) ];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath {
    [self.browserView scrollToIndexPath:indexPath];
    UWPhotoCollectionViewCell *selectedCell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [selectedCell cellShouldHighlight:NO];
    self.selectedIndexPath = indexPath;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.17 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UWPhotoCollectionViewCell *currentCell = (UWPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [currentCell cellShouldHighlight:YES];
    });
}

#pragma mark - UI -
- (void)buildUI {
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UISegmentedControl class]]) {
            [obj removeFromSuperview];
        }
    }];
    
    _totalCount = 0;
    NSInteger section = [self.dataManager numberOfSections];
    for (NSInteger i = 0; i < section; i++) {
        NSInteger count = [self.dataManager numberOfItemsInSection:i];
        _totalCount += count;
    }
    
    self.navBar.backgroundColor = [UIColor blackColor];
    [self.navBar.rightButton setTitle:@"已选" forState:UIControlStateNormal];
    [self.navBar.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.navBar.backButton setImage:[UIImage imageNamed:@"UWNavigationBarWhiteBack"] forState:UIControlStateNormal];
    [self.navBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
    }];

    [self updateTitle];
    [self createCollectionView];
    [self createLine];
    self.browserView.dataManager = self.dataManager;
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
    self.collectionView = collectionView;
}

- (void)updateTitle {
    NSString *title = [NSString stringWithFormat:@"%@/%@", @(self.dataManager.selectedCount), @(_totalCount)];
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
    [self scrollToIndexPath:indexPath];
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
            [self scrollToIndexPath:indexPath];
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
