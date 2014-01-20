//
//  AnimatorShowDetailForPresentingMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 31.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "AnimatorShowDetailForPresentingMHGallery.h"
#import "MHGalleryOverViewController.h"

@implementation AnimatorShowDetailForPresentingMHGallery


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
        
    UINavigationController *toViewController = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:self.iv.frame fromView:self.iv.superview]];
    cellImageSnapshot.image = self.iv.image;
    self.iv.hidden = YES;
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    
    
    UIView *view = [[UIView alloc]initWithFrame:toViewController.view.frame];
    view.backgroundColor = [UIColor whiteColor];
    view.alpha =0;
    
    [containerView addSubview:view];
    [containerView addSubview:cellImageSnapshot];
    [containerView addSubview:toViewController.view];

    if (self.iv.contentMode == UIViewContentModeScaleAspectFill) {
        [cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                    forFrame:toViewController.view.bounds
                                withDuration:duration
                                  afterDelay:0
                                    finished:^(BOOL finished) {
                                    }];
    }
    if(self.iv.contentMode == UIViewContentModeScaleAspectFit){
        cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    }

    [UIView animateWithDuration:duration animations:^{
        if(self.iv.contentMode == UIViewContentModeScaleAspectFit){
            cellImageSnapshot.frame = toViewController.view.bounds;
        }
        
        view.alpha =1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.02,1.02);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.00,1.00);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.35 animations:^{
                    toViewController.view.alpha = 1.0;
                    
                } completion:^(BOOL finished) {
                    self.iv.hidden = NO;
                    [cellImageSnapshot removeFromSuperview];
                    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                }];
            }];
        }];
    }];
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}


@end
