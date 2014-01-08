//
//  AnimatorShowDetail.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//


#import "AnimatorShowDetail.h"

@implementation AnimatorShowDetail

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = transitionContext;
    
    MHGalleryOverViewController *fromViewController = (MHGalleryOverViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    MHGalleryOverViewCell *cell = (MHGalleryOverViewCell*)[fromViewController.cv cellForItemAtIndexPath:[[fromViewController.cv indexPathsForSelectedItems] firstObject]];
    
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:cell.iv.frame fromView:cell.iv.superview]];
    cellImageSnapshot.image = cell.iv.image;
    cell.iv.hidden = YES;
    
    BOOL videoIconsHidden = YES;
    if (!cell.videoGradient.isHidden) {
        cell.videoGradient.hidden = YES;
        cell.videoDurationLength.hidden =YES;
        cell.videoIcon.hidden = YES;
        videoIconsHidden = NO;
    }
   

    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    toViewController.pvc.view.hidden = YES;
    
    UITextView *descriptionLabel = toViewController.descriptionView;
    descriptionLabel.alpha =0;
    
    UIToolbar *tb = toViewController.tb;
    tb.alpha =0;
    tb.frame = CGRectMake(0, toViewController.view.frame.size.height-44, toViewController.view.frame.size.width , 44);
    
    UIToolbar *descriptionViewBackground = toViewController.descriptionViewBackground;
    descriptionViewBackground.alpha =0;
    descriptionViewBackground.frame = CGRectMake(0, toViewController.view.frame.size.height-110, toViewController.view.frame.size.width, 110);
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:cellImageSnapshot];
    [containerView addSubview:descriptionViewBackground];
    [containerView addSubview:tb];
    [containerView addSubview:descriptionLabel];
    

    [UIView animateWithDuration:duration animations:^{
        
        [cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                    forFrame:CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height)
                                withDuration:0 afterDelay:0 finished:^(BOOL finished) {
                                    
                                }];
        
        toViewController.view.alpha = 1.0;
        tb.alpha = 1.0;
        descriptionLabel.alpha = 1.0;
        descriptionViewBackground.alpha =1.0;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.02,1.02);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.00,1.00);
            } completion:^(BOOL finished) {
                toViewController.tb = tb;
                toViewController.pvc.view.hidden = NO;
                cell.iv.hidden = NO;
                if (!videoIconsHidden) {
                    cell.videoGradient.hidden = NO;
                    cell.videoIcon.hidden = NO;
                    cell.videoDurationLength.hidden =NO;
                }
                
                if ([transitionContext transitionWasCancelled]) {
                    tb.alpha = 0;
                    descriptionLabel.alpha = 0;
                    descriptionViewBackground.alpha =0;
                    [transitionContext completeTransition:NO];
                }else{
                    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                }
                [cellImageSnapshot removeFromSuperview];
            }];
        }];
    }];
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end