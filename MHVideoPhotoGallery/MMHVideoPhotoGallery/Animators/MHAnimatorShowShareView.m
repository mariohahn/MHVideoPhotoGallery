//
//  AnimatorShowShareView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 12.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHAnimatorShowShareView.h"


@implementation MHAnimatorShowShareView

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = transitionContext;
    
    if(self.present){
        MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MHShareViewController *toViewController = (MHShareViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        UIView *containerView = [transitionContext containerView];
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        ImageViewController *imageVC = [[fromViewController.pvc viewControllers]firstObject];
        
        
        MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:imageVC.imageView.frame fromView:imageVC.imageView.superview]];
        cellImageSnapshot.image = imageVC.imageView.image;
        
        if (!cellImageSnapshot.image) {
            UIView *view = [[UIView alloc]initWithFrame:fromViewController.view.frame];
            view.backgroundColor = [UIColor whiteColor];
            cellImageSnapshot.image = [[MHGallerySharedManager sharedManager] imageByRenderingView:view];
        }
        [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.image.size, cellImageSnapshot.frame)];
        
        
        
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        toViewController.tableViewShare.frame = CGRectMake(0, fromViewController.view.frame.size.height, fromViewController.view.frame.size.width, 240);
        toViewController.gradientView.frame = CGRectMake(0, fromViewController.view.frame.size.height, fromViewController.view.frame.size.width,240);
        toViewController.cv.alpha =0;
        toViewController.cv.frame =  CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height-240);
        
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
            toViewController.cv.frame =  CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height-240);
        }else{
            toViewController.cv.frame =  CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        }
        
    
        [containerView addSubview:toViewController.view];
        [containerView addSubview:cellImageSnapshot];
        
        UIView *snapShot = [imageVC.view snapshotViewAfterScreenUpdates:NO];
        [containerView addSubview:snapShot];
        
        
        
        [toViewController.cv scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.pageIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [snapShot removeFromSuperview];
            MHGalleryOverViewCell *cell = (MHGalleryOverViewCell*)[toViewController.cv cellForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.pageIndex inSection:0]];
            
            cell.iv.hidden =YES;
            [UIView animateWithDuration:duration animations:^{
                
                toViewController.cv.alpha =1;
               
                if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
                    toViewController.gradientView.frame = CGRectMake(0, toViewController.view.frame.size.height-240, toViewController.view.frame.size.width,240);
                    toViewController.tableViewShare.frame = CGRectMake(0, toViewController.view.frame.size.height-230, toViewController.view.frame.size.width, 240);
                }else{
                    toViewController.gradientView.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width,240);
                    toViewController.tableViewShare.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width, 240);
                }
                
                
                cellImageSnapshot.frame = [containerView convertRect:cell.iv.frame fromView:cell.iv.superview];
                cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
                
                toViewController.view.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                [cellImageSnapshot removeFromSuperview];
                cell.iv.hidden =NO;
                
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        });
        
    }else{
        MHShareViewController *fromViewController = (MHShareViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        MHGalleryOverViewCell *cell;
        if (fromViewController.cv.visibleCells.count ==3) {
            NSArray *visible = fromViewController.cv.visibleCells;
            visible =[self sortObjectsWithFrame:visible];
            cell = visible[1];
        }else{
            cell = [fromViewController.cv.visibleCells firstObject];
        }
        
        toViewController.pageIndex = cell.tag;

        [containerView addSubview:toViewController.view];
        
        
        
        
        toViewController.tb.frame = CGRectMake(0, fromViewController.view.frame.size.height-44, fromViewController.view.frame.size.width, 44);
        MHGalleryItem *item = [MHGallerySharedManager sharedManager].galleryItems[toViewController.pageIndex];
        [toViewController updateToolBarForItem:item];

        ImageViewController *ivC =[ImageViewController imageViewControllerForMHMediaItem:item];
        ivC.pageIndex = toViewController.pageIndex;
        [ivC setValue:toViewController forKey:@"vc"];
        
        [toViewController.pvc setViewControllers:@[ivC]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:nil];
        
        [cell.iv setHidden:YES];
        
        MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:cell.iv.frame fromView:cell.iv.superview]];
        cellImageSnapshot.image = cell.iv.image;
        
        toViewController.view.alpha =0;
        
        UIView *viewWhite = [[UIView alloc]initWithFrame:toViewController.view.bounds];
        viewWhite.backgroundColor = [UIColor whiteColor];
        viewWhite.alpha =0;
        
        
        [containerView addSubview:toViewController.view];
        [containerView addSubview:viewWhite];
        [containerView addSubview:cellImageSnapshot];
        
        [cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                    forFrame:CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height)
                                withDuration:duration
                                  afterDelay:0
                                    finished:^(BOOL finished) {
                                    
                                }];
        
        [UIView animateWithDuration:duration animations:^{
            viewWhite.alpha =1;
            fromViewController.gradientView.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width,240);
            fromViewController.tableViewShare.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width, 240);
        } completion:^(BOOL finished) {
            toViewController.view.alpha =1;
            [cellImageSnapshot removeFromSuperview];
            [viewWhite removeFromSuperview];
            cell.iv.hidden =NO;
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
        
    }
}


-(NSArray*)sortObjectsWithFrame:(NSArray*)objects{
    NSComparator comparatorBlock = ^(id obj1, id obj2) {
        if ([obj1 frame].origin.x > [obj2 frame].origin.x) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 frame].origin.x < [obj2 frame].origin.x) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSMutableArray *fieldsSort = [[NSMutableArray alloc]initWithArray:objects];
    [fieldsSort sortUsingComparator:comparatorBlock];
    return [NSArray arrayWithArray:fieldsSort];
}


- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end