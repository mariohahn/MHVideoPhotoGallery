//
//  MHGalleryPresenterImageView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 20.02.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTransitionPresentMHGallery.h"
#import "MHTransitionDismissMHGallery.h"

@class MHTransitionPresentMHGallery;
@class MHTransitionDismissMHGallery;

@interface MHPresenterImageView : UIImageView <UIGestureRecognizerDelegate>

@property (nonatomic)       BOOL shoudlUsePanGestureReconizer;
/**
 *  set your Current ViewController
 */
@property (nonatomic,strong) UIViewController *viewController;
/**
 *  set your the Data Source
 */
@property (nonatomic,strong) NSArray *galleryItems;
/**
 *  set the currentIndex
 */
@property (nonatomic)        NSInteger currentImageIndex;

@property (nonatomic, copy) void (^finishedCallback)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveDismissMHGallery);

@property (nonatomic,strong) MHTransitionPresentMHGallery *presenter;

-(void)setInseractiveGalleryPresentionWithItems:(NSArray*)galleryItems
                              currentImageIndex:(NSInteger)currentImageIndex
                          currentViewController:(UIViewController*)viewController
                                 finishCallback:(void(^)(UINavigationController *galleryNavMH,NSInteger pageIndex,UIImage *image,MHTransitionDismissMHGallery *interactiveDismissMHGallery)
                                                 )FinishBlock;
@end
