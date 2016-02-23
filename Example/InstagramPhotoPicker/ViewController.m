//
//  ViewController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "ViewController.h"
#import "TWPhotoPickerController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView *v = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:v];
//    NSMutableArray *imageList = [@[] mutableCopy];
    __block CGFloat y = 50;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];
        photoPicker.cropBlock = ^(NSArray *list) {
            CGFloat size = [[UIScreen mainScreen] bounds].size.width;
            NSInteger index = 0;
            CGFloat _width = 0;
            for (NSDictionary *data in list) {
                UIImage *image = data[@"image"];
                CGFloat width  = image.size.width;
                CGFloat height = size / width * image.size.height;
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, size, height)];
                imageview.image = image;
                [v addSubview:imageview];
                y += height+30;
                if (image.size.width > _width) {
                    _width = image.size.width;
                }
                NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
                NSLog(@"Size of Image:%f MB",(double)[imgData length]/1048576);
                NSLog(@"%@",image);
                index++;
                image = nil;
            }
            v.contentSize = (CGSize){_width+1,y};
            list = nil;
        };
        
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:photoPicker];
        [navCon setNavigationBarHidden:YES];
        
        [self presentViewController:navCon animated:YES completion:NULL];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAction:(id)sender {
}

@end
