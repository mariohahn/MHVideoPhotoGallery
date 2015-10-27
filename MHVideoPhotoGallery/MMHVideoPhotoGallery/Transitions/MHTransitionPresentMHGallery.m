//
//  AnimatorShowDetailForPresentingMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 31.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHTransitionPresentMHGallery.h"
#import "MHOverviewController.h"
#import "MHGallery.h"

@interface MHTransitionPresentMHGallery()
@property (nonatomic, strong) MHGalleryController    *interactiveToViewController;
@property (nonatomic, strong) UIView                 *backView;
@property (nonatomic)         CGRect                 startFrame;
@end


@implementation MHTransitionPresentMHGallery


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    MHGalleryController *toViewController = (MHGalleryController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    MHGalleryImageViewerViewController *imageViewer;
    if (toViewController.presentationStyle == MHGalleryViewModeImageViewerNavigationBarHidden) {
        imageViewer = toViewController.viewControllers.lastObject;
        toViewController.navigationBar.hidden = YES;
        imageViewer.toolbar.alpha = 0;
        MHStatusBar().alpha =0;
        imageViewer.view.backgroundColor = [toViewController.UICustomization MHGalleryBackgroundColorForViewMode:toViewController.presentationStyle];
    }
    
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:self.presentingImageView.frame fromView:self.presentingImageView.superview]];
    cellImageSnapshot.image = self.presentingImageView.image;
    
    cellImageSnapshot.clipsToBounds = self.presentingImageView.clipsToBounds;
    cellImageSnapshot.layer.cornerRadius = self.presentingImageView.layer.cornerRadius;
    
    self.presentingImageView.hidden = YES;
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    
    
    UIView *backView = [[UIView alloc]initWithFrame:toViewController.view.frame];
    backView.backgroundColor = [toViewController.UICustomization MHGalleryBackgroundColorForViewMode:toViewController.presentationStyle];
    backView.alpha =0;
    
    [containerView addSubview:backView];
    [containerView addSubview:cellImageSnapshot];
    [containerView addSubview:toViewController.view];
    
    if (self.presentingImageView.contentMode == UIViewContentModeScaleAspectFill) {
        [cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                    forFrame:toViewController.view.bounds
                                withDuration:duration
                                  afterDelay:0
                                    finished:^(BOOL finished) {
                                    }];
    }
    
    if(self.presentingImageView.contentMode == UIViewContentModeScaleAspectFit){
        cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    [UIView animateWithDuration:duration animations:^{
        cellImageSnapshot.layer.cornerRadius = 0;
        
        if(self.presentingImageView.contentMode == UIViewContentModeScaleAspectFit){
            cellImageSnapshot.frame = toViewController.view.bounds;
        }
        backView.alpha =1;
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
                    self.presentingImageView.hidden = NO;
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
    
    self.interactiveToViewController = (MHGalleryController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    self.transitionImageView = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:self.presentingImageView.frame fromView:self.presentingImageView.superview]];
    self.transitionImageView.image = self.presentingImageView.image;
    self.transitionImageView.contentMode = self.presentingImageView.contentMode;
    self.presentingImageView.hidden = YES;
    
    self.startFrame = self.transitionImageView.frame;
    
    self.interactiveToViewController.view.frame = [transitionContext finalFrameForViewController:self.interactiveToViewController];
    self.interactiveToViewController.view.alpha = 0;
    
    
    self.backView = [[UIView alloc]initWithFrame:self.interactiveToViewController.view.frame];
    self.backView.backgroundColor = [self.interactiveToViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    
    self.backView.alpha =0;
    
    [containerView addSubview:self.backView];
    [containerView addSubview:self.interactiveToViewController.view];
    [containerView addSubview:self.transitionImageView];
    
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];
    
    self.backView.alpha = percentComplete;
    self.transitionImageView.center = CGPointMake(self.transitionImageView.center.x-self.changedPoint.x, self.transitionImageView.center.y-self.changedPoint.y);
    self.transitionImageView.transform = CGAffineTransformMakeScale(1+self.scale*3, 1+self.scale*3);
    self.transitionImageView.transform = CGAffineTransformRotate(self.transitionImageView.transform, self.angle);
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
        self.transitionImageView.transform  = [self rotateToZeroAffineTranform];
    } completion:^(BOOL finished) {
        CGRect currentFrame = self.transitionImageView.frame;
        self.transitionImageView.transform = CGAffineTransformIdentity;
        self.transitionImageView.frame = currentFrame;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 0;
            self.transitionImageView.frame = self.startFrame;
        } completion:^(BOOL finished) {
            self.presentingImageView.hidden = NO;
            
            [self.transitionImageView removeFromSuperview];
            [self.backView removeFromSuperview];
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
    
    MHGalleryImageViewerViewController *imageViewer = self.interactiveToViewController.viewControllers.lastObject;
    
    [UIView animateWithDuration:[self timeForUnrotet] animations:^{
        self.transitionImageView.transform  = [self rotateToZeroAffineTranform];
        
    } completion:^(BOOL finished) {
        
        CGRect currentFrame = self.transitionImageView.frame;
        
        self.transitionImageView.transform = CGAffineTransformIdentity;
        self.transitionImageView.frame = currentFrame;
        self.transitionImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.backView.alpha = 1;
        }];
        
        [self.transitionImageView animateToViewMode:UIViewContentModeScaleAspectFit forFrame:imageViewer.view.bounds withDuration:0.3 afterDelay:0 finished:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.interactiveToViewController.view.alpha = 1;
            } completion:^(BOOL finished) {
                self.presentingImageView.hidden = NO;
                [self.transitionImageView removeFromSuperview];
                [self.backView removeFromSuperview];
                [self.context completeTransition:YES];
            }];
        }];
    }];
}

@end
