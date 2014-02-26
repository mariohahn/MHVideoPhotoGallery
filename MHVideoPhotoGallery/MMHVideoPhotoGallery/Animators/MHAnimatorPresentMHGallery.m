//
//  AnimatorShowDetailForPresentingMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 31.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHAnimatorPresentMHGallery.h"
#import "MHOverViewController.h"
#import "MHGalleryGlobals.h"

@interface MHAnimatorPresentMHGallery()
@property (nonatomic, strong) UINavigationController *toViewControllerInteractive;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic) CGRect startFrame;
@property (nonatomic) CGRect newFrame;
@end


@implementation MHAnimatorPresentMHGallery


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


-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.context = transitionContext;
  
    self.toViewControllerInteractive = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    self.ivAnimation = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:self.iv.frame fromView:self.iv.superview]];
    self.ivAnimation.image = self.iv.image;
    self.ivAnimation.contentMode = self.iv.contentMode;
    self.iv.hidden = YES;
    
    self.startFrame = self.ivAnimation.frame;
    
    self.toViewControllerInteractive.view.frame = [transitionContext finalFrameForViewController:self.toViewControllerInteractive];
    self.toViewControllerInteractive.view.alpha = 0;
    
    
    self.whiteView = [[UIView alloc]initWithFrame:self.toViewControllerInteractive.view.frame];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.alpha =0;
    
    [containerView addSubview:self.whiteView];
    [containerView addSubview:self.toViewControllerInteractive.view];
    [containerView addSubview:self.ivAnimation];

}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];
  
    self.whiteView.alpha = percentComplete;
    self.ivAnimation.center = CGPointMake(self.ivAnimation.center.x-self.changedPoint.x, self.ivAnimation.center.y-self.changedPoint.y);
    self.ivAnimation.transform = CGAffineTransformMakeScale(1+self.scale*3, 1+self.scale*3);
    self.ivAnimation.transform = CGAffineTransformRotate(self.ivAnimation.transform, self.angle);
}
-(CGAffineTransform)rotateToZeroAffineTranform{
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale(1+self.scale*3, 1+self.scale*3);
    transform = CGAffineTransformRotate(transform, 0);
    return transform;
}
-(void)cancelInteractiveTransition{
    [super cancelInteractiveTransition];
    
    
    [UIView animateWithDuration:[self timeForUnrotet] animations:^{
        self.ivAnimation.transform  = [self rotateToZeroAffineTranform];
    } completion:^(BOOL finished) {
        CGRect currentFrame = self.ivAnimation.frame;
        self.ivAnimation.transform = CGAffineTransformIdentity;
        self.ivAnimation.frame = currentFrame;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.whiteView.alpha = 0;
            self.ivAnimation.frame = self.startFrame;
        } completion:^(BOOL finished) {
            self.iv.hidden = NO;

            [self.ivAnimation removeFromSuperview];
            [self.whiteView removeFromSuperview];
            [self.context completeTransition:NO];
        }];
        
    }];
}

-(CGFloat)timeForUnrotet{
    CGFloat isRotateTime = 0.2;
    if (self.angle ==0) {
        isRotateTime =0;
    }
    return isRotateTime;
}

-(void)finishInteractiveTransition{
    [super finishInteractiveTransition];
    
    MHGalleryImageViewerViewController *imageViewer = self.toViewControllerInteractive.viewControllers.lastObject;
    
    [UIView animateWithDuration:[self timeForUnrotet] animations:^{
        self.ivAnimation.transform  = [self rotateToZeroAffineTranform];
    
    } completion:^(BOOL finished) {
        
        CGRect currentFrame = self.ivAnimation.frame;
        
        self.ivAnimation.transform = CGAffineTransformIdentity;
        self.ivAnimation.frame = currentFrame;
        self.ivAnimation.contentMode = UIViewContentModeScaleAspectFit;

        [UIView animateWithDuration:0.3 animations:^{
            self.whiteView.alpha = 1;
        }];
        
        [self.ivAnimation animateToViewMode:UIViewContentModeScaleAspectFit forFrame:imageViewer.view.bounds withDuration:0.3 afterDelay:0 finished:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.toViewControllerInteractive.view.alpha = 1;
            } completion:^(BOOL finished) {
                self.iv.hidden = NO;
                [self.ivAnimation removeFromSuperview];
                [self.whiteView removeFromSuperview];
                [self.context completeTransition:YES];
            }];
        }];
    }];
}

@end
