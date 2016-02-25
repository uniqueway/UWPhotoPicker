//
//  UWPhotoFilterCollectionViewCell.m
//  Pods
//
//  Created by Madao on 11/7/15.
//
//

#import "UWPhotoFilterCollectionViewCell.h"

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:127.0/255.0 green:184.0/255.0 blue:54.0/255.0 alpha:1]
#define TITLE_HEIGHT 20.f
#define TITLE_FONT [UIFont fontWithName:@"STHeitiSC-Light" size:10]
#define PADDING 3.f

@implementation UWPhotoFilterCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.content = [[UIView alloc] initWithFrame:self.bounds];
        self.content.backgroundColor = DEFAULT_COLOR;
        [self.contentView addSubview:self.content];
        CGFloat width  = CGRectGetWidth(self.bounds);
        CGFloat height = CGRectGetHeight(self.bounds) - PADDING - TITLE_HEIGHT;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, width-PADDING*2, height)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageView.backgroundColor = [UIColor grayColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];

        self.title           = [[UILabel alloc] initWithFrame:CGRectMake(0, height + PADDING, width, TITLE_HEIGHT)];
        self.title.font      = TITLE_FONT;
        self.title.textColor = [UIColor colorWithRed:30/255 green:30/255 blue:30/255 alpha:1];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.title];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.content.backgroundColor = selected ? SELECTED_COLOR : DEFAULT_COLOR;
    self.title.textColor = selected ? [UIColor whiteColor] : [UIColor colorWithRed:30/255 green:30/255 blue:30/255 alpha:1];
}


@end
