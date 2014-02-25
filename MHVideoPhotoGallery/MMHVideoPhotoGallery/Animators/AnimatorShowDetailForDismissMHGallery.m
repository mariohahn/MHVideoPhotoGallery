//
//  AnimatorShowDetailForDismissMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "AnimatorShowDetailForDismissMHGallery.h"
#import "MHOverViewController.h"

@interface AnimatorShowDetailForDismissMHGallery()
@property (nonatomic) CGFloat toTransform;
@property (nonatomic) CGFloat startTransform;
@property (nonatomic) CGRect startFrame;
@property (nonatomic) CGRect navFrame;

@property (nonatomic) BOOL hasActiveVideo;
@property (nonatomic,strong)UIView *viewWhite;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic, strong) MHUIImageViewContentViewAnimation *cellImageSnapshot;
@end

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
            
            if (self.iv.contentMode == UIViewContentModeScaleAspectFit) {
                cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
            }
            if (self.iv.contentMode == UIViewContentModeScaleAspectFill) {
                cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
                
            }
        } completion:^(BOOL finished) {
            self.iv.hidden = NO;
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            
            [[UIApplication sharedApplication] setStatusBarStyle:[MHGallerySharedManager sharedManager].oldStatusBarStyle];
        }];
        
    });
    
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.context = transitionContext;
    
    id toViewControllerNC = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UINavigationController *fromViewController = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
    
    self.containerView = [transitionContext containerView];
    
    UIImage *image;
    UIView *snapShot;
    __block NSNumber *pageIndex;
    
    ImageViewController *imageViewerCurrent;
    
    for (ImageViewController *imageViewerIndex in imageViewer.pvc.viewControllers) {
        if (imageViewerIndex.pageIndex == imageViewer.pageIndex) {
            imageViewerCurrent = imageViewerIndex;
            pageIndex = @(imageViewerIndex.pageIndex);
            image = imageViewerIndex.imageView.image;
            snapShot = [imageViewerIndex.imageView snapshotViewAfterScreenUpdates:NO];
        }
    }
    
    self.cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:fromViewController.view.bounds];
    self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    self.cellImageSnapshot.image = image;
    [self.cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(self.cellImageSnapshot.image.size,fromViewController.view.bounds)];
    self.startFrame = self.cellImageSnapshot.frame;
    
    [imageViewer.pvc.view setHidden:YES];
    
    [toViewControllerNC view].frame = [transitionContext finalFrameForViewController:toViewControllerNC];
    [fromViewController view].alpha =0;
    
    self.viewWhite = [[UIView alloc]initWithFrame:[toViewControllerNC view].frame];
    self.viewWhite.backgroundColor = [UIColor whiteColor];
    if (imageViewer.isHiddingToolBarAndNavigationBar) {
        self.viewWhite.backgroundColor = [UIColor blackColor];
    }
    
    
    [self.containerView addSubview:[toViewControllerNC view]];
    [self.containerView addSubview:self.viewWhite];
    
    
    self.toTransform= [(NSNumber *)[[toViewControllerNC view] valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    self.startTransform = [(NSNumber *)[self.containerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    
    if ([toViewControllerNC view].frame.size.width >[toViewControllerNC view].frame.size.height && self.toTransform ==0) {
        self.toTransform = self.startTransform;
    }
    
    if (imageViewerCurrent.isPlayingVideo && imageViewerCurrent.moviePlayer) {
        self.moviePlayer = imageViewerCurrent.moviePlayer;
        [self.moviePlayer.view setFrame:AVMakeRectWithAspectRatioInsideRect(imageViewerCurrent.moviePlayer.naturalSize,fromViewController.view.bounds)];
        
        self.startFrame = self.moviePlayer.view.frame;
        
        [self.containerView addSubview:self.moviePlayer.view];
        self.iv.hidden = YES;
    }else{
        [self.containerView addSubview:self.cellImageSnapshot];
        if (self.toTransform == self.orientationTransformBeforeDismiss) {
            [self.containerView addSubview:snapShot];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.iv.hidden = YES;
            [snapShot removeFromSuperview];
        });
    }
    self.navFrame = fromViewController.navigationBar.frame;
    if (self.toTransform != self.orientationTransformBeforeDismiss) {
        if (self.moviePlayer) {
            [self.moviePlayer.view setFrame:AVMakeRectWithAspectRatioInsideRect(imageViewerCurrent.moviePlayer.naturalSize,CGRectMake(0, 0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height))];
            self.moviePlayer.view.transform = CGAffineTransformMakeRotation(self.orientationTransformBeforeDismiss);
            self.moviePlayer.view.center = [UIApplication sharedApplication].keyWindow.center;
            self.startFrame = self.moviePlayer.view.bounds;
            
        }else{
            [self.cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(self.cellImageSnapshot.image.size,CGRectMake(0, 0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height))];
            self.cellImageSnapshot.transform = CGAffineTransformMakeRotation(self.orientationTransformBeforeDismiss);
            self.cellImageSnapshot.center = [UIApplication sharedApplication].keyWindow.center;
            self.startFrame = self.cellImageSnapshot.bounds;
            
        }
        self.startTransform = self.orientationTransformBeforeDismiss;
    }
    
}


-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    
    self.viewWhite.alpha = 1.1-percentComplete;
    
    if (self.moviePlayer) {
        if (self.toTransform != self.orientationTransformBeforeDismiss) {
            if (self.orientationTransformBeforeDismiss <0) {
                self.moviePlayer.view.center = CGPointMake(self.moviePlayer.view.center.x-self.changedPoint.y, self.moviePlayer.view.center.y+self.changedPoint.x);
            }else{
                self.moviePlayer.view.center = CGPointMake(self.moviePlayer.view.center.x+self.changedPoint.y, self.moviePlayer.view.center.y-self.changedPoint.x);
            }
        }else{
            self.moviePlayer.view.frame = CGRectMake(self.moviePlayer.view.frame.origin.x-self.changedPoint.x, self.moviePlayer.view.frame.origin.y-self.changedPoint.y, self.moviePlayer.view.frame.size.width, self.moviePlayer.view.frame.size.height);
        }
    }else{
        if (self.toTransform != self.orientationTransformBeforeDismiss) {
            if (self.orientationTransformBeforeDismiss <0) {
                self.cellImageSnapshot.center = CGPointMake(self.cellImageSnapshot.center.x-self.changedPoint.y, self.cellImageSnapshot.center.y+self.changedPoint.x);
            }else{
                self.cellImageSnapshot.center = CGPointMake(self.cellImageSnapshot.center.x+self.changedPoint.y, self.cellImageSnapshot.center.y-self.changedPoint.x);
            }
        }else{
            self.cellImageSnapshot.frame = CGRectMake(self.cellImageSnapshot.frame.origin.x-self.changedPoint.x, self.cellImageSnapshot.frame.origin.y-self.changedPoint.y, self.cellImageSnapshot.frame.size.width, self.cellImageSnapshot.frame.size.height);
        }
    }
}

-(void)finishInteractiveTransition{
    CGFloat delayTime  = 0.0;
    if (self.toTransform != self.orientationTransformBeforeDismiss) {
        [UIView animateWithDuration:0.3 animations:^{
            if (self.moviePlayer) {
                self.moviePlayer.view.transform = CGAffineTransformMakeRotation(self.toTransform);
            }else{
                self.cellImageSnapshot.transform = CGAffineTransformMakeRotation(self.toTransform);
            }
        }];
        delayTime =0.3;
    }
    double delayInSeconds = delayTime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (self.iv.contentMode == UIViewContentModeScaleAspectFill) {
            [self.cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFill
                                             forFrame:[self.containerView convertRect:self.iv.frame fromView:self.iv.superview]
                                         withDuration:0.3
                                           afterDelay:0
                                             finished:^(BOOL finished) {
                                                 
                                             }];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (self.moviePlayer) {
                self.moviePlayer.view.frame = [self.containerView convertRect:self.iv.frame fromView:self.iv.superview];
            }else{
                if (self.iv.contentMode == UIViewContentModeScaleAspectFit) {
                    self.cellImageSnapshot.frame = [self.containerView convertRect:self.iv.frame fromView:self.iv.superview];
                }
            }
            
            self.viewWhite.alpha = 0;
        } completion:^(BOOL finished) {
            self.iv.hidden = NO;
            [self.cellImageSnapshot removeFromSuperview];
            [self.viewWhite removeFromSuperview];
            [self.context completeTransition:!self.context.transitionWasCancelled];
            self.context = nil;
            [[UIApplication sharedApplication] setStatusBarStyle:[MHGallerySharedManager sharedManager].oldStatusBarStyle];
        }];
    });
    
}


-(void)cancelInteractiveTransition{
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.moviePlayer) {
            if (self.toTransform != self.orientationTransformBeforeDismiss) {
                self.moviePlayer.view.center = CGPointMake(self.moviePlayer.view.bounds.size.height/2, self.moviePlayer.view.center.y);
            }else{
                self.moviePlayer.view.frame = self.startFrame;
            }
        }else{
            if (self.toTransform != self.orientationTransformBeforeDismiss) {
                self.cellImageSnapshot.center = [UIApplication sharedApplication].keyWindow.center;
            }else{
                self.cellImageSnapshot.frame = self.startFrame;
            }
        }
        self.viewWhite.alpha = 1;
    } completion:^(BOOL finished) {
        
        self.iv.hidden = NO;
        [self.cellImageSnapshot removeFromSuperview];
        [self.viewWhite removeFromSuperview];
        CGRect endFrame = [[self.context containerView] bounds];
        
        UINavigationController *fromViewController = (UINavigationController*)[self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
        if (self.moviePlayer) {
            if (self.toTransform != self.orientationTransformBeforeDismiss) {
                self.moviePlayer.view.transform = CGAffineTransformMakeRotation(self.toTransform);
                self.moviePlayer.view.center = CGPointMake(self.moviePlayer.view.bounds.size.width/2, self.moviePlayer.view.bounds.size.height/2);
            }else{
                self.moviePlayer.view.bounds = fromViewController.view.bounds;
            }
        }
        
        fromViewController.view.frame = endFrame;
        [fromViewController view].alpha =1;
        
        MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
        [imageViewer.pvc.view setHidden:NO];
        
        if (self.moviePlayer) {
            ImageViewController *imageViewController = (ImageViewController*)[imageViewer.pvc.viewControllers firstObject];
            [imageViewController.view insertSubview:self.moviePlayer.view atIndex:2];
        }
        
        [self.context completeTransition:NO];
        
        if (self.moviePlayer) {
            [UIView performWithoutAnimation:^{
                [self doOrientationwithFromViewController:fromViewController];
            }];
        }else{
            [self doOrientationwithFromViewController:fromViewController];
        }
    }];
    
}

-(void)doOrientationwithFromViewController:(UINavigationController*)fromViewController{
    fromViewController.view.transform = CGAffineTransformMakeRotation(self.startTransform);
    fromViewController.view.center = [UIApplication sharedApplication].keyWindow.center;
    if (self.toTransform != self.orientationTransformBeforeDismiss) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:@"b3JpZW50YXRpb24=" options:0];
        NSString *status = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        [[UIDevice currentDevice]setValue:@(UIInterfaceOrientationPortrait) forKey:status];
        if (self.orientationTransformBeforeDismiss >0) {
            [[UIDevice currentDevice]setValue:@(UIInterfaceOrientationLandscapeRight) forKey:status];
        }else{
            [[UIDevice currentDevice]setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:status];
        }
    }else{
        fromViewController.navigationBar.frame = CGRectMake(0, 0, fromViewController.navigationBar.frame.size.width, 64);
        if (!MHISIPAD) {
            if (self.orientationTransformBeforeDismiss!=0) {
                fromViewController.navigationBar.frame = CGRectMake(0, 0, fromViewController.navigationBar.frame.size.width, 52);
            }
        }
    }
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}


@end
