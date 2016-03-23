//
//  UWPhotoFilterCollectionViewCell.m
//  Pods
//
//  Created by Madao on 11/7/15.
//
//

#import "UWPhotoFilterCollectionViewCell.h"
#import <Masonry.h>

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:127.0/255.0 green:184.0/255.0 blue:54.0/255.0 alpha:1]



@implementation UWPhotoFilterCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
        self.content = [[UIView alloc] initWithFrame:self.bounds];
        self.content.backgroundColor = DEFAULT_COLOR;
        [self.contentView addSubview:self.content];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.backgroundColor = [UIColor grayColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.borderWidth = 2.5;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.height.equalTo(self.imageView.mas_width).multipliedBy(1);
        }];

        self.title           = [[UILabel alloc] init];
        self.title.font      = [UIFont systemFontOfSize:12];
        self.title.textColor = [UIColor whiteColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.title];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(8);
            make.left.right.offset(0);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.imageView.layer.borderColor = selected ? SELECTED_COLOR.CGColor : DEFAULT_COLOR.CGColor;
}


@end
