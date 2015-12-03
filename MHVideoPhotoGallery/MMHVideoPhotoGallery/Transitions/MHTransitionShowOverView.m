//
//  AnimatorShowOverView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "MHTransitionShowOverView.h"
#import "MHGallerySharedManagerPrivate.h"
#import "TTTAttributedLabel.h"

@interface MHTransitionShowOverView()
@property (nonatomic,strong) UIToolbar *toolbar;
@property (nonatomic,strong) UITextView *titleLabel;
@property (nonatomic,strong) UIToolbar *titleViewBackgroundToolbar;
@property (nonatomic,strong) TTTAttributedLabel *descriptionLabel;
@property (nonatomic,strong) UIToolbar *descriptionViewBackgroundToolbar;
@property (nonatomic,strong) MHOverviewController *toViewController;
@property (nonatomic,strong) MHMediaPreviewCollectionViewCell *cellInteractive;
@property (nonatomic,strong) MHUIImageViewContentViewAnimation *transitionImageView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic)        CGRect startFrame;
@property (nonatomic)        BOOL isHiddingToolBarAndNavigationBar;
@end

@implementation MHTransitionShowOverView

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHOverviewController *toViewController = (MHOverviewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    UIImageView *imageView =  (UIImageView*)[[[fromViewController.pageViewController.viewControllers firstObject] view]viewWithTag:506];
    toViewController.currentPage =  [[fromViewController.pageViewController.viewControllers firstObject] pageIndex];
   
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [MHUIImageViewContentViewAnimation.alloc initWithFrame:CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    cellImageSnapshot.image = imageView.image;
    imageView.hidden = YES;
    
    UIImage *image = imageView.image;
    
    if (!image) {
        image = MHDefaultImageForFrame(fromViewController.view.frame);
        cellImageSnapshot.image = image;
    }
    [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(image.size, cellImageSnapshot.frame)];
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [containerView addSubview:cellImageSnapshot];
    
    UIView *snapShot = [imageView snapshotViewAfterScreenUpdates:NO];
    
    [containerView addSubview:snapShot];
    
    
    CGRect cellFrame  = [toViewController.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]].frame;

    [toViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
    
    [toViewController.collectionView scrollRectToVisible:cellFrame
                                    animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        MHMediaPreviewCollectionViewCell *cellNew = (MHMediaPreviewCollectionViewCell*)[toViewController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.currentPage inSection:0]];
        cellNew.thumbnail.hidden = YES;
        
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
            cellImageSnapshot.frame =[containerView convertRect:cellNew.thumbnail.frame fromView:cellNew.thumbnail.superview];
            cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
        } completion:^(BOOL finished) {
            
            if (MHGalleryOSVersion < 8.0) {
                [toViewController.collectionView reloadData];
            }
            
            [cellImageSnapshot removeFromSuperview];
            imageView.hidden = NO;
            cellNew.thumbnail.hidden =NO;
            
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
    self.toViewController = (MHOverviewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    
    UIImageView *iv =  (UIImageView*)[[[fromViewController.pageViewController.viewControllers firstObject] view]viewWithTag:506];
    self.toViewController.currentPage =  [[fromViewController.pageViewController.viewControllers firstObject] pageIndex];
    
    self.transitionImageView = [MHUIImageViewContentViewAnimation.alloc initWithFrame:CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height)];
    self.transitionImageView.image = iv.image;
    self.transitionImageView.contentMode = UIViewContentModeScaleAspectFit;
    iv.hidden = YES;
    
    UIImage *image =  iv.image;
    if (!image) {
        image = MHDefaultImageForFrame(fromViewController.view.frame);
        self.transitionImageView.image = image;
    }
    [self.transitionImageView setFrame:AVMakeRectWithAspectRatioInsideRect(image.size, self.transitionImageView.frame)];
    
    self.startFrame = self.transitionImageView.frame;
    
    self.toViewController.view.frame = [transitionContext finalFrameForViewController:self.toViewController];
    [containerView addSubview:self.toViewController.view];
    
    MHGalleryController *galleryViewController = (MHGalleryController*)fromViewController.navigationController;
    

    
    self.backView = [UIView.alloc initWithFrame:self.toViewController.view.frame];
    self.backView.backgroundColor = [galleryViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
    
    [containerView addSubview:self.backView];
    [containerView addSubview:self.transitionImageView];
    
    self.isHiddingToolBarAndNavigationBar = fromViewController.isHiddingToolBarAndNavigationBar;
    if (!fromViewController.isHiddingToolBarAndNavigationBar) {
        self.titleLabel.alpha = 1;
        
       // self.descriptionLabel = fromViewController.descriptionView;
        self.descriptionLabel.alpha =1;
        
        self.toolbar = fromViewController.toolbar;
        self.toolbar.alpha =1;
        
        self.titleViewBackgroundToolbar.alpha = 1;
        
        self.descriptionViewBackgroundToolbar.alpha =1;
        
        [containerView addSubview:self.titleViewBackgroundToolbar];
        [containerView addSubview:self.descriptionViewBackgroundToolbar];
        [containerView addSubview:self.toolbar];
        [containerView addSubview:self.titleLabel];
        [containerView addSubview:self.descriptionLabel];
    }else{
        self.backView.backgroundColor = [galleryViewController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarHidden];
        self.toViewController.navigationController.navigationBar.hidden = NO;
        self.toViewController.navigationController.navigationBar.alpha = 0;
    }
    
    CGRect cellFrame  = [self.toViewController.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:self.toViewController.currentPage inSection:0]].frame;
    
    [self.toViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.toViewController.currentPage inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
    
    [self.toViewController.collectionView scrollRectToVisible:cellFrame
                                    animated:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cellInteractive = (MHMediaPreviewCollectionViewCell*)[self.toViewController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.toViewController.currentPage inSection:0]];
        self.cellInteractive.thumbnail.hidden = YES;
        
        if (!self.cellInteractive.videoGradient.isHidden) {
            self.cellInteractive.videoGradient.hidden = YES;
            self.cellInteractive.videoDurationLength.hidden =YES;
            self.cellInteractive.videoIcon.hidden = YES;
        }
    });
}

-(void)finishInteractiveTransition{
    [super finishInteractiveTransition];
    UIView *containerView = [self.context containerView];
    CGRect frame = self.transitionImageView.frame;
    self.transitionImageView.transform = CGAffineTransformIdentity;
    self.transitionImageView.frame = frame;

    [UIView animateWithDuration:0.3 animations:^{
        if (self.isHiddingToolBarAndNavigationBar) {
            self.toViewController.navigationController.navigationBar.alpha = 1;
            MHStatusBar().alpha = MHShouldShowStatusBar() ? 1 : 0;
        }
        self.toolbar.alpha = 0;
        self.titleLabel.alpha = 0;
        self.descriptionLabel.alpha =0;
        self.backView.alpha =0;
        self.titleViewBackgroundToolbar.alpha = 0;
        self.descriptionViewBackgroundToolbar.alpha = 0;
        self.transitionImageView.frame = [containerView convertRect:self.cellInteractive.thumbnail.frame fromView:self.cellInteractive.thumbnail.superview];
        self.transitionImageView.contentMode = UIViewContentModeScaleAspectFill;
    } completion:^(BOOL finished) {
        self.cellInteractive.thumbnail.hidden =NO;
        [self.titleLabel removeFromSuperview];
        [self.descriptionLabel removeFromSuperview];
        [self.toolbar removeFromSuperview];
        [self.transitionImageView removeFromSuperview];
        [self.backView removeFromSuperview];
        [self.titleViewBackgroundToolbar removeFromSuperview];
        [self.descriptionViewBackgroundToolbar removeFromSuperview];
        [self.context completeTransition:YES];
    }];
    
}

-(void)cancelInteractiveTransition{
    [super cancelInteractiveTransition];
    
    MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGRect frame = self.transitionImageView.frame;
    self.transitionImageView.transform = CGAffineTransformIdentity;
    self.transitionImageView.frame = frame;
    
    [UIView animateWithDuration:0.4 animations:^{
        if (self.isHiddingToolBarAndNavigationBar) {
            self.toViewController.navigationController.navigationBar.alpha = 0;
        }
        self.backView.alpha =1;
        self.toolbar.alpha = 1;
        self.titleLabel.alpha = 1;
        self.descriptionLabel.alpha =1;
        self.backView.alpha =1;
        self.titleViewBackgroundToolbar.alpha = 1;
        self.descriptionViewBackgroundToolbar.alpha = 1;
        self.transitionImageView.frame = self.startFrame;
    } completion:^(BOOL finished) {
        if (self.isHiddingToolBarAndNavigationBar) {
            self.toViewController.navigationController.navigationBar.hidden = YES;
        }
        [self.cellInteractive.thumbnail setHidden:NO];
        [self.backView removeFromSuperview];
        [self.transitionImageView removeFromSuperview];
        
        MHImageViewController *imageViewerViewController = [fromViewController.pageViewController.viewControllers firstObject];
        imageViewerViewController.imageView.hidden = NO;
        imageViewerViewController.scrollView.zoomScale =1;
        [self.context completeTransition:NO];
    }];
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];

    if (!self.isHiddingToolBarAndNavigationBar) {
        self.toolbar.alpha = 1-percentComplete;
        self.titleLabel.alpha = 1-percentComplete;
        self.titleViewBackgroundToolbar.alpha = 1-percentComplete;
        self.descriptionLabel.alpha = 1-percentComplete;
        self.descriptionViewBackgroundToolbar.alpha = 1-percentComplete;
    }else{
        self.toViewController.navigationController.navigationBar.alpha = percentComplete;
    }
    
    self.backView.alpha = 1-percentComplete;

    self.transitionImageView.transform = CGAffineTransformMakeScale(self.scale, self.scale);
    self.transitionImageView.center = CGPointMake(self.transitionImageView.center.x-self.changedPoint.x, self.transitionImageView.center.y-self.changedPoint.y);


}
@end
