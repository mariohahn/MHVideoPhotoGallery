//
//  AnimatorShowShareView.m
//  MHVideoPhotoGallery
//
//  Created by Mario Hahn on 12.01.14.
//  Copyright (c) 2014 Mario Hahn. All rights reserved.
//

#import "MHTransitionShowShareView.h"
#import "MHGallerySharedManagerPrivate.h"

@implementation MHTransitionShowShareView

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    self.context = transitionContext;
    
    if(self.present){
        MHGalleryImageViewerViewController *fromViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MHShareViewController *toViewController = (MHShareViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        UIView *containerView = [transitionContext containerView];
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        MHImageViewController *imageViewController = [[fromViewController.pageViewController viewControllers]firstObject];
        
        MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:imageViewController.imageView.frame fromView:imageViewController.imageView.superview]];
        cellImageSnapshot.image = imageViewController.imageView.image;
        
        
        if (!cellImageSnapshot.imageMH) {
            UIView *view = [[UIView alloc]initWithFrame:fromViewController.view.frame];
            view.backgroundColor = [UIColor whiteColor];
            cellImageSnapshot.image =  MHImageFromView(view);
        }
        [cellImageSnapshot setFrame:AVMakeRectWithAspectRatioInsideRect(cellImageSnapshot.imageMH.size, cellImageSnapshot.frame)];
        
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        toViewController.tableViewShare.frame = CGRectMake(0, fromViewController.view.frame.size.height, fromViewController.view.frame.size.width, 240);
        toViewController.gradientView.frame = CGRectMake(0, fromViewController.view.frame.size.height, fromViewController.view.frame.size.width,240);
        toViewController.collectionView.alpha =0;
        toViewController.collectionView.frame =  CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height-240);
        
        if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
            toViewController.collectionView.frame =  CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height-240);
        }else{
            toViewController.collectionView.frame =  CGRectMake(0, 0, fromViewController.view.frame.size.width, fromViewController.view.frame.size.height);
        }
        
        MHGalleryController *galleryController = (MHGalleryController*)fromViewController.navigationController;
        
        UIView *whiteView = [[UIView alloc]initWithFrame:fromViewController.view.frame];
        whiteView.backgroundColor = [galleryController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
        whiteView.alpha =1;
        
        [containerView addSubview:toViewController.view];
        [containerView addSubview:whiteView];

        [containerView addSubview:cellImageSnapshot];
        
        UIView *snapShot = [imageViewController.view snapshotViewAfterScreenUpdates:NO];
        [containerView addSubview:snapShot];
        
        

        [toViewController.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.pageIndex inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [snapShot removeFromSuperview];
            MHMediaPreviewCollectionViewCell *cell = (MHMediaPreviewCollectionViewCell*)[toViewController.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:toViewController.pageIndex inSection:0]];
            
            cell.thumbnail.hidden =YES;
            [UIView animateWithDuration:duration animations:^{
                
                toViewController.collectionView.alpha =1;
               
                if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait){
                    toViewController.gradientView.frame = CGRectMake(0, toViewController.view.frame.size.height-240, toViewController.view.frame.size.width,240);
                    toViewController.tableViewShare.frame = CGRectMake(0, toViewController.view.frame.size.height-230, toViewController.view.frame.size.width, 240);
                }else{
                    toViewController.gradientView.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width,240);
                    toViewController.tableViewShare.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width, 240);
                }
                fromViewController.view.alpha =0;
                cellImageSnapshot.frame = [containerView convertRect:cell.thumbnail.frame fromView:cell.thumbnail.superview];
                cellImageSnapshot.contentMode = UIViewContentModeScaleAspectFill;
                whiteView.alpha =0;
                toViewController.view.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                [cellImageSnapshot removeFromSuperview];
                cell.thumbnail.hidden =NO;
                
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        });
        
    }else{
        MHShareViewController *fromViewController = (MHShareViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        MHGalleryImageViewerViewController *toViewController = (MHGalleryImageViewerViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        MHMediaPreviewCollectionViewCell *cell;
        NSArray *visible = fromViewController.collectionView.visibleCells;

        NSArray *cellsSorted =[self sortObjectsWithFrame:visible];

        if (fromViewController.collectionView.visibleCells.count ==3) {
            cell = cellsSorted[1];
        }else{
            if (MHISIPAD) {
                cell = cellsSorted[cellsSorted.count/2];
            }else{
                if ([fromViewController.collectionView numberOfItemsInSection:0]-1 == [[self sortObjectsWithFrame:visible].lastObject tag]) {
                    cell =  cellsSorted.lastObject;
                }else{
                    cell =  cellsSorted.firstObject;
                }
            }
        }
        
        toViewController.pageIndex = cell.tag;

        [containerView addSubview:toViewController.view];
        
        
        
        
        toViewController.toolbar.frame = CGRectMake(0, fromViewController.view.frame.size.height-44, fromViewController.view.frame.size.width, 44);
        MHGalleryController *galleryController = (MHGalleryController*)fromViewController.navigationController;
        MHGalleryItem *item = [galleryController.dataSource itemForIndex:toViewController.pageIndex];
        [toViewController updateToolBarForItem:item];

        MHImageViewController *ivC =[MHImageViewController imageViewControllerForMHMediaItem:item viewController:toViewController];
        ivC.pageIndex = toViewController.pageIndex;
        
        [toViewController.pageViewController setViewControllers:@[ivC]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:nil];        
        cell.thumbnail.hidden = YES;
        
        MHUIImageViewContentViewAnimation *cellImageSnapshot = [[MHUIImageViewContentViewAnimation alloc] initWithFrame:[containerView convertRect:cell.thumbnail.frame fromView:cell.thumbnail.superview]];
        cellImageSnapshot.image = cell.thumbnail.image;
        
        toViewController.view.alpha =0;
        
        
        UIView *backWhite = [[UIView alloc]initWithFrame:toViewController.view.bounds];
        backWhite.backgroundColor = [galleryController.UICustomization MHGalleryBackgroundColorForViewMode:MHGalleryViewModeImageViewerNavigationBarShown];
        backWhite.alpha =0;
        
        
        [containerView addSubview:toViewController.view];
        [containerView addSubview:backWhite];
        [containerView addSubview:cellImageSnapshot];
        
        [cellImageSnapshot animateToViewMode:UIViewContentModeScaleAspectFit
                                    forFrame:CGRectMake(0, 0, toViewController.view.frame.size.width, toViewController.view.frame.size.height)
                                withDuration:duration
                                  afterDelay:0
                                    finished:^(BOOL finished) {
                                    
                                }];
        
        [UIView animateWithDuration:duration animations:^{
            backWhite.alpha =1;
            fromViewController.gradientView.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width,240);
            fromViewController.tableViewShare.frame = CGRectMake(0, toViewController.view.frame.size.height, toViewController.view.frame.size.width, 240);
        } completion:^(BOOL finished) {
            toViewController.view.alpha =1;
            [cellImageSnapshot removeFromSuperview];
            [backWhite removeFromSuperview];
            cell.thumbnail.hidden =NO;
            
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