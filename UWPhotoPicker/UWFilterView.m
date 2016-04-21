//
//  UWFilterView.m
//  Pods
//
//  Created by 小六 on 3月23日.
//
//

#import "UWFilterView.h"
#import "UWPhotoFilterCollectionViewCell.h"
#import "UWPhotoHelper.h"
#import <Masonry.h>
@interface UWFilterView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *filterList;

@end

@implementation UWFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UWHEX(0x12110f);
        _currentType = 0;
        self.filterList   = @[@{@"name":@"normal", @"index":@0},
                              @{@"name":@"inkwell", @"index":@1},
                              @{@"name":@"earlybird", @"index":@2},
                              @{@"name":@"xproii", @"index":@3},
                              @{@"name":@"lomofi", @"index":@4}
                              ];
        [self.collectionView reloadData];
    }
    return self;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UWPhotoFilterCollectionViewCell";
    UWPhotoFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *title = [self.filterList objectAtIndex:indexPath.row][@"name"];
    NSInteger index = [[self.filterList objectAtIndex:indexPath.row][@"index"] integerValue];
    
    cell.title.text = title;
    NSString *filterName = [@(index).stringValue stringByAppendingString:@"_filter.jpg"];
    cell.imageView.image = [UIImage imageNamed:filterName];
    cell.selected = (index == self.currentType);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger selectedIndex = [self.filterList[indexPath.row][@"index"] integerValue];
    if (selectedIndex != self.currentType) {
        self.currentType = selectedIndex;
        if (self.selectedFilterType) {
            self.selectedFilterType(selectedIndex);
        }
        [self.collectionView reloadData];
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(63, 85);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing =5;
        flowLayout.scrollDirection  = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = self.backgroundColor;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[UWPhotoFilterCollectionViewCell class] forCellWithReuseIdentifier:@"UWPhotoFilterCollectionViewCell"];
        [self addSubview:collectionView];
        [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (void)setCurrentType:(NSInteger)currentType {
    _currentType = currentType;
    [self.collectionView reloadData];
}
@end
