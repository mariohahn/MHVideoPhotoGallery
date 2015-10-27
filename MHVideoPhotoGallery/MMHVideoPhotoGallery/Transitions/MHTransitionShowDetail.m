//
//  AnimatorShowDetail.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//


#import "MHTransitionShowDetail.h"
#import "MHGalleryLabel.h"

@interface MHTransitionShowDetail()
@property (nonatomic, strong) MHUIImageViewContentViewAnimation *cellImageSnapshot;
@property (nonatomic, strong) UITextView *titleLabel;
@property (nonatomic, strong) UIToolbar *titleViewBackgroundToolbar;
@property (nonatomic, strong) MHGalleryLabel *descriptionLabel;
@property (nonatomic, strong) UIToolbar *descriptionViewBackgroundToolbar;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) MHMediaPreviewCollectionViewCell *cell;
@property (nonatomic)         CGRect startFrame;
@property (nonatomic)         CGRect changedFrame;

@end

@implementation MHTransitionShowDetail

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    MHOverviewController *fromViewController = (MHOverviewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[fromViewController.collectionView cellForItemAtIndexPath:[[fromViewController.collectionView indexPathsForSelectedItems] firstObject]];
    
    
    MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:cell.thumbnail.frame fromView:cell.thumbnail.superview]];
    cellImageSnapshot.image = cell.thumbnail.image;
    cell.thumbnail.hidden = YES;
    
    BOOL videoIconsHidden = YES;
    
    if (!cell.videoGradient.isHidden) {
        cell.videoGradient.hidden = YES;
        cell.videoDurationLength.hidden =YES;
        cell.videoIcon.hidden = YES;
        videoIconsHidden = NO;
    }
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    toViewController.pageViewController.view.hidden = YES;
    
    
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:cellImageSnapshot];
    
    [cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                forFrame:CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height)
                            withDuration:duration
                              afterDelay:0
                                finished:nil];
    
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.02,1.02);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                cellImageSnapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.00,1.00);
            } completion:^(BOOL finished) {
                toViewController.pageViewController.view.hidden = NO;
                cell.thumbnail.hidden = NO;
                if (!videoIconsHidden) {
                    cell.videoGradient.hidden = NO;
                    cell.videoIcon.hidden = NO;
                    cell.videoDurationLength.hidden =NO;
                }
                if ([transitionContext transitionWasCancelled]) {
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

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.context = transitionContext;
    
    MHOverviewController *fromViewController = (MHOverviewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    self.cell = (MHMediaPreviewCollectionViewCell*)[fromViewController.collectionView cellForItemAtIndexPath:self.indexPath];
    
    self.cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:self.cell.thumbnail.frame fromView:self.cell.thumbnail.superview]];
    self.cellImageSnapshot.image = self.cell.thumbnail.image;
    
    self.startFrame = self.cellImageSnapshot.frame;
    self.cell.thumbnail.hidden = YES;
    
    if (!self.cell.videoGradient.isHidden) {
        self.cell.videoGradient.hidden = YES;
        self.cell.videoDurationLength.hidden =YES;
        self.cell.videoIcon.hidden = YES;
    }
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    toViewController.pageViewController.view.hidden = YES;
    
    self.titleLabel.alpha = 0;
    
 //   self.descriptionLabel = toViewController.descriptionView;
    self.descriptionLabel.alpha =0;
    
    self.toolbar = toViewController.toolbar;
    self.toolbar.alpha =0;
    self.toolbar.frame = CGRectMake(0, toViewController.view.frame.size.height-44, toViewController.view.frame.size.width , 44);
    
    self.titleViewBackgroundToolbar.alpha = 0;
    
    self.descriptionViewBackgroundToolbar.alpha =0;
    self.descriptionViewBackgroundToolbar.frame = CGRectMake(0, toViewController.view.frame.size.height-110, toViewController.view.frame.size.width, 110);
    
    self.backView = [UIView.alloc initWithFrame:toViewController.view.bounds];
    self.backView.backgroundColor = UIColor.whiteColor;
    self.backView.alpha =0;
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:self.backView];
    [containerView addSubview:self.cellImageSnapshot];
    [containerView addSubview:self.titleViewBackgroundToolbar];
    [containerView addSubview:self.descriptionViewBackgroundToolbar];
    [containerView addSubview:self.toolbar];
    [containerView addSubview:self.titleLabel];
    [containerView addSubview:self.descriptionLabel];
    
    BOOL imageIsLand = self.cellImageSnapshot.imageMH.size.width > self.cellImageSnapshot.imageMH.size.height;
    
    CGRect changedFrame;
    if (!imageIsLand) {
        CGFloat value = self.cellImageSnapshot.frame.size.width / self.cellImageSnapshot.imageMH.size.width;
        changedFrame = CGRectMake(self.cellImageSnapshot.frame.origin.x, self.cellImageSnapshot.frame.origin.y-((self.cellImageSnapshot.imageMH.size.height*value-self.cellImageSnapshot.frame.size.width)/2), self.cellImageSnapshot.frame.size.width,self.cellImageSnapshot.imageMH.size.height*value);
    }else{
        CGFloat value = self.cellImageSnapshot.frame.size.height / self.cellImageSnapshot.imageMH.size.height;
        changedFrame = CGRectMake(self.cellImageSnapshot.frame.origin.x-((self.cellImageSnapshot.imageMH.size.width*value-self.cellImageSnapshot.frame.size.height)/2),self.cellImageSnapshot.frame.origin.y, self.cellImageSnapshot.imageMH.size.width*value,self.cellImageSnapshot.frame.size.height);
    }
    
    self.changedFrame = changedFrame;
    
    [self.cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                     forFrame:changedFrame
                                 withDuration:0.2
                                   afterDelay:0
                                     finished:^(BOOL finished) {
                                         
                                     }];
}

-(void)finishInteractiveTransition{
    [super finishInteractiveTransition];
    
    MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat scaleForToViewControllerSize = toViewController.view.bounds.size.height/self.changedFrame.size.height;
    BOOL imageIsLand = self.cellImageSnapshot.imageMH.size.width > self.cellImageSnapshot.imageMH.size.height;
    if (imageIsLand) {
        scaleForToViewControllerSize = toViewController.view.bounds.size.width/self.changedFrame.size.width;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform,scaleForToViewControllerSize,scaleForToViewControllerSize);
    transform = CGAffineTransformRotate(transform, 0);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.cellImageSnapshot.transform =transform;
        self.cellImageSnapshot.center = toViewController.view.center;
    } completion:^(BOOL finished) {
        
        CGRect rect = self.cellImageSnapshot.frame;
        
        self.cellImageSnapshot.transform = CGAffineTransformIdentity;
        self.cellImageSnapshot.frame =rect;
        
        [UIView animateWithDuration:0.2 animations:^{
            toViewController.view.alpha = 1;
            self.cellImageSnapshot.frame = toViewController.view.bounds;
            self.titleViewBackgroundToolbar.alpha = 1;
            self.descriptionViewBackgroundToolbar.alpha = 1;
            self.toolbar.alpha = 1;
            self.titleLabel.alpha = 1;
            self.descriptionLabel.alpha = 1;
            
        } completion:^(BOOL finished) {
            self.cell.thumbnail.hidden = NO;
            toViewController.pageViewController.view.hidden = NO;
            toViewController.toolbar = self.toolbar;
            [self.cellImageSnapshot removeFromSuperview];
            [self.backView removeFromSuperview];
            [self.context completeTransition:YES];
        }];
    }];
    
}

-(void)cancelInteractiveTransition{
    [super cancelInteractiveTransition];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform,1+self.scale*3, 1+self.scale*3);
    transform = CGAffineTransformRotate(transform, 0);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.cellImageSnapshot.transform =transform;
    } completion:^(BOOL finished) {
        CGRect rect = self.cellImageSnapshot.frame;
        self.cellImageSnapshot.transform = CGAffineTransformIdentity;
        self.cellImageSnapshot.frame =rect;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.titleViewBackgroundToolbar.alpha = 0;
            self.descriptionViewBackgroundToolbar.alpha = 0;
            self.toolbar.alpha = 0;
            self.titleLabel.alpha = 0;
            self.descriptionLabel.alpha = 0;
            self.backView.alpha =0;
            self.cellImageSnapshot.frame =self.changedFrame;
            self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.cellImageSnapshot.frame =self.startFrame;
                self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
            }completion:^(BOOL finished) {
                [self.titleViewBackgroundToolbar removeFromSuperview];
                [self.descriptionViewBackgroundToolbar removeFromSuperview];
                [self.toolbar removeFromSuperview];
                [self.titleLabel removeFromSuperview];
                [self.descriptionLabel removeFromSuperview];
                [self.backView removeFromSuperview];
                [self.cellImageSnapshot removeFromSuperview];
                self.cell.thumbnail.hidden = NO;
                [self.context completeTransition:NO];
            }];
        }];
    }];
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];
   
    self.backView.alpha = percentComplete;
    self.titleViewBackgroundToolbar.alpha = percentComplete;
    self.descriptionViewBackgroundToolbar.alpha = percentComplete;
    self.toolbar.alpha = percentComplete;
    self.titleLabel.alpha = percentComplete;
    self.descriptionLabel.alpha = percentComplete;
    self.cellImageSnapshot.center = CGPointMake(self.cellImageSnapshot.center.x-self.changedPoint.x, self.cellImageSnapshot.center.y-self.changedPoint.y);
    
    self.cellImageSnapshot.transform = CGAffineTransformMakeScale(1+self.scale*3, 1+self.scale*3);
    self.cellImageSnapshot.transform = CGAffineTransformRotate(self.cellImageSnapshot.transform, self.angle);
    
}

@end