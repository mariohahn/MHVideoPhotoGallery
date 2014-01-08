//
//  AnimatorShowOverView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "AnimatorShowOverView.h"


@implementation AnimatorShowOverView

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHGalleryOverViewController *toViewController = (MHGalleryOverViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImageView *iv =  (UIImageView*)[[[fromViewController.pvc.viewControllers firstObject] view]viewWithTag:506];
    toViewController.currentPage =  [[fromViewController.pvc.viewControllers firstObject] pageIndex];
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    cellImageSnapshot.image = iv.image;
    iv.hidden = YES;
    
    
    
    if (!cellImageSnapshot.image) {
        UIView *view = [[UIView alloc]initWithFrame:fromViewController.view.frame];
        view.backgroundColor = [UIColor whiteColor];
        cellImageSnapshot.image = [[MHGallerySharedManager sharedManager] imageByRenderingView:view];
    }
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.image.size, cellImageSnapshot.frame)];
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [containerView addSubview:cellImageSnapshot];
    
    UIView *snapShot = [iv snapshotViewAfterScreenUpdates:NO];
    
    [containerView addSubview:snapShot];
    
    UITextView *descriptionLabel = fromViewController.descriptionView;
    descriptionLabel.alpha =1;
    
    UIToolbar *tb = fromViewController.tb;
    tb.alpha =1;
    
    
    UIToolbar *descriptionViewBackground = fromViewController.descriptionViewBackground;
    descriptionViewBackground.alpha =1;
    
    
    [containerView addSubview:descriptionViewBackground];
    [containerView addSubview:tb];
    [containerView addSubview:descriptionLabel];
    
    CGRect cellFrame  = [toViewController.cv.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]].frame;

    [toViewController.cv scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionBottom
                                        animated:NO];
    
    [toViewController.cv scrollRectToVisible:cellFrame
                                    animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MHGalleryOverViewCell *cellNew = (MHGalleryOverViewCell*)[toViewController.cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]];
        [cellNew.iv setHidden:YES];
        
        BOOL videoIconsHidden = YES;
        if (!cellNew.videoGradient.isHidden) {
            cellNew.videoGradient.hidden = YES;
            cellNew.videoDurationLength.hidden =YES;
            cellNew.videoIcon.hidden = YES;
            videoIconsHidden = NO;
        }
        [snapShot removeFromSuperview];
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromViewController.view.alpha = 0.0;
            descriptionLabel.alpha =0;
            tb.alpha =0;
            descriptionViewBackground.alpha =0;
            cellImageSnapshot.frame =[containerView convertRect:cellNew.iv.frame fromView:cellNew.iv.superview];
            cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
        } completion:^(BOOL finished) {
            [cellImageSnapshot removeFromSuperview];
            iv.hidden = NO;
            [cellNew.iv setHidden:NO];
            if (!videoIconsHidden) {
                cellNew.videoGradient.hidden = NO;
                cellNew.videoDurationLength.hidden =NO;
                cellNew.videoIcon.hidden = NO;
            }
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    });
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end
