//
//  UWPhotoImageItem.m
//  Pods
//
//  Created by Madao on 12/8/15.
//
//

#import "UWPhotoImageItem.h"

@interface UWPhotoImageItem ()
@end

@implementation UWPhotoImageItem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    UIImage *iconImage = [UIImage imageNamed:@"select_photo_icon"];
    CGFloat iconWidth  = iconImage.size.width/3;
    CGFloat iconHeight = iconImage.size.height/3;
    self.iconContent = [[UIView alloc] initWithFrame:rect];
    self.iconContent.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.iconContent.hidden = YES;
    self.icon = [[UIImageView alloc] initWithImage:iconImage];
    self.icon.frame = CGRectMake((width-iconWidth)/2, (height-iconHeight)/2, iconWidth, iconHeight);
    self.image = [[UIImageView alloc] initWithFrame:rect];
    self.image.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.image];
    [self addSubview:self.iconContent];
    [self.iconContent addSubview:self.icon];
    self.layer.borderColor = [UIColor colorWithRed:127.0/255.0 green:184.0/255.0 blue:54.0/255.0 alpha:1].CGColor;
    return self;
}
@end
