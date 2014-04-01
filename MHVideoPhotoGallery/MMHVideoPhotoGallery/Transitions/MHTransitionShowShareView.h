//
//  AnimatorShowShareView.h
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 12.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHGalleryImageViewerViewController.h"
#import "MHShareViewController.h"
#import "MHUIImageViewContentViewAnimation.h"
#import "MHMediaPreviewCollectionViewCell.h"

@interface MHTransitionShowShareView : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning>
@property (nonatomic,assign) BOOL interactionInProgress;
@property (nonatomic,assign) BOOL present;

@property (nonatomic,assign) id <UIViewControllerContextTransitioning> context;
@end