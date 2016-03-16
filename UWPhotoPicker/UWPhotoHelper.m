
//
//  UWPhotoHelper.m
//  Pods
//
//  Created by 小六 on 3月16日.
//
//

#import "UWPhotoHelper.h"

@implementation UWPhotoHelper

@end

#pragma mark - NSDate -
static NSDateFormatter *uwpp_DateFormatterByDot;

@implementation NSDate (UWPhotoPicker)

- (NSDateFormatter *)formatterByDot {
    if (!uwpp_DateFormatterByDot) {
        uwpp_DateFormatterByDot = [[NSDateFormatter alloc] init];
        [uwpp_DateFormatterByDot setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [uwpp_DateFormatterByDot setDateFormat:@"YYYY.MM.dd"];
    }
    return uwpp_DateFormatterByDot;
}

- (NSString *)uwpp_DateFormatByDot {
    return [[self formatterByDot] stringFromDate:self];
}
@end

#pragma mark - Animation -

@implementation UIView (UWPhotoAnimation)

- (void)uw_scaleAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.3, 0.3, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    animation.values = values;
    [self.layer addAnimation:animation forKey:nil];
}


@end