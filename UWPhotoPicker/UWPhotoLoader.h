//
//  TWImageLoader.h
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import <Foundation/Foundation.h>
#import "UWPhoto.h"

@interface UWPhotoLoader : NSObject

+ (void)loadAllPhotos:(void (^)(NSArray *photos, NSError *error))completion;

@end
