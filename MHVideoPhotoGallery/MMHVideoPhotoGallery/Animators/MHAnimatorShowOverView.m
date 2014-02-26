//
//  AnimatorShowOverView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHAnimatorShowOverView.h"
#import "MHOverViewController.h"

@interface MHAnimatorShowOverView()
@property (nonatomic,strong) UIToolbar *tbInteractive;
@property (nonatomic,strong) UITextView *descriptionLabelInteractive;
@property (nonatomic,strong) UIToolbar *descriptionViewBackgroundInteractive;
@property (nonatomic,strong) MHGalleryOverViewCell *cellInteractive;
@property (nonatomic,strong) MHUIImageViewContentViewAnimation *imageForAnimation;
@property (nonatomic,strong) UIView *whiteView;
@property (nonatomic) CGRect startFrame;
@property (nonatomic) BOOL isHiddingToolBarAndNavigationBar;

@end

@implementation MHAnimatorShowOverView

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHOverViewController *toViewController = (MHOverViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
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
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
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

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    self.context = transitionContext;
    
    MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHOverViewController *toViewController = (MHOverViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    
    UIImageView *iv =  (UIImageView*)[[[fromViewController.pvc.viewControllers firstObject] view]viewWithTag:506];
    toViewController.currentPage =  [[fromViewController.pvc.viewControllers firstObject] pageIndex];
    self.imageForAnimation = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    self.imageForAnimation.image = iv.image;
    self.imageForAnimation.contentMode = UIViewContentModeScaleAspectFit;
    iv.hidden = YES;
    
    
    if (!self.imageForAnimation.image) {
        UIView *view = [[UIView alloc]initWithFrame:fromViewController.view.frame];
        view.backgroundColor = [UIColor whiteColor];
        self.imageForAnimation.image = [[MHGallerySharedManager sharedManager] imageByRenderingView:view];
    }
    [self.imageForAnimation setFrame:AVMakeRectWithAspectRatioInsideRect(self.imageForAnimation.image.size, self.imageForAnimation.frame)];
    
    self.startFrame = self.imageForAnimation.frame;
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:toViewController.view];
    
    
    self.whiteView = [[UIView alloc]initWithFrame:toViewController.view.frame];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:self.whiteView];
    [containerView addSubview:self.imageForAnimation];
    
    self.isHiddingToolBarAndNavigationBar = fromViewController.isHiddingToolBarAndNavigationBar;
    if (!fromViewController.isHiddingToolBarAndNavigationBar) {
        self.descriptionLabelInteractive = fromViewController.descriptionView;
        self.descriptionLabelInteractive.alpha =1;
        
        self.tbInteractive = fromViewController.tb;
        self.tbInteractive.alpha =1;
        
        
        self.descriptionViewBackgroundInteractive = fromViewController.descriptionViewBackground;
        self.descriptionViewBackgroundInteractive.alpha =1;
        
        
        [containerView addSubview:self.descriptionViewBackgroundInteractive];
        [containerView addSubview:self.tbInteractive];
        [containerView addSubview:self.descriptionLabelInteractive];
    }else{
        [toViewController.navigationController.navigationBar setHidden:NO];
        self.whiteView.backgroundColor = [UIColor blackColor];
    }
    
    CGRect cellFrame  = [toViewController.cv.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]].frame;
    
    [toViewController.cv scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
    
    [toViewController.cv scrollRectToVisible:cellFrame
                                    animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cellInteractive = (MHGalleryOverViewCell*)[toViewController.cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]];
        [self.cellInteractive.iv setHidden:YES];
        
        BOOL videoIconsHidden = YES;
        if (!self.cellInteractive.videoGradient.isHidden) {
            self.cellInteractive.videoGradient.hidden = YES;
            self.cellInteractive.videoDurationLength.hidden =YES;
            self.cellInteractive.videoIcon.hidden = YES;
            videoIconsHidden = NO;
        }
    });
}

-(void)finishInteractiveTransition{
    [super finishInteractiveTransition];
    UIView *containerView = [self.context containerView];
    CGRect frame = self.imageForAnimation.frame;
    self.imageForAnimation.transform = CGAffineTransformIdentity;
    self.imageForAnimation.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (self.isHiddingToolBarAndNavigationBar) {
            MHOverViewController *toViewController = (MHOverViewController*)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
            toViewController.navigationController.navigationBar.alpha = 1;
        }
        self.tbInteractive.alpha = 0;
        self.descriptionLabelInteractive.alpha =0;
        self.whiteView.alpha =0;
        self.descriptionViewBackgroundInteractive.alpha = 0;
        self.imageForAnimation.frame = [containerView convertRect:self.cellInteractive.iv.frame fromView:self.cellInteractive.iv.superview];
        self.imageForAnimation.contentMode = UIViewContentModeScaleAspectFill;
    } completion:^(BOOL finished) {
        [self.cellInteractive.iv setHidden:NO];
        [self.descriptionLabelInteractive removeFromSuperview];
        [self.tbInteractive removeFromSuperview];
        [self.imageForAnimation removeFromSuperview];
        [self.whiteView removeFromSuperview];
        [self.descriptionViewBackgroundInteractive removeFromSuperview];
        [self.context completeTransition:YES];
    }];
    
}

-(void)cancelInteractiveTransition{
    [super cancelInteractiveTransition];
    
    MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect frame = self.imageForAnimation.frame;
    self.imageForAnimation.transform = CGAffineTransformIdentity;
    self.imageForAnimation.frame = frame;
    
    [UIView animateWithDuration:0.4 animations:^{
        if (self.isHiddingToolBarAndNavigationBar) {
            MHOverViewController *toViewController = (MHOverViewController*)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
            toViewController.navigationController.navigationBar.alpha = 0;
        }
        self.whiteView.alpha =1;
        self.tbInteractive.alpha = 1;
        self.descriptionLabelInteractive.alpha =1;
        self.whiteView.alpha =1;
        self.descriptionViewBackgroundInteractive.alpha = 1;
        self.imageForAnimation.frame = self.startFrame;
    } completion:^(BOOL finished) {
        if (self.isHiddingToolBarAndNavigationBar) {
            MHOverViewController *toViewController = (MHOverViewController*)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
            [toViewController.navigationController.navigationBar setHidden:YES];
        }
        [self.cellInteractive.iv setHidden:NO];
        [self.whiteView removeFromSuperview];
        [self.imageForAnimation removeFromSuperview];
        
        ImageViewController *imageViewer = [fromViewController.pvc.viewControllers firstObject];
        imageViewer.imageView.hidden = NO;
        imageViewer.scrollView.zoomScale =1;
        [self.context completeTransition:NO];
    }];
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];
    if (!self.isHiddingToolBarAndNavigationBar) {
        self.tbInteractive.alpha = 1-percentComplete;
        self.descriptionLabelInteractive.alpha = 1-percentComplete;
        self.descriptionViewBackgroundInteractive.alpha = 1-percentComplete;
    }else{
        MHOverViewController *toViewController = (MHOverViewController*)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
        toViewController.navigationController.navigationBar.alpha = percentComplete;
    }
    self.whiteView.alpha = 1-percentComplete;
    self.imageForAnimation.transform = CGAffineTransformMakeScale(self.scale, self.scale);
    self.imageForAnimation.center = CGPointMake(self.imageForAnimation.center.x-self.changedPoint.x, self.imageForAnimation.center.y-self.changedPoint.y);

}
@end
