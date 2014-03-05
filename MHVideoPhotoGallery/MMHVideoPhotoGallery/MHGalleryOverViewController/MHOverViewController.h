//
//  MHGalleryOverViewController.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGallery.h"
#import "MHGalleryImageViewerViewController.h"
#import "SDWebImageManager.h"
#import "MHTransitionShowDetail.h"
#import "UIImageView+WebCache.h"
#import "MHGalleryCells.h"


@interface MHIndexPinchGestureRecognizer : UIPinchGestureRecognizer
@property (strong, nonatomic) NSIndexPath *indexPath;
@end

@interface MHOverViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) UICollectionView      *collectionView;
@property (strong,nonatomic ) MHGalleryOverViewCell *clickedCell;
@property (nonatomic)         NSInteger             currentPage;
@property (nonatomic, strong) NSArray               *galleryItems;

@end
