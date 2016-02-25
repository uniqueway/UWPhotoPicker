//
//  NSDate+UWPhotoPicker.m
//  Pods
//
//  Created by 小六 on 2月25日.
//
//

#import "NSDate+UWPhotoPicker.h"

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
