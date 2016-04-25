//
//  ViewController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "ViewController.h"
#import "UWPhotoPickerController.h"
#import "UWPhoto.h"
#import "UWPhotoHelper.h"
#import "UWPhotoEditorViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIScrollView *v = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:v];
//    NSMutableArray *imageList = [@[] mutableCopy];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        NSMutableArray *temp = [NSMutableArray array];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
        PHFetchResult *fetchresults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [fetchresults enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([asset isKindOfClass:[PHAsset class]]) {
                [temp addObject:asset];
            }
        }];
        NSArray *result = [self groupPhotosBy1Day:temp];
        BOOL isEdit = YES;
        if (isEdit) {
            UWPhotoEditorViewController *editBoard = [[UWPhotoEditorViewController alloc] init];
            editBoard.needFilter = YES;
            editBoard.isSingle = YES;
            editBoard.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            editBoard.list = result[0];
            UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:editBoard];
            [navCon setNavigationBarHidden:YES];
            [self presentViewController:navCon animated:YES completion:NULL];
        }else {
            UWPhotoPickerController *photoPicker = [[UWPhotoPickerController alloc] init];
            UWPhotoDataManager *dataManager = [[UWPhotoDataManager alloc] init];
            [dataManager loadPhotosWithAll:result recommendPhotos:result singleSelection:NO hasSectionTitle:YES];
            dataManager.hasRightButton = YES;
            dataManager.editable = YES;
            dataManager.countLocation = UWPhotoCountLocationBottom;
            dataManager.title = @"选择照片";
            photoPicker.dataManager = dataManager;
            photoPicker.selectedPhotos = ^(NSArray <UWPhotoDatable>*list) {
                
            };
            UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:photoPicker];
            [navCon setNavigationBarHidden:YES];
            
            [self presentViewController:navCon animated:YES completion:NULL];
        }
    
        
        
//        photoPicker.cropBlock = ^(NSArray *list) {
//            CGFloat size = [[UIScreen mainScreen] bounds].size.width;
//            NSInteger index = 0;
//            CGFloat _width = 0;
//            for (NSDictionary *data in list) {
//                UIImage *image = data[@"image"];
//                CGFloat width  = image.size.width;
//                CGFloat height = size / width * image.size.height;
//                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, size, height)];
//                imageview.image = image;
//                [v addSubview:imageview];
//                y += height+30;
//                if (image.size.width > _width) {
//                    _width = image.size.width;
//                }
//                NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
//                NSLog(@"Size of Image:%f MB",(double)[imgData length]/1048576);
//                NSLog(@"%@",image);
//                index++;
//                image = nil;
//            }
//            v.contentSize = (CGSize){_width+1,y};
//            list = nil;
//        };
        
        
        
    });
}

- (NSArray *)groupPhotosBy1Day:(NSArray < PHAsset *> *)photos {
    NSMutableArray *days = [NSMutableArray array];
    NSMutableArray *temp = [NSMutableArray array];
    NSDate *pre = nil;
    
    for (PHAsset *asset in photos) {
        UWPhoto *photo = [[UWPhoto alloc] init];
        photo.asset = asset;
        if (!pre) {
            [temp addObject:photo];
        }else {
            NSString *title = [asset.creationDate uwpp_DateFormatByDot];
            NSString *preTitle = [pre uwpp_DateFormatByDot];
            if ([title isEqualToString:preTitle]) {
                [temp addObject:photo];
                if (asset == photos.lastObject) {
                    [days addObject:temp];
                    temp = nil;
                }
            }else {
                [days addObject:temp];
                temp = nil;
                temp = [NSMutableArray arrayWithObject:photo];
            }
        }
        pre = asset.creationDate;
    }
    return days;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAction:(id)sender {
}

@end
