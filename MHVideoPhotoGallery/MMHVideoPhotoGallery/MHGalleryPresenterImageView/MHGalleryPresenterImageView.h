//
//  MHGalleryPresenterImageView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 20.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimatorShowDetailForPresentingMHGallery.h"

@class AnimatorShowDetailForPresentingMHGallery;

@interface MHGalleryPresenterImageView : UIImageView <UIGestureRecognizerDelegate>
@property (nonatomic,strong) id viewController;
@property (nonatomic,strong) AnimatorShowDetailForPresentingMHGallery *presenter;
@property (nonatomic,strong) NSArray   *galleryItems;
@property (nonatomic)        NSInteger currentImageIndex;
@property (nonatomic, copy) void (^finishedCallback)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image);
@end
