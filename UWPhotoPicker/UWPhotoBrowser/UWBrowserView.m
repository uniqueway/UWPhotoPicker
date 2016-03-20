//
//  UWBrowserView.m
//  Pods
//
//  Created by 小六 on 3月17日.
//
//

#import "UWBrowserView.h"
#import "UWBrowserCollectionViewCell.h"
#import <Masonry.h>
#import "UWPhotoCollectionViewCell.h"

static NSString *UWBrowserCellIndentifier = @"UWBrowserCellIndentifier";

@interface UWBrowserView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;

@end

@implementation UWBrowserView

- (void)setDataManager:(UWPhotoDataManager *)dataManager {
    _dataManager = dataManager;
    [self.collectionView reloadData];
}

- (void)scrollToIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return [self.dataManager numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataManager numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UWPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:UWBrowserCellIndentifier forIndexPath:indexPath];
    id <UWPhotoDatable> photo = [self.dataManager photoAtIndex:indexPath];
    cell.photo = photo;
    [cell shouldScale];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    UWPhotoCollectionViewCell *cell = [[self.collectionView visibleCells] firstObject];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (self.scrollIndexPath) {
        self.scrollIndexPath(indexPath);
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                    = CGSizeMake(size.width, size.height-44-77);
        layout.sectionInset                = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing     = 0;
        layout.minimumLineSpacing          = 0;
        layout.scrollDirection             = UICollectionViewScrollDirectionHorizontal;
        layout.headerReferenceSize = CGSizeZero;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.dataSource        = self;
        collectionView.delegate          = self;
        collectionView.backgroundColor   = [UIColor blackColor];
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[UWPhotoCollectionViewCell class] forCellWithReuseIdentifier:UWBrowserCellIndentifier];
        [self addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.offset(0);
        }];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

@end
