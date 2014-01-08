//
//  AnimatorShowDetailForDismissMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "AnimatorShowDetailForDismissMHGallery.h"
#import "MHGalleryOverViewController.h"

@implementation AnimatorShowDetailForDismissMHGallery

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = transitionContext;
    
    id toViewControllerNC = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UINavigationController *fromViewController = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImage *image;
    UIView *snapShot;
    __block NSNumber *pageIndex;
    for (ImageViewController *imageViewerIndex in imageViewer.pvc.viewControllers) {
        if (imageViewerIndex.pageIndex == imageViewer.pageIndex) {
            pageIndex = @(imageViewerIndex.pageIndex);
            image = imageViewerIndex.imageView.image;
            snapShot = [imageViewerIndex.imageView snapshotViewAfterScreenUpdates:NO];
        }
    }
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:fromViewController.view.bounds];
    cellImageSnapshot.image = image;
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.image.size,fromViewController.view.bounds)];
    
    [imageViewer.pvc.view setHidden:YES];
    
    [toViewControllerNC view].frame = [transitionContext finalFrameForViewController:toViewControllerNC];
    [toViewControllerNC view].alpha = 0;
    
    [containerView insertSubview:[toViewControllerNC view] belowSubview:fromViewController.view];
    [containerView addSubview:cellImageSnapshot];
    [containerView addSubview:snapShot];
    
    UINavigationBar *navigationBar = fromViewController.navigationBar;
    [containerView addSubview:navigationBar];
    
    UIToolbar *descriptionViewBackground = imageViewer.descriptionViewBackground;
    [containerView addSubview:descriptionViewBackground];
    
    UITextView *descriptionView = imageViewer.descriptionView;
    [containerView addSubview:descriptionView];
    
    
    UIToolbar *toolBar = imageViewer.tb;
    [containerView addSubview:toolBar];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.iv.hidden = YES;
        [snapShot removeFromSuperview];
        
        [UIView animateWithDuration:duration animations:^{
            navigationBar.alpha =0;
            descriptionView.alpha =0;
            descriptionViewBackground.alpha =0;
            toolBar.alpha =0;
            
            [toViewControllerNC view].alpha = 1;
            [fromViewController view].alpha =0;
            cellImageSnapshot.frame =[containerView convertRect:self.iv.frame fromView:self.iv.superview];
            cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
        } completion:^(BOOL finished) {
            self.iv.hidden = NO;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
        
    });
    
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}


@end
