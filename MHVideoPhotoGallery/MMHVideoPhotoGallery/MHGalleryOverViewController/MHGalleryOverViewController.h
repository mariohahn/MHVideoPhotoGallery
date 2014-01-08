//
//  MHGalleryOverViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHVideoImageGalleryGlobal.h"
#import "MHGalleryImageViewerViewController.h"
#import "SDWebImageManager.h"
#import "AnimatorShowDetail.h"
#import "UIImageView+WebCache.h"
#import "MHGalleryCells.h"

@interface MHGalleryOverViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic)           UICollectionView *cv;

@property (nonatomic)                   NSInteger currentPage;
@property (nonatomic)                   MHGalleryTheme theme;
@property (nonatomic)                   MHGalleryViewMode viewMode;
@property (nonatomic)                   BOOL alwaysShowFullText;

@property (nonatomic, strong)           MHGalleryOverViewCell *clickedCell;

@property (nonatomic, copy) void (^finishedCallback)(NSUInteger photoIndex);
@end
