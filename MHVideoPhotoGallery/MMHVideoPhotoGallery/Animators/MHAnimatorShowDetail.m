//
//  AnimatorShowDetail.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 27.12.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//


#import "MHAnimatorShowDetail.h"
@interface MHAnimatorShowDetail()
@property (nonatomic, strong) MHUIImageViewContentViewAnimation *cellImageSnapshot;
@property (nonatomic, strong) UITextView *descriptionLabel;
@property (nonatomic, strong) UIToolbar *descriptionViewBackground;
@property (nonatomic, strong) UIToolbar *tb;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) MHGalleryOverViewCell *cell;
@property (nonatomic) CGRect startFrame;
@property (nonatomic) CGRect newFrame;

@end

@implementation MHAnimatorShowDetail

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    MHOverViewController *fromViewController = (MHOverViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
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

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.context = transitionContext;
    
    MHOverViewController *fromViewController = (MHOverViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    self.cell = (MHGalleryOverViewCell*)[fromViewController.cv cellForItemAtIndexPath:self.indexPath];
    
    self.cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:self.cell.iv.frame fromView:self.cell.iv.superview]];
    self.cellImageSnapshot.image = self.cell.iv.image;
    
    self.startFrame = self.cellImageSnapshot.frame;
    self.cell.iv.hidden = YES;
    
    BOOL videoIconsHidden = YES;
    if (!self.cell.videoGradient.isHidden) {
        self.cell.videoGradient.hidden = YES;
        self.cell.videoDurationLength.hidden =YES;
        self.cell.videoIcon.hidden = YES;
        videoIconsHidden = NO;
    }
    
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    toViewController.pvc.view.hidden = YES;
    
    self.descriptionLabel = toViewController.descriptionView;
    self.descriptionLabel.alpha =0;
    
    self.tb = toViewController.tb;
    self.tb.alpha =0;
    self.tb.frame = CGRectMake(0, toViewController.view.frame.size.height-44, toViewController.view.frame.size.width , 44);
    
    self.descriptionViewBackground = toViewController.descriptionViewBackground;
    self.descriptionViewBackground.alpha =0;
    self.descriptionViewBackground.frame = CGRectMake(0, toViewController.view.frame.size.height-110, toViewController.view.frame.size.width, 110);
    
    self.whiteView = [[UIView alloc]initWithFrame:toViewController.view.bounds];
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.alpha =0;
    
    [containerView addSubview:toViewController.view];
    [containerView addSubview:self.whiteView];
    [containerView addSubview:self.cellImageSnapshot];
    [containerView addSubview:self.descriptionViewBackground];
    [containerView addSubview:self.tb];
    [containerView addSubview:self.descriptionLabel];
    
    BOOL imageIsLand = self.cellImageSnapshot.image.size.width > self.cellImageSnapshot.image.size.height;
    
    
    CGRect newFrame;
    if (!imageIsLand) {
        CGFloat value = self.cellImageSnapshot.frame.size.width / self.cellImageSnapshot.image.size.width;
        newFrame = CGRectMake(self.cellImageSnapshot.frame.origin.x, self.cellImageSnapshot.frame.origin.y-((self.cellImageSnapshot.image.size.height*value-self.cellImageSnapshot.frame.size.width)/2), self.cellImageSnapshot.frame.size.width,self.cellImageSnapshot.image.size.height*value);
    }else{
        CGFloat value = self.cellImageSnapshot.frame.size.height / self.cellImageSnapshot.image.size.height;
        newFrame = CGRectMake(self.cellImageSnapshot.frame.origin.x-((self.cellImageSnapshot.image.size.width*value-self.cellImageSnapshot.frame.size.height)/2),self.cellImageSnapshot.frame.origin.y, self.cellImageSnapshot.image.size.width*value,self.cellImageSnapshot.frame.size.height);
    }
    
    self.newFrame = newFrame;
    
    [self.cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                     forFrame:newFrame
                                 withDuration:0.2
                                   afterDelay:0
                                     finished:^(BOOL finished) {
                                         
                                     }];
}

-(void)finishInteractiveTransition{
    [super finishInteractiveTransition];
    
    MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[self.context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat scaleForToViewControllerSize = toViewController.view.bounds.size.height/self.newFrame.size.height;
    BOOL imageIsLand = self.cellImageSnapshot.image.size.width > self.cellImageSnapshot.image.size.height;
    if (imageIsLand) {
        scaleForToViewControllerSize = toViewController.view.bounds.size.width/self.newFrame.size.width;
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
            self.descriptionViewBackground.alpha = 1;
            self.tb.alpha = 1;
            self.descriptionLabel.alpha = 1;
            
        } completion:^(BOOL finished) {
            self.cell.iv.hidden = NO;
            toViewController.pvc.view.hidden = NO;
            toViewController.tb = self.tb;
            toViewController.descriptionViewBackground = self.descriptionViewBackground;
            toViewController.descriptionView = self.descriptionLabel;
            [self.cellImageSnapshot removeFromSuperview];
            [self.whiteView removeFromSuperview];
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
            self.descriptionViewBackground.alpha = 0;
            self.tb.alpha = 0;
            self.descriptionLabel.alpha = 0;
            self.whiteView.alpha =0;
            self.cellImageSnapshot.frame =self.newFrame;
            self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFit;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.cellImageSnapshot.frame =self.startFrame;
                self.cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
            }completion:^(BOOL finished) {
                [self.descriptionViewBackground removeFromSuperview];
                [self.tb removeFromSuperview];
                [self.descriptionLabel removeFromSuperview];
                [self.whiteView removeFromSuperview];
                [self.cellImageSnapshot removeFromSuperview];
                self.cell.iv.hidden = NO;
                [self.context completeTransition:NO];
            }];
        }];
    }];
    
}

-(void)updateInteractiveTransition:(CGFloat)percentComplete{
    [super updateInteractiveTransition:percentComplete];
   
    self.whiteView.alpha = percentComplete;
    self.descriptionViewBackground.alpha = percentComplete;
    self.tb.alpha = percentComplete;
    self.descriptionLabel.alpha = percentComplete;
    self.cellImageSnapshot.center = CGPointMake(self.cellImageSnapshot.center.x-self.changedPoint.x, self.cellImageSnapshot.center.y-self.changedPoint.y);
    
    self.cellImageSnapshot.transform = CGAffineTransformMakeScale(1+self.scale*3, 1+self.scale*3);
    self.cellImageSnapshot.transform = CGAffineTransformRotate(self.cellImageSnapshot.transform, self.angle);
    
}

@end