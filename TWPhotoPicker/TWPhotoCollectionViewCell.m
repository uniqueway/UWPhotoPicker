//
//  TWPhotoCollectionViewCell.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWPhotoCollectionViewCell.h"

#define DEFAULT_COLOR [UIColor clearColor]
#define SELECTED_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]

@implementation TWPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:self.imageView];
        
        self.coverView = [[UIView alloc] initWithFrame:self.bounds];
        self.coverView.backgroundColor = DEFAULT_COLOR;
        [self.contentView addSubview:self.coverView];
        
        UIImage *iconImage = [UIImage imageNamed:@"select_photo_icon"];
        CGSize size = iconImage.size;
        CGFloat height = size.height/UIScreen.mainScreen.scale;
        CGFloat width  = size.width/UIScreen.mainScreen.scale;
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-width)/2, (frame.size.height-height)/2, width, height)];
//        icon.contentMode = UIViewContentModeCenter;
//        icon.layer.borderColor = [UIColor whiteColor].CGColor;
        icon.backgroundColor = [UIColor clearColor];
        icon.image = iconImage;
        self.icon = icon;
        self.icon.hidden = YES;
        [self.coverView addSubview:self.icon];

    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
//    _icon.layer.borderWidth = selected ? 3 : 0;
    _icon.hidden = !selected;
    self.coverView.backgroundColor = selected ? SELECTED_COLOR : DEFAULT_COLOR;
}

@end
