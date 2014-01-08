//
//  AnimatorShowDetail.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryImageViewerViewController.h"
#import "MHGalleryOverViewController.h"
#import "MHUIImageViewContentViewAnimation.h"

@interface AnimatorShowDetail : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL interactionInProgress;
@property (nonatomic,assign) id <UIViewControllerContextTransitioning> context;
@end