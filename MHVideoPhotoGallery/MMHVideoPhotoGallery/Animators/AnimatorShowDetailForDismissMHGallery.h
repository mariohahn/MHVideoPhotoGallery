//
//  AnimatorShowDetailForDismissMHGallery.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryImageViewerViewController.h"
#import "MHVideoImageGalleryGlobal.h"

@interface AnimatorShowDetailForDismissMHGallery : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIImageView *iv;

@property (nonatomic, assign) BOOL interactionInProgress;
@property (nonatomic,assign) id <UIViewControllerContextTransitioning> context;
@end