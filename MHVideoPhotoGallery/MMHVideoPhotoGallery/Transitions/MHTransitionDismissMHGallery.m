//
//  AnimatorShowDetailForDismissMHGallery.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 08.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHTransitionDismissMHGallery.h"
#import "MHOverviewController.h"
#import "MHGallerySharedManagerPrivate.h"

@interface MHTransitionDismissMHGallery()

@property (nonatomic,assign) CGFloat toTransform;
@property (nonatomic,assign) CGFloat startTransform;
@property (nonatomic,assign) CGRect startFrame;
@property (nonatomic,assign) CGPoint startCenter;

@property (nonatomic,assign) CGRect navFrame;
@property (nonatomic,assign) BOOL wrongTransform;

@property (nonatomic,assign) BOOL hasActiveVideo;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) MHUIImageViewContentViewAnimation *cellImageSnapshot;
@end

@implementation MHTransitionDismissMHGallery

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = transitionContext;
    
    id toViewControllerNC = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    MHGalleryController *fromViewController = (MHGalleryController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [fromViewController view].alpha =0;
    
    
    MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImage *image;
    for (MHImageViewController *imageViewerIndex in imageViewer.pageViewController.viewControllers) {
        if (imageViewerIndex.pageIndex == imageViewer.pageIndex) {
            image = imageViewerIndex.imageView.image;
        }
    }
    if(!image){
        image = MHDefaultImageForFrame(fromViewController.view.frame);
    }
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [MHUIImageViewContentViewAnimation.alloc initWithFrame:fromViewController.view.bounds];
    cellImageSnapshot.image = image;
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.imageMH.size,fromViewController.view.bounds)];
    cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    
    [imageViewer.pageViewController.view setHidden:YES];
    
    [toViewControllerNC view].frame = [transitionContext finalFrameForViewController:toViewControllerNC];
    [toViewControllerNC view].alpha = 0;
    
    UIView *whiteView = [UIView.alloc initWithFrame:fromViewController.view.frame];
    whiteView.backgroundColor = [fromViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    
    if (imageViewer.isHiddingToolBarAndNavigationBar) {
        whiteView.backgroundColor = [fromViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarHidden];
    }
    
    [containerView addSubview:whiteView];
    [containerView addSubview:[toViewControllerNC view]];
    [containerView addSubview:cellImageSnapshot];
    
    self.toTransform = [(NSNumber *)[[toViewControllerNC view] valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    self.startTransform = [(NSNumber *)[containerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    
    if ([toViewControllerNC view].frame.size.width >[toViewControllerNC view].frame.size.height && self.toTransform ==0) {
        self.toTransform = self.startTransform;
    }
    if (self.toTransform != self.orientationTransformBeforeDismiss) {
        cellImageSnapshot.frame  = AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.imageMH.size,CGRectMake(0, 0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height));
        cellImageSnapshot.transform = CGAffineTransformMakeRotation(self.orientationTransformBeforeDismiss);
        cellImageSnapshot.center = [UIApplication sharedApplication].keyWindow.center;
        self.startFrame = cellImageSnapshot.bounds;
    }
    
    CGFloat delayTime  = 0.0;
    if (self.toTransform != self.orientationTransformBeforeDismiss) {
        [UIView animateWithDuration:0.2 animations:^{
            cellImageSnapshot.transform = CGAffineTransformMakeRotation(self.toTransform);
        }];
        delayTime =0.2;
    }
    double delayInSeconds = delayTime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.transitionImageView.hidden = YES;
            
            [UIView animateWithDuration:duration animations:^{
                whiteView.alpha =0;
                [toViewControllerNC view].alpha = 1;
                
                cellImageSnapshot.frame =[containerView convertRect:self.transitionImageView.frame fromView:self.transitionImageView.superview];
                
                if (self.transitionImageView.contentMode == UIViewContentModeScaleAspectFit) {
                    cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
                }
                if (self.transitionImageView.contentMode == UIViewContentModeScaleAspectFill) {
                    cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
                }
            } completion:^(BOOL finished) {
                self.transitionImageView.hidden = NO;
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
            
        });
    });
    
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    self.context = transitionContext;
    
    id toViewControllerNC = (UINavigationController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    MHGalleryController *fromViewController = (MHGalleryController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
    
    self.containerView = [transitionContext containerView];
    
    UIImage *image;
    MHImageViewController *imageViewerCurrent;
    
    for (MHImageViewController *imageViewerIndex in imageViewer.pageViewController.viewControllers) {
        if (imageViewerIndex.pageIndex == imageViewer.pageIndex) {
            imageViewerCurrent = imageViewerIndex;
            image = imageViewerIndex.imageView.image;
        }
    }
    
    self.cellImageSnapshot = [MHUIImageViewContentViewAnimation.alloc initWithFrame:fromViewController.view.bounds];
    self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
    
    if(!image){
        image = MHDefaultImageForFrame(fromViewController.view.frame);
    }
    
    self.cellImageSnapshot.image = image;
    [self.cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(image.size,fromViewController.view.bounds)];
    self.startFrame = self.cellImageSnapshot.frame;
    self.startCenter = self.cellImageSnapshot.center;
    
    [imageViewer.pageViewController.view setHidden:YES];
    
    [toViewControllerNC view].frame = [transitionContext finalFrameForViewController:toViewControllerNC];
    [fromViewController view].alpha =0;
    
    self.backView = [UIView.alloc initWithFrame:[toViewControllerNC view].frame];
    self.backView.backgroundColor = [fromViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    
    if (imageViewer.isHiddingToolBarAndNavigationBar) {
        self.backView.backgroundColor = [fromViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarHidden];
    }
    
    
    [self.containerView addSubview:[toViewControllerNC view]];
    [self.containerView addSubview:self.backView];
    
    self.toTransform = [(NSNumber *)[[toViewControllerNC view] valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    self.startTransform = [(NSNumber *)[self.containerView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    
    self.wrongTransform = NO;
    if ([toViewControllerNC view].frame.size.width >[toViewControllerNC view].frame.size.height && self.toTransform ==0) {
        self.toTransform = self.startTransform;
        self.wrongTransform = YES;
    }

    
    
    if (imageViewerCurrent.isPlayingVideo && imageViewerCurrent.moviePlayer) {
        self.moviePlayer = imageViewerCurrent.moviePlayer;
        [self.moviePlayer.view setFrame:AVMakeRectWithAspectRatioInsideRect(imageViewerCurrent.moviePlayer.naturalSize,fromViewController.view.bounds)];
        
        self.startFrame = self.moviePlayer.view.frame;
        
        [self.containerView addSubview:self.moviePlayer.view];
        self.transitionImageView.hidden = YES;
    }else{
        [self.containerView addSubview:self.cellImageSnapshot];
        self.transitionImageView.hidden = YES;
    }
    self.navFrame = fromViewController.navigationBar.frame;
    if (self.toTransform != self.orientationTransformBeforeDismiss && !self.wrongTransform) {
        if (self.moviePlayer) {
            [self.moviePlayer.view setFrame:AVMakeRectWithAspectRatioInsideRect(imageViewerCurrent.moviePlayer.naturalSize,CGRectMake(0, 0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height))];
            self.moviePlayer.view.transform = CGAffineTransformMakeRotation(self.orientationTransformBeforeDismiss);
            self.moviePlayer.view.center = UIApplication.sharedApplication.keyWindow.center;
            self.startFrame = self.moviePlayer.view.bounds;
            self.startCenter = self.moviePlayer.view.center;
        }else{
            [self.cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(image.size,CGRectMake(0, 0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height))];
            self.cellImageSnapshot.transform = CGAffineTransformMakeRotation(self.orientationTransformBeforeDismiss);
            self.cellImageSnapshot.center = UIApplication.sharedApplication.keyWindow.center;
            self.startFrame = self.cellImageSnapshot.bounds;
            self.startCenter = self.cellImageSnapshot.center;
        }
        self.startTransform = self.orientationTransformBeforeDismiss;
    }
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];
    self.backView.alpha = 1.1-percentComplete;
    if (self.moviePlayer.playbackState != MPMoviePlaybackStateStopped && self.moviePlayer.playbackState != MPMoviePlaybackStatePaused) {
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
        if (self.toTransform != self.orientationTransformBeforeDismiss && !self.wrongTransform) {
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
    [super finishInteractiveTransition];
    
    CGFloat delayTime  = 0.0;
    if (self.toTransform != self.orientationTransformBeforeDismiss && self.transitionImageView  && !self.wrongTransform) {
        [UIView animateWithDuration:0.2 animations:^{
            if (self.moviePlayer) {
                self.moviePlayer.view.transform = CGAffineTransformMakeRotation(self.toTransform);
            }else{
                self.cellImageSnapshot.transform = CGAffineTransformMakeRotation(self.toTransform);
            }
        }];
        delayTime =0.2;
    }
    double delayInSeconds = delayTime;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        
        if (self.transitionImageView.contentMode == UIViewContentModeScaleAspectFill) {
            [self.cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFill
                                             forFrame:[self.containerView convertRect:self.transitionImageView.frame
                                                                             fromView:self.transitionImageView.superview]
                                         withDuration:0.3
                                           afterDelay:0
                                             finished:^(BOOL finished) {
                                                 
                                             }];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            MHStatusBar().alpha = MHShouldShowStatusBar() ? 1 : 0;
            
            self.cellImageSnapshot.clipsToBounds = self.transitionImageView.clipsToBounds;
            self.cellImageSnapshot.layer.cornerRadius = self.transitionImageView.layer.cornerRadius;
            
            if (self.moviePlayer) {
                self.moviePlayer.view.frame = [self.containerView convertRect:self.transitionImageView.frame fromView:self.transitionImageView.superview];
            }else{
                if (!self.transitionImageView) {
                    CGPoint newPoint = self.startCenter;
                    if (self.cellImageSnapshot.center.x > self.startCenter.x) {
                        newPoint.x = self.cellImageSnapshot.center.x + fabs(self.cellImageSnapshot.center.x -self.startCenter.x)*4;
                    }else{
                        newPoint.x = self.cellImageSnapshot.center.x - fabs(self.cellImageSnapshot.center.x -self.startCenter.x)*4;
                    }
                    if (self.cellImageSnapshot.center.y > self.startCenter.y) {
                        newPoint.y = self.cellImageSnapshot.center.y + fabs(self.cellImageSnapshot.center.y -self.startCenter.y)*4;
                    }else{
                        newPoint.y = self.cellImageSnapshot.center.y - fabs(self.cellImageSnapshot.center.y -self.startCenter.y)*4;
                    }
                    self.cellImageSnapshot.center = newPoint;
                }else{
                    if (self.transitionImageView.contentMode == UIViewContentModeScaleAspectFit) {
                        self.cellImageSnapshot.frame = [self.containerView convertRect:self.transitionImageView.frame fromView:self.transitionImageView.superview];
                    }
                }
            }
            
            self.backView.alpha = 0;
        } completion:^(BOOL finished) {
            self.transitionImageView.hidden = NO;
            [self.cellImageSnapshot removeFromSuperview];
            [self.backView removeFromSuperview];
            [self.context completeTransition:!self.context.transitionWasCancelled];
            self.context = nil;
        }];
    });
    
}


-(void)cancelInteractiveTransition{
    [super cancelInteractiveTransition];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.moviePlayer) {
            if (self.toTransform != self.orientationTransformBeforeDismiss) {
                self.moviePlayer.view.center = CGPointMake(self.moviePlayer.view.bounds.size.height/2, self.moviePlayer.view.center.y);
            }else{
                self.moviePlayer.view.frame = self.startFrame;
            }
        }else{
            if (self.toTransform != self.orientationTransformBeforeDismiss) {
                self.cellImageSnapshot.center = UIApplication.sharedApplication.keyWindow.center;
            }else{
                self.cellImageSnapshot.frame = self.startFrame;
            }
        }
        self.backView.alpha = 1;
    } completion:^(BOOL finished) {
        
        self.transitionImageView.hidden = NO;
        [self.cellImageSnapshot removeFromSuperview];
        [self.backView removeFromSuperview];
        
        UINavigationController *fromViewController = (UINavigationController*)[self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
        if (self.moviePlayer) {
            if (self.toTransform != self.orientationTransformBeforeDismiss) {
                self.moviePlayer.view.transform = CGAffineTransformMakeRotation(self.toTransform);
                self.moviePlayer.view.center = CGPointMake(self.moviePlayer.view.bounds.size.width/2, self.moviePlayer.view.bounds.size.height/2);
            }else{
                self.moviePlayer.view.bounds = fromViewController.view.bounds;
            }
        }
        
        fromViewController.view.alpha =1;
        
        MHGalleryImageViewerViewController *imageViewer  = (MHGalleryImageViewerViewController*)fromViewController.visibleViewController;
        imageViewer.pageViewController.view.hidden = NO;
        
        if (self.moviePlayer) {
            MHImageViewController *imageViewController = (MHImageViewController*)imageViewer.pageViewController.viewControllers.firstObject;
            [imageViewController.view insertSubview:self.moviePlayer.view atIndex:2];
        }
        
        if ([self.context respondsToSelector:@selector(viewForKey:)]) { // is on iOS 8?
            [UIApplication.sharedApplication.keyWindow addSubview:fromViewController.view];
            self.moviePlayer = nil;
        }
        
        [self.context completeTransition:NO];
        if (self.moviePlayer) {
            [UIView performWithoutAnimation:^{
                [self doOrientationwithFromViewController:fromViewController];
            }];
        }else{
            if (MHGalleryOSVersion < 8.0) {
                [self doOrientationwithFromViewController:fromViewController];
            }else{
                [UIView performWithoutAnimation:^{
                    [self doOrientationwithFromViewController:fromViewController];
                }];
            }
        }
    }];
}


-(void)doOrientationwithFromViewController:(UINavigationController*)fromViewController{
    
    if (MHGalleryOSVersion < 8.0) {
        fromViewController.view.transform = CGAffineTransformMakeRotation(self.startTransform);
        fromViewController.view.center = UIApplication.sharedApplication.keyWindow.center;
    }
    if (self.toTransform != self.orientationTransformBeforeDismiss) {
        
        NSData *decodedData = [NSData.alloc initWithBase64EncodedString:@"b3JpZW50YXRpb24=" options:0];
        NSString *status = [NSString.alloc initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        if (MHGalleryOSVersion < 8.0) {
            [UIDevice.currentDevice setValue:@(UIInterfaceOrientationPortrait) forKey:status];
        }
        if (self.orientationTransformBeforeDismiss >0) {
            [UIDevice.currentDevice setValue:@(UIInterfaceOrientationLandscapeRight) forKey:status];
        }else{
            [UIDevice.currentDevice setValue:@(UIInterfaceOrientationLandscapeLeft) forKey:status];
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
    return 0.25;
}


@end
